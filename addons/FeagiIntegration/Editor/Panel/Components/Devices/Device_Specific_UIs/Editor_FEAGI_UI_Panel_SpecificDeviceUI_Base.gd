@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
## Responsible for handling the UI of device specific Godot Settings for various FEAGI devices

## This function is called by the parent [FEAGI_UI_Panel_Device] node first, use this to init anything needed
func setup() -> void:
	assert(false, "Do not use Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base Directly!")

## Called by the parent [FEAGI_UI_Panel_Device] node IF it has a prior device config
func import_IOHandler(device_config: FEAGI_IOConnector_Base) -> void:
	assert(false, "Do not use Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base Directly!")

## Called by the parent [FEAGI_UI_Panel_Device] node to get any additional data keys that need to be merged in to the configurator JSON. Most cases empty but some classes may override this
func export_additional_JSON_configurator_data() -> Dictionary:
	return {}
	
## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	assert(false, "Do not use Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base Directly!")
	return null
