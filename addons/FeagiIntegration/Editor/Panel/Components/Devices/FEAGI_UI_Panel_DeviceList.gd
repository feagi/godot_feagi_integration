@tool
extends ScrollContainer
class_name FEAGI_UI_Panel_DeviceList
## Handles spawning the devices

var _device_holder: VBoxContainer

const DEVICE_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/FEAGI_UI_Panel_Device.tscn")

const SPECIFIC_DEVICE_UI_PATHS_SENSORY: Dictionary = {
	FEAGI_IOHandler_Sensory_Camera.TYPE_NAME: preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/Sensory/FEAGI_UI_Panel_SpecificSensoryDevice_Camera.tscn"),
	FEAGI_IOHandler_Sensory_Accelerometer.TYPE_NAME: preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/Sensory/FEAGI_UI_Panel_SpecificSensoryDevice_Accelerometer.tscn"),
	FEAGI_IOHandler_Sensory_Gyro.TYPE_NAME: preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/Sensory/FEAGI_UI_Panel_SpecificSensoryDevice_Gyro.tscn"),
	FEAGI_IOHandler_Sensory_Proximity.TYPE_NAME: preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/Sensory/FEAGI_UI_Panel_SpecificSensoryDevice_Proximity.tscn")
}

const SPECIFIC_DEVICE_UI_PATHS_MOTOR: Dictionary = {
	FEAGI_IOHandler_Motor_MotionControl.TYPE_NAME: preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/Motor/FEAGI_UI_Panel_SpecificMotorDevice_MotionControl.tscn")

}

var _is_sensory: bool
var _device_references: Dictionary = {} # key'd by device type name, values are the references to the device objects [FEAGI_UI_Panel_Device]. Used for counting, and name deduplication


func setup(is_sensory: bool) -> void:
	_device_holder = $VBoxContainer
	_is_sensory = is_sensory
	var possible_device_type_names: PackedStringArray
	if is_sensory:
		possible_device_type_names = FEAGI_PLUGIN.GODOT_SUPPORTED_SENSORS
	else:
		possible_device_type_names = FEAGI_PLUGIN.GODOT_SUPPORTED_MOTORS
	for possible_device_type_name in possible_device_type_names:
		var typed_array: Array[FEAGI_UI_Panel_Device] = []
		_device_references[possible_device_type_name] = typed_array

func spawn_device_new(device_type: StringName, configurator_template: Dictionary) -> void:
	var device_specific_UI: FEAGI_UI_Panel_SpecificDeviceUI_Base
	if _is_sensory:
		if device_type not in SPECIFIC_DEVICE_UI_PATHS_SENSORY:
			push_error("FEAGI: Cannot spawn unknown sensory device type %s!" % device_type)
			return
		device_specific_UI = SPECIFIC_DEVICE_UI_PATHS_SENSORY[device_type].instantiate()
	else:
		if device_type not in SPECIFIC_DEVICE_UI_PATHS_MOTOR:
			push_error("FEAGI: Cannot spawn unknown motor device type %s!" % device_type)
			return
		device_specific_UI = SPECIFIC_DEVICE_UI_PATHS_MOTOR[device_type].instantiate()
	
	var device: FEAGI_UI_Panel_Device = DEVICE_PREFAB.instantiate()
	var device_index: int = len(_device_references[device_type])
	var device_name_index: int = device_index
	var device_name: StringName = device_type + " " + str(device_name_index)
	
	while _is_device_name_in_array(device_type, device_name):
		device_name_index += 1
		device_name = device_type + " " + str(device_name_index)
	
	_device_references[device_type].append(device)
	_device_holder.add_child(device)
	device.confirm_name_change.connect(_confirm_device_name_change_request)
	device.request_deletion.connect(_device_request_deletion)
	device.setup(device_type, device_index, device_name, false, device_specific_UI, configurator_template)

## Exports an array of FEAGI Device IO Handlers for saving as a config
func export_FEAGI_IOHandlers() -> Array[FEAGI_IOHandler_Base]:
	var device_refs: Array[FEAGI_UI_Panel_Device] = []
	device_refs.assign(_device_holder.get_children())
	var output: Array[FEAGI_IOHandler_Base] = []
	for ref in device_refs:
		output.append(ref.export_as_FEAGI_IOHandler())
	return output

## Exports top level "capability" seciton of the config JSON
func export_as_FEAGI_config_JSON_device_objects() -> Dictionary:
	var direction: StringName = "output"
	if _is_sensory:
		direction = "input"
	var device_refs: Array[FEAGI_UI_Panel_Device] = []
	device_refs.assign(_device_holder.get_children())
	var output: Dictionary = {}
	for ref in device_refs:
		if ref.device_type not in output:
			output[ref.device_type] = {}
		output[ref.device_type].merge(ref.export_as_FEAGI_config_JSON_device_object())
	return output
	

func _device_request_deletion(device_ref: FEAGI_UI_Panel_Device) -> void:
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
		

func _confirm_device_name_change_request(requesting_new_name: StringName, device_ref: FEAGI_UI_Panel_Device) -> void:
	if _device_references[device_ref.device_type].any(func(device: FEAGI_UI_Panel_Device): return device.device_friendly_name == requesting_new_name):
		device_ref.set_device_name(device_ref.device_friendly_name) # Reject, reset textbox
	else:
		device_ref.set_device_name(requesting_new_name) # Accept
		

func _is_device_name_in_array(type_name: StringName, searching_name: StringName) -> bool:
	for device in _device_references[type_name]:
		if device.device_friendly_name == searching_name:
			return true
	return false
