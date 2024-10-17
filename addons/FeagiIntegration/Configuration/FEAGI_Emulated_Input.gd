@tool
extends Resource
class_name FEAGI_Emulated_Input
## Handles emulating a Godot Action press

const NO_ACTION: StringName = "NONE!"

@export var godot_action_name: StringName = NO_ACTION ## What action in godots input map to emulate the press of by name. "NONE!" will disable the action
@export var action_hold_seconds: float = 0.3 ## How long to hold the action for in seconds
@export var action_press_FEAGI_threshold: float = 0.5 ## The strength required by FEAGI to press this action
@export var action_release_FEAGI_threshold: float = 0.1 ## Below this value, it becomes explicit that the action is released

var _timer: Timer

func setup_for_use(node_to_hold_timer: Node) -> void:
	if godot_action_name == NO_ACTION:
		return
	var possible_actions: Array[StringName] = InputMap.get_actions()
	if godot_action_name not in possible_actions:
		push_error("FEAGI: Unable to find input action %s in the project settings! FEAGI will not be able to press it!" % godot_action_name)
		return
	_timer = Timer.new()
	_timer.name = "timer for input - " + godot_action_name
	node_to_hold_timer.add_child(_timer) # dont want to leave the timer orphaned
	_timer.autostart = false
	_timer.one_shot = false
	_timer.stop()
	_timer.wait_time = action_hold_seconds
	_timer.timeout.connect(_release)


func press_action(strength: float) -> void:
	if !_timer:
		return
	if strength < action_release_FEAGI_threshold and action_release_FEAGI_threshold != 0:
		_release()
		return
	if strength > action_press_FEAGI_threshold:
		_timer.wait_time = action_hold_seconds
		_timer.start(action_hold_seconds)
		if not Input.is_action_pressed(godot_action_name):
			Input.action_press(godot_action_name)
	
		
		
	
func _release() -> void:
	_timer.stop()
	Input.action_release(godot_action_name)
