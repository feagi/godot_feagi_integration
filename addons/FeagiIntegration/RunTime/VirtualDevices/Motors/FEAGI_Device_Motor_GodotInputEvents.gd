extends Node
class_name FEAGI_Device_GodotInputEvents
## Can emulate a set of Godot Input events as a motor output
#NOTE: This system is also automatically added as per genome mapping settings!

@export var registration_agent: FEAGI_RunTime_GodotDeviceAgent_Motor

var _input_emulators_keyd_by_action: Dictionary

## Initializes the agent var and preps it for registration
func setup_input_emulation(FEAGI_motor_name: StringName, input_emulators: Dictionary) -> void:
	_input_emulators_keyd_by_action = input_emulators
	for direction in _input_emulators_keyd_by_action:
		var input_emulator: FEAGI_Emulated_Input = _input_emulators_keyd_by_action[direction]
		input_emulator.setup_for_use(self)
	registration_agent = FEAGI_RunTime_GodotDeviceAgent_Motor.new()
	registration_agent.setup_for_motor_registration(_press_input, FEAGI_IOHandler_Motor_MotionControl.TYPE_NAME, FEAGI_motor_name)

## Actually calls for the registration
func register_device() -> void:
	if registration_agent:
		registration_agent.register_device()

func _press_input(directions_and_strengths: Dictionary) -> void: ## The direction as keys, and the values are the strengths
	var input_emulator: FEAGI_Emulated_Input
	for direction in directions_and_strengths:
		input_emulator = _input_emulators_keyd_by_action[direction]
		input_emulator.press_action(directions_and_strengths[direction])
