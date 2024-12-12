@tool
extends FEAGI_EmuInput_Abstract
class_name FEAGI_EmuInput_GodotInputEvent
## Emulates a Godot Input Event from a FEAGI motor action (from a float)

const NO_ACTION: StringName = "NONE!"

@export var use_bang_bang_instead_of_actual_value: bool = true ## If set, any input over the threshold will be treated as full firing. Otherwise will pass the actual float value to the input event
@export var bang_bang_threshold: float = 0.5 ## A float from 0-1.0 that if the motor value is above, would be considfered a press if using bang bang
@export var godot_input_event_name: StringName = NO_ACTION ## What input event should be targetted? NOTE: after calling runtime_setup this value is ignored!

var _godot_input_event_name: StringName = NO_ACTION

## Call this during setup if you intend to use during runtime to emulate Inputs. Ensure the data acquisition method returns a float 0 - 1
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

func process_input() -> void:
	if _godot_input_event_name == NO_ACTION:
		return
	var motor_value: float = _method_to_get_FEAGI_data.call()
	var is_pressed: bool
	if use_bang_bang_instead_of_actual_value:
		is_pressed = motor_value > bang_bang_threshold
		motor_value = float(is_pressed)
	else:
		is_pressed = !is_equal_approx(motor_value, 0.0)
	
	if is_pressed:
		if not Input.is_action_pressed(_godot_input_event_name):
			Input.action_press(_godot_input_event_name, motor_value)
		return
	else:
		if Input.is_action_pressed(_godot_input_event_name):
			Input.action_release(_godot_input_event_name)
