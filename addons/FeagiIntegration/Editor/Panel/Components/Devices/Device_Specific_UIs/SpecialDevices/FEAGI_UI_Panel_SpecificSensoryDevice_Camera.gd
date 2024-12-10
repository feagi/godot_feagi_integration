@tool
extends Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
class_name FEAGI_UI_Panel_SpecificSensoryDevice_Camera
## Camera has some additional properties that are proccessed here

var _x: SpinBox
var _y: SpinBox
var _flipped: CheckBox
var _screengrab: CheckBox
var _screengrab_note: RichTextLabel

## This function is called by the parent [FEAGI_UI_Panel_Device] node first, use this to init anything needed
func setup(device_config: FEAGI_IOConnector_Base, generate_motor_emuInput_UI: bool) -> Error:
	_x = $res/x
	_y = $res/y
	_flipped = $flipped/flipped
	_screengrab = $screengrabber/screengrab
	_screengrab_note = $screengrabnote
	return Error.OK


## OVERRIDDEN since we also need the resolution for the json
func export_additional_JSON_configurator_data() -> Dictionary:
	return {"camera_resolution" = [_x.value, _y.value]}


## OVERRIDDEN as camera has some additional data
func export_additional_IOHandler_data(device: FEAGI_IOConnector_Base) -> FEAGI_IOConnector_Base:
	var camera_config: FEAGI_IOConnector_Sensor_Camera = device as FEAGI_IOConnector_Sensor_Camera
	camera_config.resolution = Vector2i(_x.value, _y.value)
	camera_config.is_flipped_x = _flipped.button_pressed
	camera_config.automatically_create_screengrabber = _screengrab.button_pressed
	return camera_config


## Some specific devices may have additional UI needed to configure per device. Those devices can have logic for such behavior here in child classes
func _setup_additional_configuration(device_config: FEAGI_IOConnector_Base) -> void:
	var camera_config: FEAGI_IOConnector_Sensor_Camera = device_config as FEAGI_IOConnector_Sensor_Camera
	if camera_config == null:
		push_error("FEAGI: Unknown IOHandler sent to camera device!")
		return
	
	_x.value = camera_config.resolution.x
	_y.value = camera_config.resolution.y
	_flipped.button_pressed = camera_config.is_flipped_x
	_screengrab.button_pressed = camera_config.automatically_create_screengrabber
	_screengrab_note.visible = camera_config.automatically_create_screengrabber
