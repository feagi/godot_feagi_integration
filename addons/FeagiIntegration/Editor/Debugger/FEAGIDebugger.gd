@tool
extends EditorDebuggerPlugin
class_name FEAGIDebugger
## Handles the Debug implementation of FEAGI in Godot

const PREFAB_DEBUGGER_PANEL: PackedScene = preload("res://addons/FeagiIntegration/Editor/Debugger/FEAGIDebugPanel.tscn")

var debugger_panel: FEAGIDebugPanel = null
var _last_used_session_ID: int

func close_session() -> void:
	var session: EditorDebuggerSession = get_session(_last_used_session_ID)
	if !session:
		push_error("Unable to remove the FEAGI Debugger Panel! Is the session ID Invalid? Please restart the editor!")
		return
	session.remove_session_tab(debugger_panel)
	debugger_panel.queue_free()


func _has_capture(capture: String) -> bool:
	## Virtual func -> should return true if the given capture is related to FEAGI
	return capture == "FEAGI"

func _setup_session(session_ID: int) -> void:
	var session: EditorDebuggerSession = get_session(session_ID)
	_refresh_FEAGIDebugger_panel(session_ID)
	session.add_session_tab(debugger_panel)


func _refresh_FEAGIDebugger_panel(session_ID: int) -> FEAGIDebugPanel:
	_last_used_session_ID = session_ID
	debugger_panel = PREFAB_DEBUGGER_PANEL.instantiate()
	return debugger_panel
