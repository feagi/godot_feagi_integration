@tool
extends FEAGI_EmuInput_Abstract
class_name FEAGI_EmuInput_KeyboardPress
## Emulates a Keyboard press from a FEAGI motor action (from a float)


@export var bang_bang_threshold: float = 0.5 ## A float from 0-1.0 that if the motor value is above, would be considfered a pres
@export var key_to_press: Key = KEY_NONE ## What key should be targetted? NOTE: after calling runtime_setup this value is ignored!

var _key_to_press: Key = KEY_NONE

func runtime_setup(method_to_get_FEAGI_data: Callable) -> Error:
	var notOK: Error = super(method_to_get_FEAGI_data)
	if notOK:
		return notOK
	
	if key_to_press == KEY_NONE:
		# no need to set anything up
		return Error.OK
	_key_to_press = key_to_press
	return Error.OK

## Called every frame for input processing
func process_input(_frame_delta: float) -> void:
	if _key_to_press == KEY_NONE:
		return
	var motor_value: float = _method_to_get_FEAGI_data.call()
	var input_event: InputEventKey = InputEventKey.new()
	input_event.keycode = _key_to_press
	input_event.key_label = _key_to_press
	input_event.physical_keycode = _key_to_press
	input_event.pressed = motor_value > bang_bang_threshold
	#TODO echo?
	Input.parse_input_event(input_event)
