@tool
extends Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
class_name FEAGI_UI_Panel_SpecificMotorDevice_MotionControl

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
	var motion_config: FEAGI_IOConnector_Motor_MotionControl = device_config as FEAGI_IOConnector_Motor_MotionControl
	if motion_config == null:
		push_error("FEAGI: Unknown IOHandler sent to Motion Control device!")
		return
	if motion_config.is_using_automatic_input_key_emulation():
		_emulation_settings.setup_given_existing_configs(motion_config.automatically_emulate_keys)
		_enable_emulate.button_pressed = true

## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	var motion_config: FEAGI_IOConnector_Motor_MotionControl = FEAGI_IOConnector_Motor_MotionControl.new()
	motion_config.device_friendly_name = device_name
	motion_config.FEAGI_index = FEAGI_index
	motion_config.device_ID = device_ID
	motion_config.is_disabled = is_disabled
	if _enable_emulate.button_pressed:
		motion_config.automatically_emulate_keys = _emulation_settings.export_as_dict()
	return motion_config
