@tool
extends Resource
class_name FEAGIGenomeMapping

@export var FEAGI_enabled: bool = true
@export var delay_seconds_between_frames: float = 0.05
@export var configuration_JSON: StringName = ""
@export var allowed_sensor_device_types: PackedStringArray = ["camera"]

@export var sensors: Dictionary = {} ## A dictionary of [FEAGISensoryBase]s key'd by their device type name + "_" + device name

func sensor_register(device_type_name: StringName, device_name: StringName, data_retrieval_function: Callable) -> FEAGISensoryBase:
	if device_type_name not in allowed_sensor_device_types:
		push_error("FEAGI: Unknown sensor of type %s attempted to register itself!" % device_type_name)
		return null
	var key: StringName = device_type_name + "_" + device_name
	if key not in sensors:
		push_error("FEAGI: Unknown %s sensor of name %s attempted to register itself! Is it in the Genome Mapping?" % [device_type_name, device_name])
		return null
	var sensor_definition: FEAGISensoryBase = sensors[key]
	sensor_definition.register_sensor(data_retrieval_function)
	return sensor_definition
	
