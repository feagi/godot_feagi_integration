@tool
extends FEAGIDebugViewBase
class_name FEAGIDebuggerViewCamera

var _texture: TextureRect

func initialize() -> void:
	super()
	_texture = $Title/MarginContainer/VBoxContainer/MarginContainer/TextureRect

## Takes an [Image]
func update_visualization(data: Variant) -> void:
	if !(data is Image): # Funni gdscript formatting issue
		push_error("FEAGI: Camera Debug View did not recieve an Image! Ignoring!")
		return
	(_texture.texture as ImageTexture).set_image(data as Image)
