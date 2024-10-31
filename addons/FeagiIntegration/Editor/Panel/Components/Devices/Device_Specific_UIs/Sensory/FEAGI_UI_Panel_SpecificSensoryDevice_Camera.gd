@tool
extends Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
class_name FEAGI_UI_Panel_SpecificSensoryDevice_Camera

var _x: SpinBox
var _y: SpinBox
var _flipped: CheckBox
var _screengrab: CheckBox
var _screengrab_note: RichTextLabel

## This function is called by the parent [FEAGI_UI_Panel_Device] node first, use this to init anything needed
func setup() -> void:
	_x = $res/x
	_y = $res/y
	_flipped = $flipped/flipped
	_screengrab = $screengrabber/screengrab
	_screengrab_note = $screengrabnote

## Called by the parent [FEAGI_UI_Panel_Device] node IF it has a prior device config
func import_IOHandler(device_config: FEAGI_IOConnector_Base) -> void:
	var camera_config: FEAGI_IOConnector_Sensor_Camera = device_config as FEAGI_IOConnector_Sensor_Camera
	if camera_config == null:
		push_error("FEAGI: Unknown IOHandler sent to camera device!")
		return
	
	_x.value = camera_config.resolution.x
	_y.value = camera_config.resolution.y
	_flipped.button_pressed = camera_config.is_flipped_x
	_screengrab.button_pressed = camera_config.automatically_create_screengrabber
	_screengrab_note.visible = camera_config.automatically_create_screengrabber

## OVERRIDDEN since we also need the resolution for the json
func export_additional_JSON_configurator_data() -> Dictionary:
	return {"camera_resolution" = [_x.value, _y.value]}

## Called by the parent [FEAGI_UI_Panel_Device] node when it needs to build the device settings to export a save file
func export_IOHandler(device_name: StringName, FEAGI_index: int, device_ID: int, is_disabled: bool) -> FEAGI_IOConnector_Base:
	var camera_config: FEAGI_IOConnector_Sensor_Camera = FEAGI_IOConnector_Sensor_Camera.new()
	camera_config.device_friendly_name = device_name
	camera_config.FEAGI_index = FEAGI_index
	camera_config.device_ID = device_ID
	camera_config.is_disabled = is_disabled
	camera_config.resolution = Vector2i(_x.value, _y.value)
	camera_config.is_flipped_x = _flipped.button_pressed
	camera_config.automatically_create_screengrabber = _screengrab.button_pressed
	return camera_config
