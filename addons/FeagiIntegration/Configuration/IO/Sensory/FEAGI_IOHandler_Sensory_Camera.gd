@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Camera
## Camera IOHandler. Sensor that captures images from game to pass to FEAGI
## NOTE: _data_grabber in this class is expected to return an [Image]

const TYPE_NAME = "camera"

@export var resolution: Vector2i = Vector2i(64,64)
@export var is_flipped_x: bool
@export var automatically_create_screengrabber: bool ## If set, the FEAGI runtime will automatically create a screengrabber for use with this

var _blank_image: Image # a cached empty image for when no Godot Device is registered

func _init() -> void:
	_blank_image = Image.new()
	_blank_image.create_empty(resolution.x, resolution.y, false, Image.FORMAT_RGB8)

func get_device_type() -> StringName:
	return TYPE_NAME

## OVERRIDDEN - cameras need to report their resolution such that the packed data array can be properly applied
func get_debug_interface_device_creation_array() -> Array:
	return [get_device_type(), device_name, resolution.x, resolution.y]
	# str device type, str name of device, int x resolution, int y resolution]

## If there is a data grabber function, get the image from it and process it before outputting the data from it. Otherwise updates the cached data with an empty image
func refresh_cached_sensory_data() -> void:
	if _data_grabber.is_null():
		_cached_data = _blank_image.get_data()
		return
	_cached_data = _process_image(_data_grabber.call())

## Processes the input images returns the byte array data of it
func _process_image(image: Image) -> PackedByteArray:
	image.resize(resolution.x, resolution.y)
	image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		image.flip_x()
	return image.get_data()
