@tool
extends Editor_FEAGI_Debug_Panel_ViewBase
class_name Editor_FEAGI_Debug_Panel_View_Sensory_Camera


var _texture: TextureRect
var _parsed_image: Image
var _image_resolution: Vector2i = Vector2i(64,64)

func initialize() -> void:
	_texture = $Title/MarginContainer/VBoxContainer/holder/TextureRect
	super()
	

## OVERRIDDEN: camera needs the X resolution (val 0) and Y resolution (val 1)
func setup_extra_setup_data(extra_settings: Array) -> void:
	if len(extra_settings) != 2:
		push_error("FEAGI Debugger: Camera element was not supplied resolution information properly!")
		return
	if extra_settings[0] is not int or extra_settings[1] is not int:
		push_error("FEAGI Debugger: Camera element was not supplied resolution information properly!")
		return
	_image_resolution = Vector2i(extra_settings[0], extra_settings[1])
	_parsed_image = Image.create_empty(_image_resolution.x,_image_resolution.y,false,Image.FORMAT_RGB8)
	var initial_texture: ImageTexture = ImageTexture.create_from_image(_parsed_image)
	_texture.texture = initial_texture
	
func update_visualization(data: PackedByteArray) -> void:
	if len(data) != _image_resolution.x * _image_resolution.y * 3:
		return # data out of order, we recived something incorrect
	_parsed_image = Image.create_from_data(_image_resolution.x, _image_resolution.y, false, Image.FORMAT_RGB8, data)
	(_texture.texture as ImageTexture).set_image(_parsed_image)
