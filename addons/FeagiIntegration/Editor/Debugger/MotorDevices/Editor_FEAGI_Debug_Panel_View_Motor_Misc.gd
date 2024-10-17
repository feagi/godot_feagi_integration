@tool
extends Editor_FEAGI_Debug_Panel_ViewBase
class_name Editor_FEAGI_Debug_Panel_View_Motor_Misc

var _text: TextEdit

func initialize() -> void:
	super()
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	
func update_visualization(data: PackedByteArray) -> void:
	if len(data) != 4:
		return # data out of order, we recived something incorrect
	_text.text = "Misc Value: %.2f" % data.decode_float(0)
