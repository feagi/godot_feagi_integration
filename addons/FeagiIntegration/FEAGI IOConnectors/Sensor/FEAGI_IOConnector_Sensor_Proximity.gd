@tool
extends FEAGI_IOConnector_Sensor_Base
class_name FEAGI_IOConnector_Sensor_Proximity
## Proximity FEAGI Device. Sensor that captures distances in game to pass to FEAGI
## NOTE: _function_to_grab_from_godot with in this class is expected to return a [float]

const TYPE_NAME = "proximity"

func _init() -> void:
	_cached_bytes = PackedFloat32Array([0]).to_byte_array()

func get_device_type() -> StringName:
	return TYPE_NAME

func get_cached_data_as_float() -> float:
	return _parse_bytes_as_float(_cached_bytes)

## Processes the input vector into the byte array cache
func _process_sensor_input_for_cache_using_callable() -> void:
	_parse_float_into_byte_cache(_function_to_grab_from_godot_with.call())
