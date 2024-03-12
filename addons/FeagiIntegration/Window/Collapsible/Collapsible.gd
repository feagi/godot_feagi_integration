extends VBoxContainer
class_name FEAGIWindowCollapsible

var _show: Button
var _hide: Button

func _ready():
	_show = $Show
	_hide = $Hide

## Show / Hide the internals of this control
func toggle_visibility(show_internals: bool) -> void:
	for child: Control in get_children():
		child.visible = show_internals
	_show.visible = !show_internals
	_hide.visible = show_internals
