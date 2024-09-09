@tool
extends MarginContainer
class_name FEAGI_Debug_Panel
## The actual Debug Panel visible in editor to see what the FEAGI integration is doing

const CAMERA_DEVICE: PackedScene = preload("res://addons/FeagiIntegration/Editor/Debugger/SensoryDevices/FEAGI_Debug_Panel_ViewCamera.tscn")

var _not_running: VBoxContainer
var _running: VBoxContainer
var _sensor_holder: VBoxContainer
var _motor_holder: VBoxContainer

var _device_update_callables: Array[Callable] = []

## THis function is called directly by [FEAGIDebugger] on the init
func initialize() -> void:
	_device_update_callables = []
	_not_running = $Tabs/Data/NotRunning
	_running = $Tabs/Data/Running
	_sensor_holder = $Tabs/Data/Running/HSplitContainer/Sensors/PanelContainer/VBoxContainer
	_motor_holder = $Tabs/Data/Running/HSplitContainer/Motors/PanelContainer/VBoxContainer
	var data_split: SplitContainer = $Tabs/Data/Running/HSplitContainer
	data_split.split_offset = size.x / 2

func set_running_state(is_running: bool) -> void:
	_not_running.visible = !is_running
	_running.visible = is_running

## Resets the panel to its original state
func clear() -> void:
	for i in range(1, _sensor_holder.get_child_count()):
		_sensor_holder.get_child(i).queue_free()
	for i in range(1, _motor_holder.get_child_count()):
		_motor_holder.get_child(i).queue_free()
	_update_none_label(_sensor_holder, true)
	_update_none_label(_motor_holder, true)
	set_running_state(false)
	_device_update_callables = []
	

## Called by [FEAGIDebugger] when it recieves a message about a device being added
func add_sensor_device(sensor_type: StringName, sensor_name: StringName) -> void:
	var view: FEAGI_Debug_Panel_ViewBase
	match(sensor_type): # This could be a dict lookup, hmmm
		"camera":
			print("FEAGI: Added %s device of name %s!" % [sensor_type, sensor_name])
			view = CAMERA_DEVICE.instantiate()
		_:
			push_error("FEAGI: Unknown device type %s requested to be added to the debugger!" % sensor_type)
			return
	view.initialize()
	view.setup_base(sensor_name)
	_sensor_holder.add_child(view)
	_device_update_callables.append(view.update_visualization)
	print("a")
	print(_device_update_callables)
	_update_none_label(_sensor_holder, false)

## Called by [FEAGIDebugger] when it recieves a message containing data
func update_visualizations(data: Array) -> void:
	for i in range(len(_device_update_callables)):
		_device_update_callables[i].call(data[i])

func _update_none_label(vbox: VBoxContainer, is_visible: bool) -> void:
	var label: Label = vbox.get_child(0)
	label.visible = is_visible
