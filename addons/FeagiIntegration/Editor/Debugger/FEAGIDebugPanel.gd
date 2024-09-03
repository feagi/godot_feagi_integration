@tool
extends MarginContainer
class_name FEAGIDebugPanel
## The actual Debug Panel visible in editor to see what the FEAGI integration is doing

var _not_running: VBoxContainer
var _running: VBoxContainer


## THis functiojn is called directly by [FEAGIDebugger] on the init
func initialize() -> void:
	_not_running = $Tabs/Data/NotRunning
	_running = $Tabs/Data/Running
	var data_split: SplitContainer = $Tabs/Data/Running/HSplitContainer
	data_split.split_offset = size.x / 2

func set_running_state(is_running: bool) -> void:
	return
	_not_running.visible = !is_running
	_running.visible = is_running

## Called by [FEAGIDebugger] when it recieves a message about a device being added
func add_sensor_device(sensor_type: StringName, sensor_name: StringName) -> void:
	print("a" + sensor_type + sensor_name)
