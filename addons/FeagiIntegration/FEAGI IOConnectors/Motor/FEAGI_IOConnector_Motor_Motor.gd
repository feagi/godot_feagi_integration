@tool
extends FEAGI_IOConnector_Motor_Base
class_name FEAGI_IOConnector_Motor_Motor
## Motor FEAGI Device. Motor that that FEAGI can rotate
## NOTE: _function_to_interact_with_godot_with with in this class is expected to accept a [float]

const TYPE_NAME = "motor"

func get_device_type() -> StringName:
	return TYPE_NAME


func retrieve_zero_value_byte_array() -> PackedByteArray:
	var arr: PackedByteArray = PackedByteArray()
	arr.resize(4)
	return arr

func retrieve_cached_value() -> float:
	return _parse_bytes_as_float(_cached_bytes)

func get_InputEmulator_names() -> Array[StringName]:
	return [&"Forward", &"Backward"]

func get_InputEmulator_data_types() -> Array[INPUT_EMULATOR_DATA_TYPE]:
	return [INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1]

## Parse the data as a float and execute the function on it
func _parse_FEAGI_raw_data(raw_FEAGI_data: PackedByteArray) -> void:
	_cached_bytes = raw_FEAGI_data
	_function_to_interact_with_godot_with.call(_parse_bytes_as_float(raw_FEAGI_data))
