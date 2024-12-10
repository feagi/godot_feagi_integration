@tool
extends ScrollContainer
class_name Editor_FEAGI_UI_Panel_DeviceList
## Handles spawning the devices

const DEVICE_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Editor_FEAGI_UI_Panel_Device.tscn")

var _device_holder: VBoxContainer
var _is_sensory: bool
var _device_references: Dictionary = {} # key'd by device type name, values are the references to the device objects [Editor_FEAGI_UI_Panel_Device]. Used for counting, and name deduplication

# Sets up the device list, and the add device dropdown
func setup(is_sensory: bool) -> void:
	_device_holder = $VBoxContainer
	_is_sensory = is_sensory
	_device_references = {}
	var possible_device_type_names: PackedStringArray
	if is_sensory:
		possible_device_type_names = FEAGI_PLUGIN_CONFIG.GODOT_SUPPORTED_SENSORS
	else:
		possible_device_type_names = FEAGI_PLUGIN_CONFIG.GODOT_SUPPORTED_MOTORS
	for possible_device_type_name in possible_device_type_names:
		var typed_array: Array[Editor_FEAGI_UI_Panel_Device] = []
		_device_references[possible_device_type_name] = typed_array


## Updates the device ID to something valid. then spawns the UI for that device
func spawn_existing_device_UI(device: FEAGI_IOConnector_Base, configurator_template: Dictionary, configurator_loaded_settings: Dictionary = {})  -> Editor_FEAGI_UI_Panel_Device:
	if _device_references.has(device.get_device_type()):
		device.device_ID = len(_device_references[device.get_device_type()])
	else:
		device.device_ID = 0

	var device_UI: Editor_FEAGI_UI_Panel_Device = DEVICE_PREFAB.instantiate()
	_device_references[device.get_device_type()].append(device_UI)
	_device_holder.add_child(device_UI)
	device_UI.confirm_name_change.connect(_confirm_device_name_change_request)
	device_UI.request_deletion.connect(_device_request_deletion)
	device_UI.setup(device, configurator_template, configurator_loaded_settings)
	return device_UI

## Spawns a new fresh device
func spawn_new_device_UI(device_type: String, configurator_template: Dictionary) -> Editor_FEAGI_UI_Panel_Device:
	var new_device: FEAGI_IOConnector_Base = FEAGI_IOConnector_Base.create_new_IOConnector_by_device_type(device_type)
	if !new_device:
		push_error("FEAGI Configurator: Unable to generate device UI for unknown device type %s!" % device_type)
		return null
	
	var new_device_name_index: int = 0
	var new_device_name: StringName = device_type + " " + str(new_device_name_index)
	while _is_device_name_in_array(device_type, new_device_name):
		new_device_name_index += 1
		new_device_name = device_type + " " + str(new_device_name_index)
	new_device.device_friendly_name = new_device_name
	return spawn_existing_device_UI(new_device, configurator_template)


## Exports an array of FEAGI Device IO Handlers for saving as a config
func export_FEAGI_IOHandlers() -> Array[FEAGI_IOConnector_Base]:
	var device_refs: Array[Editor_FEAGI_UI_Panel_Device] = []
	device_refs.assign(_device_holder.get_children())
	var output: Array[FEAGI_IOConnector_Base] = []
	for ref in device_refs:
		output.append(ref.export_as_FEAGI_IOHandler())
	return output


## Exports top level "capability" seciton of the config JSON
func export_as_FEAGI_config_JSON_device_objects() -> Dictionary:
	var direction: StringName = "output"
	if _is_sensory:
		direction = "input"
	var device_refs: Array[Editor_FEAGI_UI_Panel_Device] = []
	device_refs.assign(_device_holder.get_children())
	var output: Dictionary = {}
	for ref in device_refs:
		if ref.device_type not in output:
			output[ref.device_type] = {}
		output[ref.device_type].merge(ref.export_as_FEAGI_config_JSON_device_object())
	return output


func clear() -> void:
	for child in _device_holder.get_children():
		child.queue_free()
	setup(_is_sensory)


## Given an unsorted array of devices, spawns them in order such that their device ID order is satisfied
func load_sort_and_spawn_devices(devices: Array[FEAGI_IOConnector_Base], IO_template: Dictionary, configurator_section_of_devices: Dictionary) -> void:
	# Seperate devices array into dictionary, key'd by device type, and the vlaue being (unordered) device arrays
	var device_orders: Dictionary = {}
	for device_def in devices:
		if device_def.get_device_type() not in device_orders:
			var arr: Array[FEAGI_IOConnector_Base] = []
			device_orders[device_def.get_device_type()] = arr
		device_orders[device_def.get_device_type()].append(device_def)
	
	for device_type in device_orders:
		var arr: Array[FEAGI_IOConnector_Base] = device_orders[device_type]
		arr.sort_custom(func(a: FEAGI_IOConnector_Base, b: FEAGI_IOConnector_Base): return a.device_ID < b.device_ID)
		for device_def in arr:
			var configurator_prefilled: Dictionary = {}
			if device_def.get_device_type() in configurator_section_of_devices:
				if str(device_def.device_ID) in configurator_section_of_devices[device_def.get_device_type()]:
					configurator_prefilled = configurator_section_of_devices[device_def.get_device_type()][str(device_def.device_ID)]
			spawn_existing_device_UI(device_def, IO_template[device_def.get_device_type()], configurator_prefilled)


func _device_request_deletion(device_ref: Editor_FEAGI_UI_Panel_Device) -> void:
	var device_index: int = _device_references[device_ref.device_type].find(device_ref)
	if device_index > -1:
		_device_references[device_ref.device_type].remove_at(device_index)
		_update_all_indexes_for_type(device_ref.device_type)
	device_ref.queue_free()


func _update_all_indexes_for_type(type_name: StringName) -> void:
	var index: int = 0
	for device in _device_references[type_name]:
		if device == null:
			continue
		device.set_title_label_index(index)
		index += 1
		

func _confirm_device_name_change_request(requesting_new_name: StringName, device_ref: Editor_FEAGI_UI_Panel_Device) -> void:
	if _device_references[device_ref.device_type].any(func(device: Editor_FEAGI_UI_Panel_Device): return device.device_friendly_name == requesting_new_name):
		device_ref.set_device_name(device_ref.device_friendly_name) # Reject, reset textbox
	else:
		device_ref.set_device_name(requesting_new_name) # Accept
		

func _is_device_name_in_array(type_name: StringName, searching_name: StringName) -> bool:
	for device in _device_references[type_name]:
		if device.device_friendly_name == searching_name:
			return true
	return false
