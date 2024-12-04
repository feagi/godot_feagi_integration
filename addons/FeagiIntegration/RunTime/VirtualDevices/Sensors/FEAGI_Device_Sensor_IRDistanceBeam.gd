extends RayCast3D
class_name FEAGI_Device_Sensor_IRDistanceBeam
## raycast that connects to a feagi proximity sensor, returns a value of 0-1 describing collesion status

@export var proximity_sensor_name: StringName = "" ## What is the matching proximity sensor name in FEAGI?
@export var autoregister_on_start: bool = true
@export var minimum_distance_outputs_one: bool = true ## if one should be the section closest to a sensor, or not (if false, 1 will be outputted when no collesion)

var _registration_agent: FEAGI_RegistrationAgent_Sensory

func _ready() -> void:
	if autoregister_on_start:
		if not FEAGI.is_ready_for_device_registration():
			register_IRDistanceBeam()
			await FEAGI.ready_for_registration_agent_registration
		register_IRDistanceBeam()

func register_IRDistanceBeam(FEAGI_sensor_name: StringName = proximity_sensor_name) -> void:
	_registration_agent = FEAGI_RegistrationAgent_Sensory.new()
	_registration_agent.register_with_FEAGI(_get_distance, "proximity", FEAGI_sensor_name)


func _get_distance() -> float:
	if !is_colliding():
		return float(!minimum_distance_outputs_one)
	var collesion_distance_ratio: float = (get_collision_point() - global_position).length() / target_position.length()
	
	if minimum_distance_outputs_one:
		return 1.0 - collesion_distance_ratio
	else:
		return collesion_distance_ratio
