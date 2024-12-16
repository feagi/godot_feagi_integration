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

## In the case we wish to dynamically disable input emulation, call this to clear any initialization we used for input emulation
func deinitialize() -> void:
	if _is_ready:
		push_warning("FEAGI: No need to deinitialize Emulated Input as its not initialized!")
		return
	_is_ready = false
	_method_to_get_FEAGI_data = Callable()

## Get the type expected to be returned for the given FEAGI data method. Some children may override this method if they expect something else
func get_expected_FEAGI_data_method_return_type() -> FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE:
	return FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1

## [Overridden in child classes] to be called every motor frame for input processing
func process_input() -> void:
	pass
