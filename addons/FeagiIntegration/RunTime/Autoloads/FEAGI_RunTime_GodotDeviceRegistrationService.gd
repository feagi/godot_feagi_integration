extends RefCounted
class_name FEAGI_RunTime_GodotDeviceRegistrationService
## The Godot Device Registration Service is the endpoint that Godot Devices can use to register and deregister themselves from.
## This singleton handles mapping the registered Godot Devices to / from FEAGI Devices

var sensors: Dictionary = {} ## A dictionary of [FEAGI_IOHandler_Sensory_Base]s key'd by their device type name + "_" + device name

var _is_ready: bool = false

## Called from [FEAGI_RunTime] To initialize this object
func setup(initial_sensor_definitions: Dictionary) -> void:
	sensors = initial_sensor_definitions
	_is_ready = true

func get_possible_sensor_feagi_names() -> PackedStringArray:
	var output: Array[StringName]
	


func register_sensor(agent: FEAGI_RunTime_GodotDeviceAgent_Sensory) -> bool:
	return false




func _get_device_key(device_type_name: StringName, device_name: StringName) -> StringName:
	return device_type_name + "_" + device_name
