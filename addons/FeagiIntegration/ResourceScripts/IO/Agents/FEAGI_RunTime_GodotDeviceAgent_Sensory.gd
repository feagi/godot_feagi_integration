extends FEAGI_RunTime_GodotDeviceAgent_Base
class_name FEAGI_RunTime_GodotDeviceAgent_Sensory
## Acts as an agent on all Godot Device Sensors to act as interfaces to handle registration and data transfer

var _data_retrieval_function: Callable = Callable() ## Function that takes no parameters and returns the appropriate data type expected by the sensor

func setup


## Called from the device node that this object is a member of on its startup
func setup_device_type(type: StringName, data_retrieval_function: Callable) -> void:
	_device_type_name = type
	_data_retrieval_function = data_retrieval_function
	if attempt_registeration_on_startup:
		FEAGI_RunTime.signal_all_autoregister_sensors_to_register.connect(register_device)
		

func _register_device() -> FEAGI_IOHandler_Base:
	if _data_retrieval_function.is_null():
		push_error("FEAGI: Sensor %s does not have a data retrival function defined correctly! Was the 'setup_device_type' function called incorrectly? Skipping Registration!" % _device_name)
		return null
	var sensor_device: FEAGI_IOHandler_Base = FEAGI_RunTime.mapping_config.sensor_register(_device_type_name, _device_name, _data_retrieval_function)
	return sensor_device

func _deregister_device() -> FEAGI_IOHandler_Base:
	var sensor_device: FEAGI_IOHandler_Base = FEAGI_RunTime.mapping_config.sensor_deregister(_device_type_name, _device_name)
	return sensor_device
