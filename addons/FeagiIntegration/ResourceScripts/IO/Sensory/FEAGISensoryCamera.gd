@tool
extends FEAGISensoryBase
class_name FEAGISensoryCamera
## Base camera class, as this may be used for both screencapture cameras and 3D camera, depending on the grabber function
## NOTE: _data_grabber in this class is expected to return an [Image]

@export var export_res_x: int = 64
@export var export_res_y: int = 64
@export var is_flipped_x: bool
@export var automatically_create_screengrabber: bool ## If set, the FEAGI runtime will automatically create a screengrabber for use with this
@export var blank_camera_color: Color = Color.BLACK

var _cached_image: Image
var _blank_image: Image
var _data_for_blank_image: PackedByteArray = [] # a cached copy of the raw data representing a blank camera feed

func _init() -> void:
	_blank_image = Image.new()
	_blank_image.set_data(export_res_x, export_res_y, false, Image.FORMAT_RGB8, _generate_blank_black_image_data())
	_blank_image.fill(blank_camera_color)
	_data_for_blank_image = _blank_image.get_data()
	
func get_data_as_byte_array() -> PackedByteArray:
	if _data_grabber.is_null():
		return _data_for_blank_image
	
	_cached_image = _process_image(_data_grabber.call())
	return _cached_image.get_data()

func _process_image(image: Image) -> Image:
	image.resize(export_res_x, export_res_y)
	image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		image.flip_x()
	return image

func _generate_blank_black_image_data() -> PackedByteArray:
	var length: int = export_res_x * export_res_y * 3
	var output: PackedByteArray = []
	output.resize(length)
	return output
	
