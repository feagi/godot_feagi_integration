@tool
extends FEAGI_IOConnector_Sensor_Base
class_name FEAGI_IOConnector_Sensor_Gyro
## Gyroscope FEAGI Device. Sensor that captures gyroscopic rotations as euler angles from game to pass to FEAGI.
## NOTE: _function_to_grab_from_godot with in this class is expected to return an [Vector3]

const TYPE_NAME = "gyro"

func _init() -> void:
	_cached_bytes = PackedFloat32Array([0,0,0]).to_byte_array()

func get_device_type() -> StringName:
	return TYPE_NAME

func get_cached_data_as_vector3() -> Vector3:
	return _parse_bytes_as_vector3(_cached_bytes)

## Processes the input vector into the byte array cache
func _process_sensor_input_for_cache_using_callable() -> void:
	_parse_vector3_into_byte_cache(_function_to_grab_from_godot_with.call())
