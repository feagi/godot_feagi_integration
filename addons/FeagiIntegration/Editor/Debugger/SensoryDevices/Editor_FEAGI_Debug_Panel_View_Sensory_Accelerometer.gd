@tool
extends Editor_FEAGI_Debug_Panel_ViewBase
class_name Editor_FEAGI_Debug_Panel_View_Sensory_Accelerometer

var _text: TextEdit

func initialize() -> void:
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	super()
	
func update_visualization(data: PackedByteArray) -> void:
	if len(data) != 12:
		return # data out of order, we recived something incorrect
	var arr: PackedFloat32Array = data.to_float32_array()
	_text.text = "X: %.2f, Y: %.2f, Z: %.2f" % [arr[0], arr[1], arr[2]] # Yes this is stupid, but godot gets pissy if I pass the PackedFloat32Array directly
