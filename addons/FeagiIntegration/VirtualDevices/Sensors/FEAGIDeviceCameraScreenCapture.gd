extends Node
class_name FEAGIDeviceCameraScreenCapture
## Camera Device that takes a capture of the entire global viewport
#WARNING: You probably do not want to use this node directly, as this is automatically instantiated depending on your settings

@export var registration_agent: FEAGIRegistrationAgentSensory

func _init() -> void:
	registration_agent.setup_device_type("camera", _capture_viewport)

func _capture_viewport() -> Image:
	var viewPort: Viewport = get_tree().root.get_viewport()
	return viewPort.get_texture().get_image()
	
