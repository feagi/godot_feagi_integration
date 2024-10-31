@tool
extends Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
class_name FEAGI_UI_Panel_SpecificSensoryDevice_Proximity

## This function is called by the parent [FEAGI_UI_Panel_Device] node first, use this to init anything needed
func setup() -> void:
	pass

## Called by the parent [FEAGI_UI_Panel_Device] node IF it has a prior device config
func import_IOHandler(device_config: FEAGI_IOConnector_Base) -> void:
	var proximity_config: FEAGI_IOConnector_Sensor_Proximity = device_config as FEAGI_IOConnector_Sensor_Proximity
	if proximity_config == null:
		push_error("FEAGI: Unknown IOHandler sent to accelerometer device!")
		return


## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	var proximity_config: FEAGI_IOConnector_Sensor_Proximity = FEAGI_IOConnector_Sensor_Proximity.new()
	proximity_config.device_friendly_name = device_name
	proximity_config.FEAGI_index = FEAGI_index
	proximity_config.device_ID = device_ID
	proximity_config.is_disabled = is_disabled
	return proximity_config
