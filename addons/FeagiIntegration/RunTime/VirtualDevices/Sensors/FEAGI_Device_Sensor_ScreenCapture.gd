extends Node
class_name FEAGI_IOConnector_Sensor_ScreenCapture
## Camera Device that takes a capture of the entire global viewport
#NOTE: This system is also automatically added as per genome mapping settings!

@export var camera_sensor_name: StringName = ""
var _registration_agent: FEAGI_RegistrationAgent_Sensory

## Initializes the agent var and preps it for registration
func register_screenshot_system(FEAGI_camera_name: StringName = camera_sensor_name) -> void:
	_registration_agent = FEAGI_RegistrationAgent_Sensory.new()
	_registration_agent.register_with_FEAGI(_capture_viewport, "camera", FEAGI_camera_name)

func _capture_viewport() -> Image:
	var viewPort: Viewport = get_tree().root.get_viewport()
	return viewPort.get_texture().get_image()
