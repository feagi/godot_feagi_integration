extends Node
class_name FEAGIAutomaticDeviceGenerator
## Some devices are not directly added by the user to their scenes, they are set to be created by the plugin directly. This node facilitates that

func _enter_tree() -> void:
	name = "FEAGI Automatic Device Generator"

## Goes through device arrays, sees if any are calling for an automatically generated Registration Agents, and if so, create them
func add_all_autogenerated_objects(FEAGI_sensors: Dictionary, FEAGI_motors: Dictionary) -> void:
	for sensor_name in FEAGI_sensors:
		print("Adding autogenerated sensor: %s" % sensor_name)
		if FEAGI_sensors[sensor_name] is FEAGI_IOConnector_Sensor_Camera:
			if (FEAGI_sensors[sensor_name] as FEAGI_IOConnector_Sensor_Camera).automatically_create_screengrabber:
				var screenshoter: FEAGI_IOConnector_Sensor_ScreenCapture = FEAGI_IOConnector_Sensor_ScreenCapture.new()
				add_child(screenshoter)
				screenshoter.register_screenshot_system((FEAGI_sensors[sensor_name] as FEAGI_IOConnector_Sensor_Camera).device_friendly_name)
				screenshoter.name = "Screenshoter - " + (FEAGI_sensors[sensor_name] as FEAGI_IOConnector_Sensor_Camera).device_friendly_name
				continue
				
	for motor_name in FEAGI_motors:
		print("Adding autogenerated motor: %s" % motor_name)
		if FEAGI_motors[motor_name] is FEAGI_IOConnector_Motor_MotionControl:
			if (FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_MotionControl).is_using_automatic_input_key_emulation():
				var input_emulators: FEAGI_IOConnector_GodotInputEvents = FEAGI_IOConnector_GodotInputEvents.new()
				input_emulators.name = "motion control input emulator - " + (FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_MotionControl).device_friendly_name
				add_child(input_emulators)
				input_emulators.register_input_emulator(
					FEAGI_IOConnector_GodotInputEvents.create_callable_for_motion_control((FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_MotionControl).automatically_emulate_keys, input_emulators),
					"motion_control",
					(FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_MotionControl).device_friendly_name)
				continue
		
		if FEAGI_motors[motor_name] is FEAGI_IOConnector_Motor_Motor:
			if (FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_Motor).is_using_automatic_input_key_emulation():
				var input_emulators: FEAGI_IOConnector_GodotInputEvents = FEAGI_IOConnector_GodotInputEvents.new()
				input_emulators.name = "motor input emulator - " + (FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_MotionControl).device_friendly_name
				add_child(input_emulators)
				input_emulators.register_input_emulator(
					FEAGI_IOConnector_GodotInputEvents.create_callable_for_motor((FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_Motor).automatically_emulate_keys, input_emulators),
					"motor",
					(FEAGI_motors[motor_name] as FEAGI_IOConnector_Motor_Motor).device_friendly_name)
				continue
