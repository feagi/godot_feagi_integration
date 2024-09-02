@tool
extends EditorDebuggerSession
class_name FEAGIDebuggerSession

const PREFAB_DEBUGGER_PANEL: PackedScene = preload("res://addons/FeagiIntegration/Editor/Debugger/FEAGIDebugPanel.tscn")

func add_FEAGI_debug_panel() -> FEAGIDebugPanel:
	var panel: FEAGIDebugPanel = PREFAB_DEBUGGER_PANEL.instantiate()
	add_session_tab(panel)
	return panel
