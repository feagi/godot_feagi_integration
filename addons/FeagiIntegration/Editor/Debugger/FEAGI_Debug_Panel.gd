@tool
extends MarginContainer
class_name FEAGI_Debug_Panel
## The actual Debug Panel visible in editor to see what the FEAGI integration is doing

const CAMERA_DEVICE: PackedScene = preload("res://addons/FeagiIntegration/Editor/Debugger/SensoryDevices/FEAGI_Debug_Panel_ViewCamera.tscn")

var _not_running: VBoxContainer
var _running: VBoxContainer
var _sensor_holder: VBoxContainer
var _motor_holder: VBoxContainer

var _sensor_update_callables: Array[Callable] = [] # an array of callables for each sensor (in order), where each function takes in a PackedByteArray of the value to update the UI representing the device

## THis function is called directly by [FEAGIDebugger] on the init
func initialize() -> void:
	_sensor_update_callables = []
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
	_sensor_update_callables = []
	

## Called by [FEAGIDebugger] when it recieves a message about a device being added
func add_sensor_device(sensor_type: StringName, sensor_name: StringName, extra_setup_data: Array) -> void:
	var view: FEAGI_Debug_Panel_ViewBase
	match(sensor_type): # This could be a dict lookup, hmmm
		"camera":
			print("FEAGI: Added %s device of name %s!" % [sensor_type, sensor_name])
			view = CAMERA_DEVICE.instantiate()
		_:
			push_error("FEAGI Debugger: Unknown device type %s requested to be added to the debugger!" % sensor_type)
			return
	view.initialize() # establish internal UI references
	view.setup_base(sensor_name, extra_setup_data) 
	_sensor_holder.add_child(view)
	_sensor_update_callables.append(view.update_visualization)
	_update_none_label(_sensor_holder, false)

## Called by [FEAGIDebugger] when it recieves a message containing data for sensors
func update_sensor_visualizations(data: Array) -> void:
	for i in range(len(_sensor_update_callables)):
		_sensor_update_callables[i].call(data[i])

func _update_none_label(vbox: VBoxContainer, is_visible: bool) -> void:
	var label: Label = vbox.get_child(0)
	label.visible = is_visible
