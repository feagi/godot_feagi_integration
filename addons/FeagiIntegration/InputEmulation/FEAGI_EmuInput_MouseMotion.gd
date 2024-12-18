@tool
extends FEAGI_EmuInput_Abstract
class_name FEAGI_EmuInput_MouseMotion

## Emulates a Mouse Motion event from a FEAGI motor action (from a -1 - 1 vector2)

@export var movement_scaling: float = 1.0 ## How much to scale the movement by
@export var mirror_y_axis: bool = true ## if we should mirror the direction along the y axis

var _root_viewport: Viewport
var _movement_scaling: float
var _timestamp_previous_movement: int

## Call this during setup if you intend to use during runtime to emulate mouse clicks. Ensure the data acquisition method returns a float 0 - 1
func runtime_setup(method_to_get_FEAGI_data: Callable) -> Error:
	var notOK: Error = super(method_to_get_FEAGI_data)
	if notOK:
		return notOK
	
	_movement_scaling = movement_scaling
	_root_viewport = Engine.get_main_loop().root # May Linus Torvalds forgive me
	_timestamp_previous_movement = Time.get_ticks_msec()
	return Error.OK

func process_input() -> void:
	
	var motor_value: Vector2 = _method_to_get_FEAGI_data.call()

	if is_zero_approx(motor_value.length()):
		return # no need to send no movement
	
	motor_value *= _movement_scaling
	if mirror_y_axis:
		motor_value.y *= -1.0
	
	var window_scale: Vector2 = _root_viewport.get_screen_transform().get_scale()
	var delta_time: float = (_timestamp_previous_movement - Time.get_ticks_msec()) / 1000.0
	_timestamp_previous_movement = Time.get_ticks_msec()
	var input_event: InputEventMouseMotion = InputEventMouseMotion.new()
	
	input_event.screen_relative = motor_value
	input_event.screen_velocity = motor_value * delta_time
	input_event.relative = input_event.screen_relative * window_scale
	input_event.velocity = input_event.screen_velocity * window_scale

	input_event.global_position = _root_viewport.get_mouse_position()
	input_event.position = input_event.global_position # Since its from the root, this should be identical
	Input.parse_input_event(input_event)
