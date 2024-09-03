@tool
extends FEAGIDebugViewBase
class_name FEAGIDebuggerViewCamera

const PREVIEW_SIZE: Vector2i = Vector2i(256, 256)

var _texture: TextureRect

func initialize() -> void:
	super()
	_texture = $Title/MarginContainer/VBoxContainer/holder/TextureRect
	var initial_texture: ImageTexture = ImageTexture.create_from_image(Image.create_empty(PREVIEW_SIZE.x,PREVIEW_SIZE.y,false,Image.FORMAT_RGB8))
	_texture.texture = initial_texture

## Takes an [Image]
func update_visualization(data: Variant) -> void:
	if !(data is Image): # Funni gdscript formatting issue
		push_error("FEAGI: Camera Debug View did not recieve an Image! Ignoring!")
		return
	(data as Image).resize(PREVIEW_SIZE.x, PREVIEW_SIZE.y)
	(_texture.texture as ImageTexture).set_image((data as Image))

func _generate_blank_black_image_data(x_size: int, y_size: int) -> PackedByteArray:
	var length: int = x_size * y_size * 3
	var output: PackedByteArray = []
	output.resize(length)
	return output
