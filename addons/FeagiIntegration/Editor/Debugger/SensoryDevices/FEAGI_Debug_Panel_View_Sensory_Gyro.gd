@tool
extends FEAGI_Debug_Panel_ViewBase
class_name FEAGI_Debug_Panel_View_Sensory_Gyro

var _text: TextEdit

func initialize() -> void:
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	super()
	
func update_visualization(data: PackedByteArray) -> void:
	var arr: PackedFloat32Array = data.to_float32_array()
	_text.text = "X: %d, Y: %d, Z: %d" % [arr[0], arr[1], arr[2]] # Yes this is stupid, but godot gets pissy if I pass the PackedFloat32Array directly
