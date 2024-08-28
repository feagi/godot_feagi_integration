@tool
extends FEAGISensoryBase
class_name FEAGISensoryCamera
## Base camera class, as this may be used for both screencapture cameras and 3D camera, depending on the grabber function

@export var export_res_x: int = 64
@export var export_res_y: int = 64
@export var is_flipped_x: bool
@export var is_screen_grabber: bool
@export var blank_camera_color: Color = Color.BLACK

var _image_grabber: Callable = Callable() # the function that returns the initial image to send
var _data_for_blank_image: PackedByteArray = [] # a cached copy of the raw data representing a blank camera feed

func _init() -> void:
	var blank_image: Image = Image.new()
	blank_image.resize(export_res_x, export_res_y)
	blank_image.fill(blank_camera_color)
	blank_image.convert(Image.FORMAT_RGB8)
	_data_for_blank_image = blank_image.get_data()

## Have a camera register itself by providing a function that returns an [Image]
func register_camera(imaging_grabber_function: Callable) -> void:
	if !_image_grabber.is_null():
		push_warning("FEAGI: A camera entitiy attempted to register itself to FEAGISensoryCamera %s when it was already registered to a camera! Overwriting the registration!" % device_name)
	_image_grabber = imaging_grabber_function

## Have a camera deregister itself
func deregister_camera() -> void:
	if _image_grabber.is_null():
		push_warning("FEAGI: A call to deregister FEAGISensoryCamera %s was made when it had nothing registered anyways! Skipping!" % device_name)
		return
	_image_grabber = Callable()

func post_initialize_required_dependencies() -> void:
	#NOTE: Due to how Godot handles [Image], I have currently decided not to attempt any additional caching as it already passes around by reference anyways
	pass
	
func get_data_as_byte_array() -> PackedByteArray:
	if _image_grabber.is_null():
		return _data_for_blank_image
	return _process_image(_image_grabber.call()).get_data()

func _process_image(image: Image) -> Image:
	image.resize(export_res_x, export_res_y)
	image.convert(Image.FORMAT_RGB8)
	if is_flipped_x:
		image.flip_x()
	return image
