@tool
extends FEAGI_Debug_Panel_ViewBase
class_name FEAGI_Debug_Panel_View_Motor_MotionControl

var _text: TextEdit

func initialize() -> void:
	super()
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	_text.text = "Move Up: 0, Move Down: 0, Move Right: 0, Move Left: 0\nYaw Left: 0, Yaw Right: 0, Roll Left: 0, Roll Right: 0\nPitch Forward: 0, Pitch Backward: 0"
	
## OVERRIDDEN: camera needs the X resolution (val 0) and Y resolution (val 1)
func setup_extra_setup_data(_extra_settings: Array) -> void:
	pass
	
func update_visualization(data: PackedByteArray) -> void:
	var arr: PackedFloat32Array = data.to_float32_array()
	_text.text = "Move Up: %d, Move Down: %d, Move Right: %d, Move Left: %d\nYaw Left: %d, Yaw Right: %d, Roll Left: %d, Roll Right: %d\nPitch Forward: %d, Pitch Backward: %d" % Array(arr)
