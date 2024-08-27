extends FEAGISensoryBase
class_name FEAGISensoryCamera
## Base camera class, as this may be used for both screencapture cameras and 3D camera, depending on the grabber function

@export var export_res_x: int = 64
@export var export_res_y: int = 64
@export var flipped_x: bool

var _image_grabber: Callable # the function that returns the initial image to send

func setup_camera(imaging_grabber_function: Callable) -> void:
	_image_grabber = imaging_grabber_function

func post_initialize_required_dependencies() -> void:
	#NOTE: Due to how Godot handles [Image], I have currently decided not to attempt any additional caching as it already passes around by reference anyways
	pass
	
func get_data_as_byte_array() -> PackedByteArray:
	return _process_image(_image_grabber.call()).get_data()

func _process_image(image: Image) -> Image:
	image.resize(export_res_x, export_res_y)
	image.convert(Image.FORMAT_RGB8)
	if flipped_x:
		image.flip_x()
	return image
