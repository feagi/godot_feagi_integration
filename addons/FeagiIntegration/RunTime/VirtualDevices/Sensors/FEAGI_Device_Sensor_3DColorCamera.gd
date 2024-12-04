extends Camera3D
class_name FEAGI_IOConnector_Sensor_3DColorCamera
## Camera Device That sends its view to FEAGI. Camera Sensor

@export var camera_sensor_name: StringName = "" ## What is the matching camera sensor name in FEAGI?
@export var capture_resolution: Vector2i = Vector2i(64,64) ## The capture resolution of the camera. This is not the final size and will be resized by the FEAGI camera sensor
@export var autoregister_on_start: bool = true

var _registration_agent: FEAGI_RegistrationAgent_Sensory
var _viewport: Viewport
var _cloned_camera: Camera3D

func _ready() -> void:
	if autoregister_on_start:
		if not FEAGI.is_ready_for_device_registration():
			register_color_camera()
			await FEAGI.ready_for_registration_agent_registration
		register_color_camera()

## Initializes the agent var and preps it for registration
func register_color_camera(FEAGI_camera_name: StringName = camera_sensor_name, viewport_resolution: Vector2i = capture_resolution) -> void:
	current = false
	# May John Carmack forgive me for what I am about to do
	if not _viewport:
		_viewport = SubViewport.new()
		add_child(_viewport)
		_viewport.size = viewport_resolution
		_viewport.own_world_3d = true
		_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_viewport.audio_listener_enable_2d = false
		_viewport.audio_listener_enable_3d = false
	if not _cloned_camera:
		_cloned_camera = Camera3D.new()
		_viewport.add_child(_cloned_camera)
		_cloned_camera.keep_aspect = keep_aspect
		_cloned_camera.cull_mask = cull_mask
		_cloned_camera.environment = environment
		_cloned_camera.attributes = attributes
		_cloned_camera.compositor = compositor
		_cloned_camera.h_offset = h_offset
		_cloned_camera.v_offset = v_offset
		_cloned_camera.doppler_tracking = doppler_tracking
		_cloned_camera.projection = projection
		_cloned_camera.fov = fov
		_cloned_camera.near = near
		_cloned_camera.far = far
		_cloned_camera.current = true

	_registration_agent = FEAGI_RegistrationAgent_Sensory.new()
	_registration_agent.register_with_FEAGI(_capture_viewport, "camera", FEAGI_camera_name)

func _capture_viewport() -> Image:
	if _viewport:
		return _viewport.get_texture().get_image()
	else:
		return Image.create_empty(capture_resolution.x, capture_resolution.y, false, Image.FORMAT_RGB8) # return something
