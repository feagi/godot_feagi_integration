@tool
extends FEAGI_Debug_Panel_ViewBase
class_name FEAGI_Debug_Panel_View_Sensory_Gyro

var _text: TextEdit

func initialize() -> void:
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	super()
	
func update_visualization(data: PackedByteArray) -> void:
	_text.text = "X: %d, Y: %d, Z: %d" % data.to_float32_array()
