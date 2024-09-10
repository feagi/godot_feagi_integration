@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Camera
## Base camera class, as this may be used for both screencapture cameras and 3D camera, depending on the grabber function
## NOTE: _data_grabber in this class is expected to return an [Image]

@export var resolution: Vector2i = Vector2i(64,64)
@export var is_flipped_x: bool
@export var automatically_create_screengrabber: bool ## If set, the FEAGI runtime will automatically create a screengrabber for use with this

var _blank_image: Image # a cached empty 
var _data_for_blank_image: PackedByteArray = [] # a cached copy of the raw data representing a blank camera feed

func _init() -> void:
	_blank_image = Image.new()
	_blank_image.create_empty(resolution.x, resolution.y, false, Image.FORMAT_RGB8)
	_data_for_blank_image = _blank_image.get_data()

## If there is a data grabber function, get the image from it and process it before outputting the data from it. Otherwise returns a cached copy of an empty image
func get_data_as_byte_array() -> PackedByteArray:
	if _data_grabber.is_null():
		return _data_for_blank_image
	return _process_image(_data_grabber.call())

func get_device_type() -> StringName:
	return "camera"

## OVERRIDDEN - cameras need to report their resolution such that the packed data array can be properly applied
func get_debug_interface_device_creation_array() -> Array:
	return [false, get_device_type(), device_name, resolution.x, resolution.y]
	# [bool is motor, str device type, str name of device, int x resolution, int y resolution]

## Processes the input images returns the byte array data of it
func _process_image(image: Image) -> PackedByteArray:
	image.resize(resolution.x, resolution.y)
	image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		image.flip_x()
	return image.get_data()
