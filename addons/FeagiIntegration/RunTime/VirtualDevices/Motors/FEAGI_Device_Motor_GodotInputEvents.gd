extends Node
class_name FEAGI_IOConnector_GodotInputEvents
## Can emulate a set of Godot Input events as a motor output
#NOTE: This system is also automatically added as per genome mapping settings!

## Used to easily create a callable to process the outputs of motion control as input events
static func create_callable_for_motion_control(motion_control_automatic_inputs: Dictionary, node_for_timers: Node) -> Callable:
	(motion_control_automatic_inputs["move_up"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["move_down"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["move_left"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["move_right"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["yaw_left"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["yaw_right"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["roll_left"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["roll_right"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["pitch_forward"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motion_control_automatic_inputs["pitch_backward"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	
	return func(motion_control_data: FEAGI_Data_MotionControl) -> void:
		(motion_control_automatic_inputs["move_up"] as FEAGI_Emulated_Input).press_action(motion_control_data.move_up)
		(motion_control_automatic_inputs["move_down"] as FEAGI_Emulated_Input).press_action(motion_control_data.move_down)
		(motion_control_automatic_inputs["move_left"] as FEAGI_Emulated_Input).press_action(motion_control_data.move_left)
		(motion_control_automatic_inputs["move_right"] as FEAGI_Emulated_Input).press_action(motion_control_data.move_right)
		(motion_control_automatic_inputs["yaw_left"] as FEAGI_Emulated_Input).press_action(motion_control_data.yaw_left)
		(motion_control_automatic_inputs["yaw_right"] as FEAGI_Emulated_Input).press_action(motion_control_data.yaw_right)
		(motion_control_automatic_inputs["roll_left"] as FEAGI_Emulated_Input).press_action(motion_control_data.roll_left)
		(motion_control_automatic_inputs["roll_right"] as FEAGI_Emulated_Input).press_action(motion_control_data.roll_right)
		(motion_control_automatic_inputs["pitch_forward"] as FEAGI_Emulated_Input).press_action(motion_control_data.pitch_forward)
		(motion_control_automatic_inputs["pitch_backward"] as FEAGI_Emulated_Input).press_action(motion_control_data.pitch_backward)

static func create_callable_for_motor(motor_automatic_inputs: Dictionary, node_for_timers: Node) -> Callable:
	(motor_automatic_inputs["forward"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	(motor_automatic_inputs["backward"] as FEAGI_Emulated_Input).setup_for_use(node_for_timers)
	
	return func(motor_power: float) -> void:
		if motor_power > 0:
			(motor_automatic_inputs["forward"] as FEAGI_Emulated_Input).press_action(motor_power)
		else:
			(motor_automatic_inputs["backward"] as FEAGI_Emulated_Input).press_action(abs(motor_power))


var _registration_agent: FEAGI_RegistrationAgent_Motor

## The callable here should be essentially the entire thing setup already, and is where all input differntiation should take place within
func register_input_emulator(filled_callable: Callable, device_type: StringName, emulator_device_name: StringName) -> void:
	_registration_agent = FEAGI_RegistrationAgent_Motor.new()
	_registration_agent.register_with_FEAGI(filled_callable, device_type, emulator_device_name)
