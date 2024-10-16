@tool
extends Editor_FEAGI_Debug_Panel_ViewBase
class_name Editor_FEAGI_Debug_Panel_View_Sensory_Proximity

var _text: TextEdit

func initialize() -> void:
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	super()
	
func update_visualization(data: PackedByteArray) -> void:
	if len(data) != 4:
		return # data out of order, we recived something incorrect
	_text.text = "Distance: %.2f" % data.decode_float(0)
