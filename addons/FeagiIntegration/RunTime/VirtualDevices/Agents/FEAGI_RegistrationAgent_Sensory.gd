extends FEAGI_RegistrationAgent_Base
class_name FEAGI_RegistrationAgent_Sensory

#WARNING: This remains in sync with GODOT_SUPPORTED_SENSORS of [FEAGI_PLUGIN_CONFIG]!
@export_enum("camera", "accelerometer", "gyro", "proximity") var default_sensor_type: String ## The type of this device. Note this can be overridden from the setup function

func get_sensor_callable() -> Callable:
	return _registered_callable

## COROUTINE function that registers sensor with FEAGI. Ensure your passed callable returns the variable type expected by the sensor!
func register_with_FEAGI(sensor_callable: Callable, override_device_type: StringName = default_sensor_type, override_device_name: StringName = default_device_name) -> bool:
	if !_check_if_registration_valid_base(sensor_callable, override_device_name): # checks base cases
		return false
	
	if !FEAGI.is_ready_for_device_registration():
		await FEAGI.ready_for_godot_device_registration
	
	if override_device_name not in FEAGI.godot_device_manager.get_possible_sensor_feagi_names():
		push_error("FEAGI: Device name %s is not found as a registered sensor from the loaded FEAGI config! Refusing to allow registration!" % override_device_name)
		return false
	
	_registered_callable = sensor_callable
	_registered_device_type = override_device_type
	_registered_device_name = override_device_name
	_is_registered_with = FEAGI.godot_device_manager.register_godot_device_sensor(self)
	return _is_registered_with != null
