extends Node
class_name FEAGI_Device_Camera_ScreenCapture
## Camera Device that takes a capture of the entire global viewport
#NOTE: This system is also automatically added as per genome mapping settings!

@export var registration_agent: FEAGI_RunTime_GodotDeviceAgent_Sensory

## Initializes the agent var and preps it for registration
func setup_screenshot_system(FEAGI_camera_name: StringName) -> void:
	registration_agent = FEAGI_RunTime_GodotDeviceAgent_Sensory.new()
	registration_agent.setup_for_sensor_registration(_capture_viewport, "camera",FEAGI_camera_name )

## Actually calls for the registration
func register_device() -> void:
	if registration_agent:
		registration_agent.register_device()

func _capture_viewport() -> Image:
	var viewPort: Viewport = get_tree().root.get_viewport()
	return viewPort.get_texture().get_image()
