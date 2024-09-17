@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Gyro
## Gyroscope IOHandler. Sensor that captures rotations from game to pass to FEAGI. 3 Floats.
## NOTE: _data_grabber in this class is expected to return an [Vector3]

const TYPE_NAME = "gyro"

var _blank_zero_rotation: PackedByteArray

func _init() -> void:
	var arr: PackedFloat32Array = PackedFloat32Array([0,0,0])
	_blank_zero_rotation = arr.to_byte_array()

func get_device_type() -> StringName:
	return TYPE_NAME

## If there is a data grabber function, get the Vector3 from it and process it before storing the data from it. Otherwise updates the cached data with a zero
func refresh_cached_sensory_data() -> void:
	if _data_grabber.is_null():
		_cached_data = _blank_zero_rotation
		return
	var vector: Vector3 = _data_grabber.call()
	_cached_data = PackedFloat32Array([vector.x, vector.y, vector.z]).to_byte_array()
