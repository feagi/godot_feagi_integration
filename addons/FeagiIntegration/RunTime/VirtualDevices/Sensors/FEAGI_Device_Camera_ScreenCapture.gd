extends Node
class_name FEAGI_Device_Camera_ScreenCapture
## Camera Device that takes a capture of the entire global viewport
#WARNING: You probably do not want to use this node directly, as this is automatically instantiated depending on your settings

var registration_agent: FEAGI_RegistrationAgent_Sensory

#NOTE: Given we spawn this node from the plugin, we dont want it to init to anything. That is handled by [FEAGIAutomaticDeviceGenerator] by its call to setup_screenshot_system
#func _init() -> void:
	#registration_agent.setup_device_type("camera", _capture_viewport)
	
#NOTE: All FEAGIRegistrationAgent derived classes will attempt to autoregister upon the signal from [FEAGI_RunTime]. This is desired
# However, their device name is not set and thus will be invalid initially, so we will have to update it before running all setup calls

func setup_screenshot_system(FEAGI_camera_name: StringName) -> void:
	registration_agent = FEAGI_RegistrationAgent_Sensory.new()
	registration_agent.set_current_device_name(FEAGI_camera_name)
	registration_agent.setup_device_type("camera", _capture_viewport)
	# From here, the registration agent automatically suscribes to the "signal_all_autoregister_sensors_to_register" signal from [FEAGI_RunTime]
	# Nothing else needs to be done!

func _capture_viewport() -> Image:
	var viewPort: Viewport = get_tree().root.get_viewport()
	return viewPort.get_texture().get_image()
	
