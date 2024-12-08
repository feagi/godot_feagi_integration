@tool
extends Resource
class_name FEAGI_EmuInput_Abstract
## Root Abstract class for all classes that store how and action emulating godot inputs, be they through Godot Input Events, or emulating physical actions

## Returns if this Input Emulator is ready to be used (if setup was called and valid)
var is_ready: bool:
	get: return _is_ready
var _method_to_get_FEAGI_data: Callable
var _is_ready: bool = false


## Call this during setup if you intend to use during runtime to emulate Inputs. Ensure the data acquisition method returns the expected type
func runtime_setup(method_to_get_FEAGI_data: Callable) -> Error:
	if method_to_get_FEAGI_data.is_null():
		push_error("method_to_get_FEAGI_data appears to be invalid!")
		_is_ready = false
		return Error.ERR_INVALID_DATA
	_method_to_get_FEAGI_data = method_to_get_FEAGI_data
	_is_ready = true
	return Error.OK


## [Overridden in child classes] to be called every process frame for input processing
func process_input(_frame_delta: float) -> void:
	pass
