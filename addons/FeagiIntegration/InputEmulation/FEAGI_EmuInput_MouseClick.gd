@tool
extends FEAGI_EmuInput_Abstract
class_name FEAGI_EmuInput_MouseClick
## Emulates a Mouse Click from a FEAGI motor action (from a 0 - 1 float). can also handle scrolling

## Due to limitations with global scope, use this enum to represent all buttons that are supported. Primarily used for UI purposes, use [MouseButton] for internal use where possible
enum SUPPORTED_KEY {
	MOUSE_BUTTON_NONE = MouseButton.MOUSE_BUTTON_NONE,
	MOUSE_BUTTON_LEFT = MouseButton.MOUSE_BUTTON_LEFT,
	MOUSE_BUTTON_RIGHT = MouseButton.MOUSE_BUTTON_RIGHT,
	MOUSE_BUTTON_MIDDLE = MouseButton.MOUSE_BUTTON_MIDDLE,
	MOUSE_BUTTON_WHEEL_UP = MouseButton.MOUSE_BUTTON_WHEEL_UP,
	MOUSE_BUTTON_WHEEL_DOWN = MouseButton.MOUSE_BUTTON_WHEEL_DOWN,
	MOUSE_BUTTON_WHEEL_LEFT = MouseButton.MOUSE_BUTTON_WHEEL_LEFT,
	MOUSE_BUTTON_WHEEL_RIGHT = MouseButton.MOUSE_BUTTON_WHEEL_RIGHT,
	MOUSE_BUTTON_XBUTTON1 = MouseButton.MOUSE_BUTTON_XBUTTON1,
	MOUSE_BUTTON_XBUTTON2 = MouseButton.MOUSE_BUTTON_XBUTTON2,
	
}

@export var bang_bang_threshold: float = 0.5 ## A float from 0-1.0 that if the motor value is above, would be considered a press
@export var is_double_click: bool = false
@export var mouse_button_to_click: MouseButton = MouseButton.MOUSE_BUTTON_NONE ## What mouse button should be targetted? NOTE: after calling runtime_setup this value is ignored!

var _button_to_click: MouseButton = MouseButton.MOUSE_BUTTON_NONE
var _was_pressed: bool = false
var _is_double_click: bool
var _root_viewport: Viewport

## Call this during setup if you intend to use during runtime to emulate mouse clicks. Ensure the data acquisition method returns a float 0 - 1
func runtime_setup(method_to_get_FEAGI_data: Callable) -> Error:
	var notOK: Error = super(method_to_get_FEAGI_data)
	if notOK:
		return notOK
	
	if mouse_button_to_click == MouseButton.MOUSE_BUTTON_NONE:
		# no need to set anything up
		return Error.OK
	_button_to_click = mouse_button_to_click
	_is_double_click = is_double_click
	_root_viewport = Engine.get_main_loop().get_tree().get_root_viewport() # May Linus Torvalds forgive me
	return Error.OK

func process_input() -> void:
	if _button_to_click == KEY_NONE:
		return
	
	var motor_value: float = _method_to_get_FEAGI_data.call()
	if _was_pressed == (motor_value > bang_bang_threshold):
		return
	_was_pressed = !_was_pressed
	

	var input_event: InputEventMouseButton = InputEventMouseButton.new()
	input_event.button_index = _button_to_click
	input_event.global_position = _root_viewport.get_mouse_position()
	input_event.position = input_event.global_position # Since its from the root, this should be identical
	input_event.double_click = _is_double_click
	input_event.pressed = _was_pressed
	#TODO echo?
	Input.parse_input_event(input_event)
