extends FEAGIRegistrationAgentBase
class_name FEAGIRegistrationAgentSensory
## A FEAGI Registration Agent for all sensors

var _data_retrieval_function: Callable = Callable() ## Function that takes no parameters and returns the appropriate data type expected by the sensor

## Called from the device node that this object is a member of on its startup
func setup_device_type(type: StringName, data_retrieval_function: Callable) -> void:
	_device_type_name = type
	_data_retrieval_function = data_retrieval_function
	if attempt_registeration_on_startup:
		FEAGIRunTime.signal_all_autoregister_sensors_to_register.connect(register_device)
		

func _register_device() -> FEAGIIOBase:
	if _data_retrieval_function.is_null():
		push_error("FEAGI: Sensor %s does not have a data retrival function defined correctly! Was the 'setup_device_type' function called incorrectly? Skipping Registration!" % _device_name)
		return null
	var sensor_device: FEAGIIOBase = FEAGIRunTime.mapping_config.sensor_register(_device_type_name, _device_name, _data_retrieval_function)
	return sensor_device

func _deregister_device() -> FEAGIIOBase:
	var sensor_device: FEAGIIOBase = FEAGIRunTime.mapping_config.sensor_deregister(_device_type_name, _device_name)
	return sensor_device
