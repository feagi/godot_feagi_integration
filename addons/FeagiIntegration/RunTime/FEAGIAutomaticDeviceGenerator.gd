extends Node
class_name FEAGIAutomaticDeviceGenerator
## Some devices are not directly added by the user to their scenes, they are set to be created by the plugin directly. This node facilitates that



func add_camera_screencapture(FEAGI_camera_name: StringName) -> FEAGIDeviceCameraScreenCapture:
	var screenshot_node: FEAGIDeviceCameraScreenCapture = FEAGIDeviceCameraScreenCapture.new()
	screenshot_node.setup_screenshot_system(FEAGI_camera_name)
	screenshot_node.name = "Camera_Screenshot_" + FEAGI_camera_name
	add_child(screenshot_node)
	return screenshot_node
