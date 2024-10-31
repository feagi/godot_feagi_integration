extends RefCounted
class_name FEAGI_RunTime_RegistrationAgentManager
## The Registration Agent Manager is the endpoint that Registration Agents [FEAGI_RegistrationAgent_Base] can use to register and deregister themselves from.
## This singleton handles mapping the registered Registration Agents to / from [FEAGI_IOConnector_Base]s
## NOTE: This does NOT handle the mapping of FEAGI Devices to the debugger or FEAGI itself, thats handled by [FEAGI_RunTime_IOConnectorManager]!

var _FEAGI_sensors_reference: Dictionary ## WARNING: For performance reasons, we pass this by reference, and changes may occur to this dictionary outside this class. Be EXTREMELY careful with caching!
var _FEAGI_motors_reference: Dictionary ## Ditto

func _init(reference_to_FEAGI_sensors: Dictionary, reference_to_FEAGI_motors: Dictionary) -> void:
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	_FEAGI_motors_reference = reference_to_FEAGI_motors

## Attempt to register a godot sensor to its equavilant [FEAGI_IOConnector_Sensor_Base], returns the FEAGI Sensor if succeeds
func register_registration_agent_sensor(agent: FEAGI_RegistrationAgent_Sensory) -> FEAGI_IOConnector_Sensor_Base:
	# NOTE: We assume the agent itself already made all the needed checks
	if agent.get_device_name() not in _FEAGI_sensors_reference:
		push_error("FEAGI: Unable to find a sensory Registration Agent for the agent of device name %s! Skipping registration!" % agent.get_device_name())
		return null
	
	var relevant_feagi_sensor: FEAGI_IOConnector_Sensor_Base = _FEAGI_sensors_reference[agent.get_device_name()]
	if agent.get_device_type() != relevant_feagi_sensor.get_device_type():
		push_error("FEAGI: Sensory agent %s is not of expected device type %s! Skipping registration!" % [agent.get_device_name(), relevant_feagi_sensor.get_device_type()])
		return null

	return relevant_feagi_sensor.register_registration_agent_sensor(agent.get_sensor_callable())

## Attempt to register a godot motor to its equavilant [FEAGI_IOConnector_Motor_Base],  returns the FEAGI Motor if succeeds
func register_registration_agent_motor(agent: FEAGI_RegistrationAgent_Motor) -> FEAGI_IOConnector_Motor_Base:
	# NOTE: We assume the agent itself already made all the needed checks
	if agent.get_device_name() not in _FEAGI_motors_reference:
		push_error("FEAGI: Unable to find a motor Registration Agent for the agent of device name %s! Skipping registration!" % agent.get_device_name())
		return null
	
	var relevant_feagi_motor: FEAGI_IOConnector_Motor_Base = _FEAGI_motors_reference[agent.get_device_name()]
	if agent.get_device_type() != relevant_feagi_motor.get_device_type():
		push_error("FEAGI: Motor agent %s is not of expected device type %s! Skipping registration!" % [agent.get_device_name(), relevant_feagi_motor.get_device_type()])
		return null

	return relevant_feagi_motor.register_registration_agent_motor(agent.get_motor_callable())

## TODO Deregister

## Get an up to date array of all sensor names that are allowed (that are in the FEAGI mapping definition config)
func get_possible_sensor_feagi_names() -> PackedStringArray:
	var output: Array[StringName] = []
	for sensor in _FEAGI_sensors_reference.values():
		output.append(sensor.device_friendly_name)
	return PackedStringArray(output)

func get_possible_motor_feagi_names() -> PackedStringArray:
	var output: Array[StringName] = []
	for motor in _FEAGI_motors_reference.values():
		output.append(motor.device_friendly_name)
	return PackedStringArray(output)
	
