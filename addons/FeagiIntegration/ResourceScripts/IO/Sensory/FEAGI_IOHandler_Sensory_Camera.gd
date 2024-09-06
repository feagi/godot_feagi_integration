@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Camera
## Base camera class, as this may be used for both screencapture cameras and 3D camera, depending on the grabber function
## NOTE: _data_grabber in this class is expected to return an [Image]

@export var resolution: Vector2i = Vector2i(64,64)
@export var is_flipped_x: bool
@export var automatically_create_screengrabber: bool ## If set, the FEAGI runtime will automatically create a screengrabber for use with this
@export var blank_camera_color: Color = Color.BLACK

var _cached_image: Image
var _blank_image: Image
var _data_for_blank_image: PackedByteArray = [] # a cached copy of the raw data representing a blank camera feed

func _init() -> void: #TODO change this, we dont want this init to run on its own, we need to control it. However the setup base may not be good for this either
	_blank_image = Image.new()
	_blank_image.set_data(resolution.x, resolution.y, false, Image.FORMAT_RGB8, _generate_blank_black_image_data())
	_blank_image.fill(blank_camera_color)
	_data_for_blank_image = _blank_image.get_data()
	_cached_image =Image.new()
	_cached_image.copy_from(_blank_image)
	
func get_data_as_byte_array() -> PackedByteArray:
	if _data_grabber.is_null():
		_cached_image.copy_from(_blank_image)
		return _data_for_blank_image
	_process_image(_data_grabber.call())
	return _cached_image.get_data()

func get_device_type() -> StringName:
	return "camera"

func get_debug_data() -> Variant:
	return get_data_as_byte_array() #TODO REMOVE ME WONCE FEAGI ADDED
	return _cached_image # Since we just processed this for sending to FEAGI, might as well reuse the image

## Processes the input images and writes over the _cached image with it.
#WARNING: This is important since we cannot have the memory reference of _blank_image changing!
func _process_image(image: Image) -> void:
	image.resize(resolution.x, resolution.y)
	image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		image.flip_x()
	_cached_image.copy_from(image)

func _generate_blank_black_image_data() -> PackedByteArray:
	var length: int = resolution.x * resolution.y * 3
	var output: PackedByteArray = []
	output.resize(length)
	return output
	
