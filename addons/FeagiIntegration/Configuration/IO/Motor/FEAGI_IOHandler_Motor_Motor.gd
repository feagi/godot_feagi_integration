@tool
extends FEAGI_IOHandler_Motor_Base
class_name FEAGI_IOHandler_Motor_Motor
## Motor, recieves data from FEAGI to Rotate. Single Float.
## _data_reciever Callable is expected to have a parameter taking a float going from -inf to inf

const TYPE_NAME = "motor"

@export var automatically_emulate_keys: Dictionary = {} ## A dictionary that if defined, is key'd by the string "forward" or "backward", and value'd to the [FEAGI_Emulated_Input] for a specific event

var _output: Dictionary = {}

static func byte_array_to_float(bytes: PackedByteArray) -> float:
	return bytes.decode_float(0)

## Return what the packed byte array equivalent of a zero value would be
static func retrieve_zero_value_byte_array() -> PackedByteArray:
	var output: PackedByteArray = PackedByteArray()
	output.resize(4)
	output.encode_float(0, 0.0)
	return output

func _init() -> void:
	_cached_bytes = PackedByteArray()
	_cached_bytes.resize(4) # Since "encode_float" does not modify byte array lengths, we need to ensure we can fit a float in it

func get_device_type() -> StringName:
	return TYPE_NAME

func is_using_automatic_input_key_emulation() -> bool:
	return len(automatically_emulate_keys) != 0

func _process_raw_data(raw_data: PackedByteArray) -> void:
	if !_data_reciever.is_null():
		_data_reciever.call(FEAGI_IOHandler_Motor_Motor.byte_array_to_float(raw_data))
