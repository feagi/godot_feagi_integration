@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Accelerometer
## Acceleration IOHandler. Sensor that captures Accelerations from game to pass to FEAGI. 3 Floats.
## NOTE: _data_grabber in this class is expected to return an [Vector3]

const TYPE_NAME = "accelerometer"

var _blank_zero_acceleration: PackedByteArray

static func byte_array_to_vector3(bytes: PackedByteArray) -> Vector3:
	var floats: PackedFloat32Array = bytes.to_float32_array()
	return Vector3(floats[0], floats[1],floats[2])

func _init() -> void:
	var arr: PackedFloat32Array = PackedFloat32Array([0,0,0])
	_blank_zero_acceleration = arr.to_byte_array()

func get_device_type() -> StringName:
	return TYPE_NAME

## If there is a data grabber function, get the Vector3 from it and process it before storing the data from it. Otherwise updates the cached data with a zero
func refresh_cached_sensory_data() -> void:
	if _data_grabber.is_null():
		_cached_bytes = _blank_zero_acceleration
		return
	var vector: Vector3 = _data_grabber.call()
	_cached_bytes = PackedFloat32Array([vector.x, vector.y, vector.z]).to_byte_array()
