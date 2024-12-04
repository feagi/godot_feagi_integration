@tool
extends Editor_FEAGI_Debug_Panel_ViewBase
class_name Editor_FEAGI_Debug_Panel_View_Motor_MotionControl

var _text: TextEdit

func initialize() -> void:
	super()
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	_text.text = "Yaw Left: 0, Pitch Forward: 0, Pitch Backward: 0, Yaw Right: 0\nRoll Left: 0, Move Forward: 0, Move Backward: 0, Roll Right: 0\nMove Left: 0, Move Up: 0, Move Down: 0, Move Right: 0"
	
	
func update_visualization(data: PackedByteArray) -> void:
	if len(data) != 40:
		return # data out of order, we recived something incorrect
	var arr: PackedFloat32Array = data.to_float32_array()
	_text.text = "Yaw Left: %.2f, Pitch Forward: %.2f, Pitch Backward: %.2f, Yaw Right: %.2f\nRoll Left: %.2f, Move Forward: %.2f, Move Backward: %.2ff, Roll Right: %.2f\nMove Left: %.2f, Move Up: %.2f, Move Down: %.2f, Move Right: %.2f" % [arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9], arr[10], arr[11]] # Yes this is stupid, but godot gets pissy if I pass the PackedFloat32Array directly
