@tool
extends PanelContainer
class_name FEAGI_UI_Panel_Device

var device_type: StringName:
	get: return _device_type

var _type_header: Label
var _device_name_line: LineEdit
var _is_disabled_box: CheckBox
var _device_settings: FEAGI_UI_Panel_SpecificDeviceBase  # This node gets replaced on start as per setup()
var _FEAGI_device_settings_holder: VBoxContainer

var _device_type: StringName = ""

func setup(device_type_name: StringName, device_index: int, initial_name: StringName, is_device_disabled: bool, specific_device_UI: FEAGI_UI_Panel_SpecificDeviceBase, 
configurator_JSON_template: Dictionary, specific_device_handler: FEAGI_IOHandler_Base = null, configurator_JSON_values: Dictionary = {}) -> void:
	# NOTE: The default value import is part of this function cause it is easier to mix that with the TemplateJSon Generator
	_type_header = $MarginContainer/VBoxContainer/titlebar/type
	_device_name_line = $MarginContainer/VBoxContainer/name/name
	_is_disabled_box = $MarginContainer/VBoxContainer/disabled/disabled
	_device_settings = $MarginContainer/VBoxContainer/DeviceSettings_TOBEREPLACED # This is a placeholder about to be replaced
	_FEAGI_device_settings_holder = $MarginContainer/VBoxContainer/FEAGISettings/PanelContainer/MarginContainer/Internals
	
	_device_settings.replace_by(specific_device_UI)
	_device_type = device_type_name
	set_device_name(initial_name)
	_is_disabled_box.button_pressed = is_device_disabled
	_device_settings.setup()


func set_title_label_index(index: int) -> void:
	_type_header.text = "%s %d" % [_device_type, index]

func set_device_name(set_name: StringName) -> void:
	_device_name_line.text = set_name

## TODO
func export_as_FEAGI_config_JSON_device_object() -> Dictionary:
	var output: Dictionary = {
		
	}
	
	
	return output
