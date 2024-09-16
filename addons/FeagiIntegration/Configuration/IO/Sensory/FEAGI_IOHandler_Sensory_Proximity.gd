@tool
extends FEAGI_IOHandler_Sensory_Base
class_name FEAGI_IOHandler_Sensory_Proximity

const TYPE_NAME = "proxmity"

func get_device_type() -> StringName:
	return TYPE_NAME
	
## If there is a data grabber function, get the float from it and process it before outputting the data from it. Otherwise updates the cached data with a zero
func refresh_cached_sensory_data() -> void:
	if _data_grabber.is_null():
		_cached_data.encode_float(0, 0)
		return
	_cached_data.encode_float(0, _data_grabber.call())
