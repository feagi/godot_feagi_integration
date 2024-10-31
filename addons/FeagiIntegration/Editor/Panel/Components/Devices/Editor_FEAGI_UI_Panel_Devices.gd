@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_Devices

var _dropdown: OptionButton
var _device_list: Editor_FEAGI_UI_Panel_DeviceList
var _is_sensory: bool
var _whole_IO_template: Dictionary

func setup(is_sensory: bool, whole_IO_template: Dictionary) -> void:
	_dropdown = $Header/options
	_device_list = $FeagiUiPanelDeviceList
	_is_sensory = is_sensory
	_whole_IO_template = whole_IO_template
	
	
	var acceptable_device_types: PackedStringArray
	if is_sensory:
		acceptable_device_types = FEAGI_PLUGIN_CONFIG.GODOT_SUPPORTED_SENSORS
	else:
		acceptable_device_types = FEAGI_PLUGIN_CONFIG.GODOT_SUPPORTED_MOTORS
	for acceptable_type in acceptable_device_types:
		_dropdown.add_item(acceptable_type)
	
	_device_list.setup(is_sensory)

func export_FEAGI_IOHandlers() -> Array[FEAGI_IOConnector_Base]:
	return _device_list.export_FEAGI_IOHandlers()

func export_as_FEAGI_config_JSON_device_objects() -> Dictionary:
	return _device_list.export_as_FEAGI_config_JSON_device_objects()

func clear() -> void:
	_device_list.clear()

func load_sort_and_spawn_devices(devices: Array[FEAGI_IOConnector_Base], IO_template: Dictionary, configurator_section_of_devices: Dictionary) -> void:
	_device_list.load_sort_and_spawn_devices(devices, _whole_IO_template, configurator_section_of_devices)
	

func _add_device_button_pressed() -> void:
	var spawn_index: int = _dropdown.get_selected_id()
	if spawn_index == -1:
		return
	var spawn_name: StringName
	if _is_sensory:
		spawn_name = FEAGI_PLUGIN_CONFIG.GODOT_SUPPORTED_SENSORS[spawn_index]
	else:
		spawn_name = FEAGI_PLUGIN_CONFIG.GODOT_SUPPORTED_MOTORS[spawn_index]

	_device_list.spawn_device_new(spawn_name, _whole_IO_template[spawn_name])
	
	
