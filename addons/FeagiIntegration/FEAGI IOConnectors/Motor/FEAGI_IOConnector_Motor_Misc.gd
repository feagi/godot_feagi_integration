@tool
extends FEAGI_IOConnector_Motor_Base
class_name FEAGI_IOConnector_Motor_Misc
## Misc FEAGI Device. A generic float output for FEAGI
## NOTE: _function_to_interact_with_godot_with with in this class is expected to accept a [float]

@export var automatically_emulate_keys: Dictionary = {} ## A Dictionary that if defined, is key'd by the string  "forward" or "backward" and valued to the [FEAGI_Emulated_Input]

const TYPE_NAME = "misc"

func get_device_type() -> StringName:
	return TYPE_NAME

func is_using_automatic_input_key_emulation() -> bool:
	return len(automatically_emulate_keys) != 0

func retrieve_zero_value_byte_array() -> PackedByteArray:
	var arr: PackedByteArray = PackedByteArray()
	arr.resize(4)
	return arr

## Parse the data as a float and execute the function on it
func _parse_FEAGI_raw_data(raw_FEAGI_data: PackedByteArray) -> void:
	_cached_bytes = raw_FEAGI_data
	_function_to_interact_with_godot_with.call(_parse_bytes_as_float(raw_FEAGI_data))
