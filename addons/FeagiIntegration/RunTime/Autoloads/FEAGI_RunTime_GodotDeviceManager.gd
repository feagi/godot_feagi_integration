extends RefCounted
class_name FEAGI_RunTime_GodotDeviceManager
## The Godot Device Manager is the endpoint that Godot Devices can use to register and deregister themselves from.
## This singleton handles mapping the registered Godot Devices to / from FEAGI Devices
## NOTE: This does NOT handle the mapping of FEAGI Devices to the debugger or FEAGI itself, thats handled by [FEAGI_Runtime_FEAGIDeviceManager]!

var _FEAGI_sensors_reference: Dictionary ## WARNING: For performance reasons, we pass this by reference, and changes may occur to this dictionary outside this class. Be EXTREMELY careful with caching!

func _init(reference_to_FEAGI_sensors: Dictionary) -> void: #TODO add motors
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors

## Attempt to register a godot sensor to its equavilant [FEAGI_IOHandler_Sensory_Base], returns true if succeeds 
func register_godot_device_sensor(agent: FEAGI_RunTime_GodotDeviceAgent_Sensory) -> bool:
	# NOTE: We assume the agent itself already made all the needed checks
	if agent.get_device_name() not in _FEAGI_sensors_reference:
		push_error("FEAGI: Unable to find a sensory IO handler for the agent of device name %s! Skipping registration!" % agent.get_device_name())
		return false
	
	var relevant_feagi_sensor: FEAGI_IOHandler_Sensory_Base = _FEAGI_sensors_reference[agent.get_device_name()]
	if agent.get_device_type() != relevant_feagi_sensor.get_device_type():
		push_error("FEAGI: sensory agent %s is not of expected device type %s! Skipping registration!" % [agent.get_device_name(), relevant_feagi_sensor.get_device_type()])
		return false

	relevant_feagi_sensor.register_godot_device_sensor(agent.get_data_retrival_function())
	return true

## TODO motors

## TODO Deregister

## Get an up to date array of all sensor names that are allowed (that are in the FEAGI mapping definition config)
func get_possible_sensor_feagi_names() -> PackedStringArray:
	var output: Array[StringName] = []
	for sensor in _FEAGI_sensors_reference.values():
		output.append(sensor.device_name)
	return PackedStringArray(output)
	
