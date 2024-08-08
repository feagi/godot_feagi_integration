extends BaseFEAGILocalIO
class_name FEAGIInputGodotCamera

enum CAPTURE_METHOD {
	WHOLE_SCREEN_CAPTURE,
	MANUAL_RECIEVE_BY_NAME
}

var _capture_method: CAPTURE_METHOD

func _ready() -> void:
	super()

func setup(initial_name: StringName, capture_method: CAPTURE_METHOD) -> void:
	_setup_as_input(FEAGIPluginInit.INPUT_TYPE.CAMERA, initial_name)
	_capture_method = capture_method
