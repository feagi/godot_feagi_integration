@tool
extends EditorDebuggerPlugin
class_name FEAGIDebugger
## Handles the Debug implementation of FEAGI in Godot

const PREFAB_DEBUGGER_PANEL: PackedScene = preload("res://addons/FeagiIntegration/Editor/Debugger/FEAGIDebugPanel.tscn")

var debugger_panel: FEAGIDebugPanel = null

var _last_used_session_ID: int

## This is called from [FeagiPluginInit] when it is closing (as the plugin is getting disabled) since Godot has no way to normally close a debugger (?)
func close_session() -> void:
	var session: EditorDebuggerSession = get_session(_last_used_session_ID)
	if !session:
		push_error("Unable to remove the FEAGI Debugger Panel! Is the session ID Invalid? Please restart the editor!")
		return
	session.remove_session_tab(debugger_panel)
	debugger_panel.queue_free()

## Doesn't close the session per say, but it does clear the panel of details from the game running (IE resets)
func clear_session() -> void:
	if debugger_panel:
		debugger_panel.clear()
	

## Virtual func -> should return true if the given capture is related to FEAGI
func _has_capture(capture: String) -> bool:
	return capture == "FEAGI"

## Virtual func -> When the Game Instance sends messages, this will be called
func _capture(message: String, data: Array, _session_id: int) -> bool:
	if !debugger_panel:
		push_warning("FEAGI: Debugger has some broken references! This error is harmless, and called be resolved by reloading the editor!")
		return true
	match(message):
		"FEAGI:data":
			debugger_panel.update_visualizations(data)
			return true
		"FEAGI:add_device":
			# Array should be formatted as [bool true if motor, str(device type), str(device name)]
			debugger_panel.add_sensor_device(data[1], data[2])
			return true
		"FEAGI:remove_device":
			return true
		_:
			push_error("FEAGI: Unknown message of " + message)
	return true
	

## Virtual func -> called when the debugger session is initialized by Godot itself
func _setup_session(session_ID: int) -> void:
	var session: EditorDebuggerSession = get_session(session_ID)
	_refresh_FEAGIDebugger_panel_reference(session_ID)
	session.add_session_tab(debugger_panel)
	session.stopped.connect(clear_session)
	session.started.connect(_attempt_set_panel_to_running)

func _refresh_FEAGIDebugger_panel_reference(session_ID: int) -> FEAGIDebugPanel:
	_last_used_session_ID = session_ID
	debugger_panel = PREFAB_DEBUGGER_PANEL.instantiate()
	debugger_panel.initialize()
	debugger_panel.set_running_state(false)
	return debugger_panel

func _attempt_set_panel_to_running() -> void:
	if debugger_panel:
		debugger_panel.set_running_state(true)
