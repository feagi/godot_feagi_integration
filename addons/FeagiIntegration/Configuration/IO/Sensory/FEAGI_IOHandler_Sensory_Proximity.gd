@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Proximity
## Proxmimity IOHandler. Sensor that captures distances from game to pass to FEAGI. Single Float.
## NOTE: _data_grabber in this class is expected to return an [float]

const TYPE_NAME = "proximity"

static func byte_array_to_float(bytes: PackedByteArray) -> float:
	return bytes.decode_float(0)

func get_device_type() -> StringName:
	return TYPE_NAME
	
## If there is a data grabber function, get the float from it and process it before storing the data from it. Otherwise updates the cached data with a zero
func refresh_cached_sensory_data() -> void:
	if _data_grabber.is_null():
		_cached_bytes.encode_float(0, 0)
		return
	_cached_bytes.encode_float(0, _data_grabber.call())
