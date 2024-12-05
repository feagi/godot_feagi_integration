@tool
extends FEAGI_EmuInput_Abstract
class_name FEAGI_EmuInput_GodotInputEvent
## Emulates a Godot Input Event from a FEAGI motor action (from a float)

const NO_ACTION: StringName = "NONE!"

@export var use_bang_bang_instead_of_actual_value: bool = true ## If set, any input over the threshold will be treated as full firing. Otherwise will pass the actual float value to the input event
@export var bang_bang_threshold: float = 0.5 ## A float from 0-1.0 that if the motor value is above, would be considfered a press if using bang bang
@export var godot_input_event_name: StringName = NO_ACTION ## What input event should be targetted? NOTE: after calling runtime_setup this value is ignored!

var _godot_input_event_name: StringName = NO_ACTION

func runtime_setup(method_to_get_FEAGI_data: Callable) -> Error:
	var notOK: Error = super(method_to_get_FEAGI_data)
	if notOK:
		return notOK
	
	if godot_input_event_name == NO_ACTION:
		# no need to set anything up
		return Error.OK
	var possible_actions: Array[StringName] = InputMap.get_actions()
	if godot_input_event_name not in possible_actions:
		push_error("FEAGI: Unable to find input action %s in the project settings! FEAGI will not be able to press it!" % godot_input_event_name)
		return Error.ERR_DOES_NOT_EXIST 
	_godot_input_event_name = godot_input_event_name
	return Error.OK

## Called every frame for input processing
func process_input(_frame_delta: float) -> void:
	if _godot_input_event_name == NO_ACTION:
		return
	var motor_value: float = _method_to_get_FEAGI_data.call()
	var input_event: InputEventAction = InputEventAction.new()
	input_event.action = _godot_input_event_name
	if use_bang_bang_instead_of_actual_value:
		motor_value = float(motor_value > bang_bang_threshold)
		input_event.strength = motor_value
		input_event.pressed = bool(motor_value)
	else:
		input_event.strength = motor_value
		input_event.pressed = !is_equal_approx(motor_value, 0.0)
		
	Input.parse_input_event(input_event)
