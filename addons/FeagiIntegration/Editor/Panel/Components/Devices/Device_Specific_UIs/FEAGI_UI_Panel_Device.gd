@tool
extends PanelContainer
class_name FEAGI_UI_Panel_Device

signal confirm_name_change(requesting_new_name: StringName, self_ref: FEAGI_UI_Panel_Device)
signal request_deletion(self_ref: FEAGI_UI_Panel_Device)

var device_type: StringName:
	get: return _device_type

var device_friendly_name: StringName:
	get: return _device_friendly_name

var is_disabled: bool:
	get:
		if _is_disabled_box:
			return _is_disabled_box.button_pressed
		return false

var feagi_index: int:
	get: 
		if _FEAGI_index_spin:
			return _FEAGI_index_spin.value
		return -1

var _type_header: Label
var _device_name_line: LineEdit
var _is_disabled_box: CheckBox
var _FEAGI_index_spin: SpinBox
var _device_settings: FEAGI_UI_Panel_SpecificDeviceUI_Base  # This node gets replaced on start as per setup()
var _FEAGI_settings: FEAGI_UI_Prefab_Collapsible
var _FEAGI_device_settings_holder: FEAGI_UI_Panel_Device_ParameterManager
var _device_index: int
var _device_friendly_name: StringName

var _device_type: StringName = ""

func setup(device_type_name: StringName, device_index: int, initial_name: StringName, is_device_disabled: bool, specific_device_UI: FEAGI_UI_Panel_SpecificDeviceUI_Base, 
configurator_JSON_template_for_this_device: Dictionary, specific_device_handler: FEAGI_IOHandler_Base = null, configurator_JSON_values: Dictionary = {}) -> void:
	# NOTE: The default value import is part of this function cause it is easier to mix that with the TemplateJSon Generator
	# configurator_JSON_template_for_this_device refers to the dictionary  that is the value corresponding to {"input/output" : {"device_name" : (this dict)}}
	_type_header = $MarginContainer/VBoxContainer/titlebar/type
	_device_name_line = $MarginContainer/VBoxContainer/name/name
	_is_disabled_box = $MarginContainer/VBoxContainer/disabled/disabled
	_FEAGI_index_spin = $MarginContainer/VBoxContainer/feagi_index/index
	_device_settings = $MarginContainer/VBoxContainer/DeviceSettings_TOBEREPLACED # This is a placeholder about to be replaced
	_FEAGI_device_settings_holder = $MarginContainer/VBoxContainer/FEAGISettings/PanelContainer/MarginContainer/Internals
	_FEAGI_settings = $MarginContainer/VBoxContainer/FEAGISettings
	
	_device_settings.replace_by(specific_device_UI)
	_device_settings = specific_device_UI
	_device_type = device_type_name
	set_device_name(initial_name)
	_is_disabled_box.button_pressed = is_device_disabled
	_device_index = device_index
	
	set_title_label_index(_device_index)
	_device_settings.setup()
	
	var parameters_JSON_for_this_device: Array[Dictionary]
	parameters_JSON_for_this_device.assign(configurator_JSON_template_for_this_device["parameters"])
	_FEAGI_device_settings_holder.setup(parameters_JSON_for_this_device, configurator_JSON_values)
	if _FEAGI_device_settings_holder.get_child_count() == 0:
		_FEAGI_settings.visible = false # no point showing the section if theres nothing in it!


func set_title_label_index(index: int) -> void:
	_device_index = index
	_type_header.text = "%s %d" % [_device_type, index]

func set_device_name(set_name: StringName) -> void:
	_device_friendly_name = set_name
	_device_name_line.text = set_name

## Returns the dict of the device index as a string, that then contains the details of that device
func export_as_FEAGI_config_JSON_device_object() -> Dictionary:
	var inside: Dictionary = {
		"custom_name": device_friendly_name,
		"disabled": is_disabled,
		"feagi_index": feagi_index
	}
	inside.merge(_FEAGI_device_settings_holder.export_as_dict())
	return {str(_device_index): inside }
	

func export_as_FEAGI_IOHandler() -> FEAGI_IOHandler_Base:
	return _device_settings.export_IOHandler(_device_friendly_name, _device_index, 0, is_disabled) # TODO what is going onm with device index / device ID?


## When the name lineedit loses focus, check if the text in it cheanged. If it did, send a signal to confirm if the name should be changed or not
func _check_name_change() -> void:
	if _device_name_line.text != _device_friendly_name:
		confirm_name_change.emit(_device_name_line.text, self)

func _request_deletion() -> void:
	request_deletion.emit(self)
