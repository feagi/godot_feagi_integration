@tool
extends FEAGI_EmuInput_Abstract
class_name FEAGI_EmuInput_KeyboardPress
## Emulates a Keyboard press from a FEAGI motor action (from a float)

## Due to limitations with global scope, use this enum to represent all keys that are supported. Primarily used for UI purposes, use [Key] for internal use where possible
enum SUPPORTED_KEY {
	NONE = Key.KEY_NONE,
	ESCAPE = Key.KEY_ESCAPE,
	SPACE = Key.KEY_SPACE,
	ENTER = Key.KEY_ENTER,
	BACKSPACE = Key.KEY_BACKSPACE,
	TAB = Key.KEY_TAB,
	LEFT_SHIFT = Key.KEY_SHIFT,
	LEFT_CONTROL = Key.KEY_CTRL,
	LEFT_ALT = Key.KEY_ALT,
	CAPS_LOCK = Key.KEY_CAPSLOCK,
	NUM_LOCK = Key.KEY_NUMLOCK,
	SCROLL_LOCK = Key.KEY_SCROLLLOCK,
	A = Key.KEY_A,
	B = Key.KEY_B,
	C = Key.KEY_C,
	D = Key.KEY_D,
	E = Key.KEY_E,
	F = Key.KEY_F,
	G = Key.KEY_G,
	H = Key.KEY_H,
	I = Key.KEY_I,
	J = Key.KEY_J,
	K = Key.KEY_K,
	L = Key.KEY_L,
	M = Key.KEY_M,
	N = Key.KEY_N,
	O = Key.KEY_O,
	P = Key.KEY_P,
	Q = Key.KEY_Q,
	R = Key.KEY_R,
	S = Key.KEY_S,
	T = Key.KEY_T,
	U = Key.KEY_U,
	V = Key.KEY_V,
	W = Key.KEY_W,
	X = Key.KEY_X,
	Y = Key.KEY_Y,
	Z = Key.KEY_Z,
	ARROW_LEFT = Key.KEY_LEFT,
	ARROW_RIGHT = Key.KEY_RIGHT,
	ARROW_UP = Key.KEY_UP,
	ARROW_DOWN = Key.KEY_DOWN
	
}

@export var bang_bang_threshold: float = 0.5 ## A float from 0-1.0 that if the motor value is above, would be considfered a pres
@export var key_to_press: Key = KEY_NONE ## What key should be targetted? NOTE: after calling runtime_setup this value is ignored!

var _key_to_press: Key = KEY_NONE
var _was_pressed: bool = false

## Call this during setup if you intend to use during runtime to emulate Keyboard presses. Ensure the data acquisition method returns a float 0 - 1
func runtime_setup(method_to_get_FEAGI_data: Callable) -> Error:
	var notOK: Error = super(method_to_get_FEAGI_data)
	if notOK:
		return notOK
	
	if key_to_press == KEY_NONE:
		# no need to set anything up
		return Error.OK
	_key_to_press = key_to_press
	return Error.OK

func process_input() -> void:
	if _key_to_press == KEY_NONE:
		return
	
	var motor_value: float = _method_to_get_FEAGI_data.call()
	if _was_pressed == (motor_value > bang_bang_threshold):
		return
	_was_pressed = !_was_pressed
	
	var input_event: InputEventKey = InputEventKey.new()
	input_event.keycode = _key_to_press
	input_event.key_label = _key_to_press
	input_event.physical_keycode = _key_to_press
	input_event.pressed = _was_pressed
	#TODO echo?
	Input.parse_input_event(input_event)
