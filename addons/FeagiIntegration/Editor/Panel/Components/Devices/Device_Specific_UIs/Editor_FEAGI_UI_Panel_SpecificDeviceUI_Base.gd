@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
## Responsible for handling the UI of device specific Godot Settings for various FEAGI devices

const PATH_EMUINPUT_UI: NodePath = "CollapsiblePrefab/PanelContainer/MarginContainer/Internals/Editor_FEAGI_UI_Panel_EmuInputConfigurations"

var _emuInput_UI: Editor_FEAGI_UI_Panel_EmuInputConfigurations = null # only exists for motor UIs

## This function is called by the parent [FEAGI_UI_Panel_Device] node first
func setup(device_config: FEAGI_IOConnector_Base) -> Error:
	if has_node(PATH_EMUINPUT_UI): ## If the scene contains a setup for input emulation, trigger setup
		_motor_setup_emuInput_UI(device_config)

	return Error.OK




## Called by the parent [FEAGI_UI_Panel_Device] node to get any additional data keys that need to be merged in to the configurator JSON. Most cases empty but some classes may override this
func export_additional_JSON_configurator_data() -> Dictionary:
	return {}
	
## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	assert(false, "Do not use Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base Directly!")
	return null

func _motor_setup_emuInput_UI(device_config: FEAGI_IOConnector_Base) -> Error:
	if not has_node(PATH_EMUINPUT_UI):
		push_error("Feagi Configurator: This Specific UI does not seem to have the input emulator configurator, is this a sensor?")
		return Error.ERR_UNAVAILABLE
	
	
	_emuInput_UI = $CollapsiblePrefab/PanelContainer/MarginContainer/Internals/Editor_FEAGI_UI_Panel_EmuInputConfigurations
	
	
	var error: Error = _emuInput_UI.setup_for_motor(device_config)
	return error
