extends FEAGI_RunTime_GodotDeviceAgent_Base
class_name FEAGI_RunTime_GodotDeviceAgent_Motor
## Acts as an agent on all Godot Device Motors to act as interfaces to handle registration and data transfer

var _data_setting_function: Callable = Callable() ## Function that takes the parameter expected of the motor and returns nothing

func setup_for_motor_registration(data_setting_function: Callable, override_device_type: StringName = initial_device_type_of_agent, override_device_name: StringName = initial_device_name_to_map_to_FEAGI) -> void:
	var is_valid: bool = _base_setup_agent_for_registration(FEAGI_PLUGIN.GODOT_SUPPORTED_MOTORS, FEAGI.godot_device_manager.get_possible_motor_feagi_names(), override_device_type, override_device_name)
	if not is_valid:
		return
	_data_setting_function = data_setting_function
	_is_ready_for_registration = true

func get_data_setting_function() -> Callable:
	return _data_setting_function

func _register_device() -> bool:
	if _data_setting_function.is_null():
		push_error("FEAGI: Motor %s does not have a data setting function defined correctly! Was the 'setup_device_type' function called incorrectly? Skipping Registration!" % _device_name)
		return false
	
	var is_registration_sucessful: bool = FEAGI.godot_device_manager.register_godot_device_motor(self)
	return is_registration_sucessful

func _deregister_device() -> bool:
	# TODO
	return false
