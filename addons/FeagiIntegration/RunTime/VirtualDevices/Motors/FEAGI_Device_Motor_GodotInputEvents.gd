extends Node
class_name FEAGI_IOConnector_GodotInputEvents
## Can emulate a set of Godot Input events as a motor output
#NOTE: This system is also automatically added as per genome mapping settings!


var _cached_data: Variant ## Since FEAGI motor data and Godot input data are in different time domains, we need to cache it
var _registration_agent: FEAGI_RegistrationAgent_Motor
var _input_emulators: Array[FEAGI_EmuInput_Abstract]

func _process(delta: float) -> void:
	if _registration_agent:
		for input_emulator in _input_emulators:
			if input_emulator:
				input_emulator.process_input()

## Attempts to register a motors emulated inputs. If alternate emulated inputs is empty, attempts to set it using any saved on disk emulated input configuration made during plugin configuration
func register_motor_to_emulated_inputs(motor_name: StringName, alternate_emulated_inputs: Array[FEAGI_EmuInput_Abstract] = []) -> Error:
	var FEAGI_motor: FEAGI_IOConnector_Motor_Base = FEAGI.registration_agent_manager.get_FEAGI_motor_by_name(motor_name)
	if !FEAGI_motor:
		push_error("FEAGI: Unknown motor of name %s to register emulated inputs to!" % motor_name)
		return Error.ERR_DOES_NOT_EXIST
	if len(alternate_emulated_inputs) == 0:
		alternate_emulated_inputs = FEAGI_motor.InputEmulators
		if len(alternate_emulated_inputs) == 0:
			push_warning("FEAGI: Cannot register emulated inputs for motor %s as none are defined!" % motor_name)
			return Error.ERR_DOES_NOT_EXIST
	if !FEAGI_motor.is_input_emulation_array_valid(alternate_emulated_inputs):
		push_error("FEAGI: Emulated input definition invalid for motor %s!" % motor_name)
		return Error.ERR_INVALID_DATA
	
	if FEAGI_motor is FEAGI_IOConnector_Motor_MotionControl:
		_setup_motion_control_emulated_inputs(alternate_emulated_inputs)
	elif FEAGI_motor is FEAGI_IOConnector_Motor_Misc:
		_setup_misc_emulated_inputs(alternate_emulated_inputs)
	elif FEAGI_motor is FEAGI_IOConnector_Motor_Motor:
		_setup_motor_emulated_inputs(alternate_emulated_inputs)
	else:
		push_error("FEAGI:Unknown motor type of motor %s!" % motor_name)
		return Error.ERR_INVALID_DATA
	
	_cached_data = FEAGI_motor.retrieve_cached_value() # RISKY
	_input_emulators = alternate_emulated_inputs

	_registration_agent = FEAGI_RegistrationAgent_Motor.new()
	_registration_agent.register_with_FEAGI(_cache_motor_data, FEAGI_motor.get_device_type(), motor_name)
	return Error.OK
	
func _cache_motor_data(data_in: Variant) -> void:
	_cached_data = data_in

func _setup_motion_control_emulated_inputs(input_emulators: Array[FEAGI_EmuInput_Abstract]) -> void:
	if input_emulators[0]: # Translate Upward
		input_emulators[0].runtime_setup(func(): return _cached_data.move_up)
	if input_emulators[1]: # Translate Downward
		input_emulators[1].runtime_setup(func(): return _cached_data.move_down)
	if input_emulators[2]: # Translate Leftward
		input_emulators[2].runtime_setup(func(): return _cached_data.move_left)
	if input_emulators[3]: # Translate Rightward
		input_emulators[3].runtime_setup(func(): return _cached_data.move_right)
	if input_emulators[4]: # Yaw Left
		input_emulators[4].runtime_setup(func(): return _cached_data.yaw_left)
	if input_emulators[5]: # Yaw Right
		input_emulators[5].runtime_setup(func(): return _cached_data.yaw_right)
	if input_emulators[6]: # Roll Left
		input_emulators[6].runtime_setup(func(): return _cached_data.roll_left)
	if input_emulators[7]: # Roll Right
		input_emulators[7].runtime_setup(func(): return _cached_data.roll_right)
	if input_emulators[8]: # Pitch Foward
		input_emulators[8].runtime_setup(func(): return _cached_data.pitch_forward)
	if input_emulators[9]: # Pitch Backward
		input_emulators[9].runtime_setup(func(): return _cached_data.pitch_backward)
	if input_emulators[10]: # Translate Forward
		input_emulators[10].runtime_setup(func(): return _cached_data.move_forward)
	if input_emulators[11]: # Translate Backward
		input_emulators[11].runtime_setup(func(): return _cached_data.move_backward)

func _setup_misc_emulated_inputs(input_emulators: Array[FEAGI_EmuInput_Abstract]) -> void:
	if input_emulators[0]:
		input_emulators[0].runtime_setup(func(): return _cached_data)

func _setup_motor_emulated_inputs(input_emulators: Array[FEAGI_EmuInput_Abstract]) -> void:
	if input_emulators[0]:
		input_emulators[0].runtime_setup(func(): return _cached_data)
