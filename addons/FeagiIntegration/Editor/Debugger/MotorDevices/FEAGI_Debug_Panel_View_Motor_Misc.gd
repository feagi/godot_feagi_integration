@tool
extends FEAGI_Debug_Panel_ViewBase
class_name FEAGI_Debug_Panel_View_Motor_Misc

var _text: TextEdit

func initialize() -> void:
	super()
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	
func update_visualization(data: PackedByteArray) -> void:
	_text.text = "Misc Value: %.2f" % data.decode_float(0)