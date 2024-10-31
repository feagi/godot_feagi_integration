@tool
extends Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
class_name FEAGI_UI_Panel_SpecificSensoryDevice_Gyro

## This function is called by the parent [FEAGI_UI_Panel_Device] node first, use this to init anything needed
func setup() -> void:
	pass

## Called by the parent [FEAGI_UI_Panel_Device] node IF it has a prior device config
func import_IOHandler(device_config: FEAGI_IOConnector_Base) -> void:
	var gyro_config: FEAGI_IOConnector_Sensor_Gyro = device_config as FEAGI_IOConnector_Sensor_Gyro
	if gyro_config == null:
		push_error("FEAGI: Unknown IOHandler sent to gyro device!")
		return


## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	var gyro_config: FEAGI_IOConnector_Sensor_Gyro = FEAGI_IOConnector_Sensor_Gyro.new()
	gyro_config.device_friendly_name = device_name
	gyro_config.FEAGI_index = FEAGI_index
	gyro_config.device_ID = device_ID
	gyro_config.is_disabled = is_disabled
	return gyro_config
