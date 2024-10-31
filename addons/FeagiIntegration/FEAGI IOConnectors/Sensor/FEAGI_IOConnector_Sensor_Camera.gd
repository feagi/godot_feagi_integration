@tool
extends FEAGI_IOConnector_Sensor_Base
class_name FEAGI_IOConnector_Sensor_Camera
## Camera FEAGI Device. Sensor that relays images from game to pass to FEAGI.
## NOTE: _function_to_grab_from_godot_with in this class is expected to return an [Image]

const TYPE_NAME = "camera"

@export var resolution: Vector2i = Vector2i(64,64)
@export var is_flipped_x: bool
@export var automatically_create_screengrabber: bool ## If set, the FEAGI runtime will automatically create a screengrabber for use with this

var _sensor_image: Image # a cached empty image for when no Registration Agent is registered
var _blank_image: Image # a cached empty image for when no Registration Agent is registered

func _init() -> void:
	_blank_image = Image.create_empty(resolution.x, resolution.y, false, Image.FORMAT_RGB8)

func get_device_type() -> StringName:
	return TYPE_NAME

## OVERRIDDEN - cameras need to report their resolution such that the packed data array can be properly applied
func get_debug_interface_device_creation_array() -> Array:
	return [get_device_type(), device_friendly_name, resolution.x, resolution.y]
	# str device type, str name of device, int x resolution, int y resolution]

## Processes the input images returns the byte array data of it
func _process_sensor_input_for_cache_using_callable() -> void:
	_sensor_image = _function_to_grab_from_godot_with.call()
	_sensor_image.resize(resolution.x, resolution.y)
	_sensor_image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		_sensor_image.flip_x()
	_cached_bytes = _sensor_image.get_data()

## In the case of no user defined callable (due to a lack of device registration. This call will be called instead. Usually returning the previous data is fine, but some child classes may override this
func _fallback_sensory_update_when_no_callable() -> void:
	_cached_bytes = _blank_image.get_data()
