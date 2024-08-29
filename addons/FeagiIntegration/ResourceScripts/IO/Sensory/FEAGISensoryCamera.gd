@tool
extends FEAGISensoryBase
class_name FEAGISensoryCamera
## Base camera class, as this may be used for both screencapture cameras and 3D camera, depending on the grabber function
## NOTE: _data_grabber in this class is expected to return an [Image]

@export var export_res_x: int = 64
@export var export_res_y: int = 64
@export var is_flipped_x: bool
@export var is_screen_grabber: bool
@export var blank_camera_color: Color = Color.BLACK

var _data_for_blank_image: PackedByteArray = [] # a cached copy of the raw data representing a blank camera feed

func _init() -> void:
	var blank_image: Image = Image.new()
	blank_image.resize(export_res_x, export_res_y)
	blank_image.fill(blank_camera_color)
	blank_image.convert(Image.FORMAT_RGB8)
	_data_for_blank_image = blank_image.get_data()

func post_initialize_required_dependencies() -> void:
	#NOTE: Due to how Godot handles [Image], I have currently decided not to attempt any additional caching as it already passes around by reference anyways
	pass
	
func get_data_as_byte_array() -> PackedByteArray:
	if _data_grabber.is_null():
		return _data_for_blank_image
	return _process_image(_data_grabber.call()).get_data()

func _process_image(image: Image) -> Image:
	image.resize(export_res_x, export_res_y)
	image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		image.flip_x()
	return image
