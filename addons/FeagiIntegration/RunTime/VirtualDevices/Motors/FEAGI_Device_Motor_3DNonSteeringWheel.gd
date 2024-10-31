extends VehicleWheel3D
class_name FEAGI_IOConnector_Motor_3DNonSteeringWheel
## Acts as a robot wheel controllable by FEAGI. Is a "Motor" type FEAGI Motor

@export var wheel_motor_name: StringName = "" ## What is the matching motor motor name in FEAGI?
@export var autoregister_on_start: bool = true
@export var max_forward_engine_force: float = 10.0 ## The engine_force to set when FEAGI is pressing max strength

var _registration_agent: FEAGI_RegistrationAgent_Motor
var _max_engine_force

func _ready() -> void:
	if autoregister_on_start:
		if not FEAGI.is_ready_for_device_registration():
			await FEAGI.ready_for_registration_agent_registration
		register_wheel_motor(wheel_motor_name)

func register_wheel_motor(device_name_in_FEAGI: StringName) -> void:
	_registration_agent = FEAGI_RegistrationAgent_Motor.new()
	_registration_agent.register_with_FEAGI(_FEAGI_action_motor, FEAGI_IOConnector_Motor_Motor.TYPE_NAME, device_name_in_FEAGI)

func _FEAGI_action_motor(motor_strength_and_direction: float) -> void:
	engine_force = max_forward_engine_force * motor_strength_and_direction
	
