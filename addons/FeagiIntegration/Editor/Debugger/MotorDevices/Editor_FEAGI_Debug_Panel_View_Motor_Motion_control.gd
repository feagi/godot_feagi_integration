@tool
extends Editor_FEAGI_Debug_Panel_ViewBase
class_name Editor_FEAGI_Debug_Panel_View_Motor_MotionControl

var _text: TextEdit

func initialize() -> void:
	super()
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	_text.text = "Move Up: 0, Move Down: 0, Move Left: 0, Move Right: 0\nYaw Left: 0, Yaw Right: 0, Roll Left: 0, Roll Right: 0\nPitch Forward: 0, Pitch Backward: 0"
	
	
func update_visualization(data: PackedByteArray) -> void:
	if len(data) != 40:
		return # data out of order, we recived something incorrect
	var arr: PackedFloat32Array = data.to_float32_array()
	_text.text = "Move Up: %.2f, Move Down: %.2f, Move Left: %.2f, Move Right: %.2f\nYaw Left: %.2f, Yaw Right: %.2f, Roll Left: %.2ff, Roll Right: %.2f\nPitch Forward: %.2f, Pitch Backward: %.2f" % [arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9]] # Yes this is stupid, but godot gets pissy if I pass the PackedFloat32Array directly
