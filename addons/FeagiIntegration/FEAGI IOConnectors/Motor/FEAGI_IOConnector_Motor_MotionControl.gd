@tool
extends FEAGI_IOConnector_Motor_Base
class_name FEAGI_IOConnector_Motor_MotionControl
## Motion Control FEAGI Device. Can signal for movement in various directions
## NOTE: _function_to_interact_with_godot_with with in this class is expected to accept a [FEAGI_Data_MotionControl]
const TYPE_NAME = "motion_control"

func get_device_type() -> StringName:
	return TYPE_NAME


func retrieve_zero_value_byte_array() -> PackedByteArray:
	var arr: PackedByteArray = PackedByteArray()
	arr.resize(48)
	return arr

func retrieve_cached_value() -> FEAGI_Data_MotionControl:
	return FEAGI_Data_MotionControl.create_from_bytes(_cached_bytes)

func get_InputEmulator_names() -> Array[StringName]:
	return [&"Translate Upward", &"Translate Downward", &"Translate Leftward", &"Translate Rightward", &"Yaw Left", &"Yaw Right", 
	&"Roll Left", &"Roll Right", &"Pitch Foward", &"Pitch Backward", &"Translate Forward", &"Translate Backward",
	]

func get_InputEmulator_data_types() -> Array[INPUT_EMULATOR_DATA_TYPE]:
	return [INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1,
	INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1,
	]

## Parse the data as a float and execute the function on it
func _parse_FEAGI_raw_data(raw_FEAGI_data: PackedByteArray) -> void:
	_cached_bytes = raw_FEAGI_data
	_function_to_interact_with_godot_with.call(FEAGI_Data_MotionControl.create_from_bytes(raw_FEAGI_data))
