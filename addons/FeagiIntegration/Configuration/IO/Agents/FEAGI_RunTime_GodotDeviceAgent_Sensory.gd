extends FEAGI_RunTime_GodotDeviceAgent_Base
class_name FEAGI_RunTime_GodotDeviceAgent_Sensory
## Acts as an agent on all Godot Device Sensors to act as interfaces to handle registration and data transfer

var _data_retrieval_function: Callable = Callable() ## Function that takes no parameters and returns the appropriate data type expected by the sensor

func setup_for_sensor_registration(data_retrival_function: Callable, override_device_type: StringName = initial_device_type_of_agent, override_device_name: StringName = initial_device_name_to_map_to_FEAGI) -> void:
	var is_valid: bool = _base_setup_agent_for_registration(FEAGI_PLUGIN.GODOT_SUPPORTED_SENSORS, FEAGI.godot_device_manager.get_possible_sensor_feagi_names(), override_device_type, override_device_name)
	if not is_valid:
		return
	_data_retrieval_function = data_retrival_function
	_is_ready_for_registration = true

func get_data_retrival_function() -> Callable:
	return _data_retrieval_function

func _register_device() -> bool:
	if _data_retrieval_function.is_null():
		push_error("FEAGI: Sensor %s does not have a data retrival function defined correctly! Was the 'setup_device_type' function called incorrectly? Skipping Registration!" % _device_name)
		return false
	
	var is_registration_sucessful: bool = FEAGI.godot_device_manager.register_godot_device_sensor(self)
	return is_registration_sucessful

func _deregister_device() -> bool:
	# TODO
	return false
