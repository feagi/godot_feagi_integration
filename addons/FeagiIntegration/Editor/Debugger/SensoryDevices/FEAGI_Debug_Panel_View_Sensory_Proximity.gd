@tool
extends FEAGI_Debug_Panel_ViewBase
class_name FEAGI_Debug_Panel_View_Sensory_Proximity

var _text: TextEdit

func initialize() -> void:
	_text = $Title/MarginContainer/VBoxContainer/holder/TextEdit
	super()
	
func update_visualization(data: PackedByteArray) -> void:
	_text.text = "Distance: %d" % data.decode_float(0)
