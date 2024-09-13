@tool
extends FEAGI_Debug_Panel_ViewBase
class_name FEAGI_Debug_Panel_View_Motor_MotionControl

var _vec4: LineEdit
var _vec2: LineEdit

func initialize() -> void:
	super()
	_vec4 = $Title/MarginContainer/VBoxContainer/holder/HBoxContainer/vec4
	_vec2 = $Title/MarginContainer/VBoxContainer/holder/HBoxContainer/vec2
	_parse(0.0, 0.0, 0.0, 0.0)
	
## OVERRIDDEN: camera needs the X resolution (val 0) and Y resolution (val 1)
func setup_extra_setup_data(_extra_settings: Array) -> void:
	pass
	
func update_visualization(data: PackedByteArray) -> void:
	var arr: PackedFloat32Array = data.to_float32_array()
	_parse(arr[0], arr[1], arr[2], arr[3])

func _parse(forward: float, backward: float, right: float, left: float) -> void:
	_vec4.text = "Forward: %d   Backward: %d   Right: %d   Left: %d" % [forward, backward, right, left]
	_vec2.text = "X: %d, Y: %d" % [right - left, forward - backward]
