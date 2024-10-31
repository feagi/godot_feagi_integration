@tool
extends Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
class_name FEAGI_UI_Panel_SpecificMotorDevice_Misc

var _enable_emulate: CheckBox
var _emulate_note: RichTextLabel
var _section_emulation_config: FEAGI_UI_Prefab_Collapsible
var _emulation_settings: FEAGI_UI_Panel_ActionPresserConfigSet

## This function is called by the parent [FEAGI_UI_Panel_Device] node first, use this to init anything needed
func setup() -> void:
	_enable_emulate = $keyboard/emulate
	_emulate_note = $keyboardnote
	_section_emulation_config = $CollapsiblePrefab
	_emulation_settings = $CollapsiblePrefab/PanelContainer/MarginContainer/Internals/FeagiUiPanelActionPresserConfigSet
	_emulation_settings.setup_from_export_vars()


## Called by the parent [FEAGI_UI_Panel_Device] node IF it has a prior device config
func import_IOHandler(device_config: FEAGI_IOConnector_Base) -> void:
	var motor_config: FEAGI_IOConnector_Motor_Misc = device_config as FEAGI_IOConnector_Motor_Misc
	if motor_config == null:
		push_error("FEAGI: Unknown IOHandler sent to Motor device!")
		return
	
	if motor_config.is_using_automatic_input_key_emulation():
		_emulation_settings.setup_given_existing_configs(motor_config.automatically_emulate_keys)
		_enable_emulate.button_pressed = true

## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	var motor_config: FEAGI_IOConnector_Motor_Misc = FEAGI_IOConnector_Motor_Misc.new()
	motor_config.device_friendly_name = device_name
	motor_config.FEAGI_index = FEAGI_index
	motor_config.device_ID = device_ID
	motor_config.is_disabled = is_disabled
	if _enable_emulate.button_pressed:
		motor_config.automatically_emulate_keys = _emulation_settings.export_as_dict()
	return motor_config
