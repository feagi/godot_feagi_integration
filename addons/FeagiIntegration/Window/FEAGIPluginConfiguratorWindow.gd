@tool
extends PanelContainer
class_name FEAGIPluginConfiguratorWindow

var _plugin_main_script: FEAGIPluginInit

var _status_summary: RichTextLabel


func _ready() -> void:
	_status_summary = $ScrollContainer/Options/DesContainer/Status
	tree_exited.connect(_user_closing_window)

func setup(plugin_main_script: FEAGIPluginInit) -> void:
	_plugin_main_script = plugin_main_script






## Called when the window is closing for any reason. Freeing of the resource is already handled by [FEAGIPluginInit]
func _user_closing_window() -> void:
	pass

## Sets the summary status top label to indicate if FEAGI is ready or not
func _set_status_summary(is_ready: bool) -> void:
	if is_ready:
		_status_summary.text = "Feagi Integration is [b]ready[/b]"
	else:
		_status_summary.text = "Feagi Integration is [b]not ready[/b]"
