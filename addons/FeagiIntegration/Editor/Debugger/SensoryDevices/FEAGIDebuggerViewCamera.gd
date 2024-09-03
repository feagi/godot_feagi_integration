@tool
extends FEAGIDebugViewBase
class_name FEAGIDebuggerViewCamera

const PREVIEW_SIZE: Vector2i = Vector2i(256, 256)

var _texture: TextureRect
var _parsed_image: Image

func initialize() -> void:
	super()
	_texture = $Title/MarginContainer/VBoxContainer/holder/TextureRect
	var initial_texture: ImageTexture = ImageTexture.create_from_image(Image.create_empty(PREVIEW_SIZE.x,PREVIEW_SIZE.y,false,Image.FORMAT_RGB8))
	_texture.texture = initial_texture

## Takes an [Image] but within an [EncodedObjectAsID]
func update_visualization(data: Variant) -> void:
	print("DEBUG EDITOR: Recieved object" + str(instance_from_id(data.object_id)) + " with ID " + str(data.object_id))
	return
	var parsed_image: Image = instance_from_id(data.object_id)

	parsed_image.resize(PREVIEW_SIZE.x, PREVIEW_SIZE.y)
	(_texture.texture as ImageTexture).set_image(parsed_image)

func _generate_blank_black_image_data(x_size: int, y_size: int) -> PackedByteArray:
	var length: int = x_size * y_size * 3
	var output: PackedByteArray = []
	output.resize(length)
	return output
