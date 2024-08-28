@tool
extends Resource
class_name FEAGIGenomeMapping

@export var FEAGI_enabled: bool = true
@export var delay_seconds_between_frames: float = 0.05
@export var configuration_JSON: StringName = ""

#TODO use only a single dictionary?
@export var sensor_cameras: Dictionary = {} ## A dictionary of [FEAGISensoryCamera]s key'd by their string device name

## Allows for registering cameras 
func sensor_camera_register(device_name: StringName, image_retrival_function: Callable) -> FEAGISensoryCamera:
	if device_name not in sensor_cameras:
		return null
	(sensor_cameras[device_name] as FEAGISensoryCamera).register_camera(image_retrival_function)
	return (sensor_cameras[device_name] as FEAGISensoryCamera)
