@tool
extends FEAGI_Device_Motor_Base
class_name FEAGI_Device_Motor_MotionControl
## Motion Control FEAGI Device. Can signal for movement in various directions
## NOTE: _function_to_interact_with_godot_with with in this class is expected to accept a [FEAGI_Data_MotionControl]

const TYPE_NAME = "motion_control"

@export var automatically_emulate_keys: Dictionary = {} ## A dictionary that if defined, is key'd by the string key name of the direction from FEAGI, and the value is the [FEAGI_Emulated_Input] for that even

func get_device_type() -> StringName:
	return TYPE_NAME

func is_using_automatic_input_key_emulation() -> bool:
	return len(automatically_emulate_keys) != 0

func retrieve_zero_value_byte_array() -> PackedByteArray:
	var arr: PackedByteArray = PackedByteArray()
	arr.resize(40)
	return arr

## Parse the data as a float and execute the function on it
func _parse_FEAGI_raw_data(raw_FEAGI_data: PackedByteArray) -> void:
	_cached_bytes = raw_FEAGI_data
	_function_to_interact_with_godot_with.call(FEAGI_Data_MotionControl.create_from_bytes(raw_FEAGI_data))
