@tool
extends MarginContainer
class_name FEAGIDebugPanel
## The actual Debug Panel visible in editor to see what the FEAGI integration is doing

const CAMERA_DEVICE: PackedScene = preload("res://addons/FeagiIntegration/Editor/Debugger/SensoryDevices/FEAGIDebuggerViewCamera.tscn")

var _not_running: VBoxContainer
var _running: VBoxContainer
var _sensor_holder: VBoxContainer
var _motor_holder: VBoxContainer

var _device_update_callables: Array = []

## THis functiojn is called directly by [FEAGIDebugger] on the init
func initialize() -> void:
	_not_running = $Tabs/Data/NotRunning
	_running = $Tabs/Data/Running
	_sensor_holder = $Tabs/Data/Running/HSplitContainer/Sensors/PanelContainer/VBoxContainer
	_motor_holder = $Tabs/Data/Running/HSplitContainer/Motors/PanelContainer/VBoxContainer
	var data_split: SplitContainer = $Tabs/Data/Running/HSplitContainer
	data_split.split_offset = size.x / 2

func set_running_state(is_running: bool) -> void:
	return
	_not_running.visible = !is_running
	_running.visible = is_running

## Called by [FEAGIDebugger] when it recieves a message about a device being added
func add_sensor_device(sensor_type: StringName, sensor_name: StringName) -> void:
	var view: FEAGIDebugViewBase
	match(sensor_type): # This could be a dict lookup, hmmm
		"camera":
			view = CAMERA_DEVICE.instantiate()
		_:
			push_error("FEAGI: Unknown device type %s requested to be added to the debugger!" % sensor_type)
			return
	view.initialize()
	view.setup_base(sensor_name)
	_sensor_holder.add_child(view)
	_device_update_callables.append(view.update_visualization)
	_update_none_label(_sensor_holder)


func _update_none_label(vbox: VBoxContainer) -> void:
	var label: Label = vbox.get_child(0)
	label.visible = vbox.get_child_count() == 1
