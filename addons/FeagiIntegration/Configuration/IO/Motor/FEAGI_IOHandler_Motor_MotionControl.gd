@tool
extends FEAGI_IOHandler_Motor_Base
class_name FEAGI_IOHandler_Motor_MotionControl
## Motion Control, recieves data from FEAGI to go in various directions.
## _data_reciever Callable is expected to have a parameter taking a dictionary, where string keys are mapped to the float value of that direciton, ranging from 0-1

const TYPE_NAME = "motion_control"

@export var automatically_emulate_keys: Dictionary = {} ## A dictionary that if defined, is key'd by the data key name of this output, and value'd to the [FEAGI_Emulated_Input] for a specific event

var _output: Dictionary = {}

static func byte_array_to_dictionary(bytes: PackedByteArray) -> Dictionary:
	var output: Dictionary
	var floats: PackedFloat32Array = bytes.to_float32_array()
	output["move_up"] = floats[0]
	output["move_down"] = floats[1]
	output["move_right"] = floats[2]
	output["move_left"] = floats[3]
	output["yaw_left"] = floats[4] 
	output["yaw_right"] = floats[5]
	output["roll_left"] = floats[6]
	output["roll_right"] = floats[7]
	output["pitch_forward"] = floats[8]
	output["pitch_backward"] = floats[9]
	return output

## Return what the packed byte array equivalent of a zero value would be
static func retrieve_zero_value_byte_array() -> PackedByteArray:
	# HACK what is commented out is correct, but for now using a hack
	#var arr: PackedFloat32Array = PackedFloat32Array([0,0,0,0,0,0,0,0,0,0])
	#return arr.to_byte_array()
	var dict: Dictionary = {
		"move_up": 0.0,
		"move_down": 0.0,
		"move_right": 0.0,
		"move_left": 0.0,
		"yaw_left" : 0.0,
		"yaw_right": 0.0,
		"roll_left": 0.0,
		"roll_right": 0.0,
		"pitch_forward": 0.0,
		"pitch_backward": 0.0
		}
	return JSON.stringify(dict).to_utf8_buffer()
	

func get_device_type() -> StringName:
	return TYPE_NAME

## OVERRIDDEN - right now we recieve data as dicts. So for now we will translate it like this
func update_state_with_retrieved_date(new_data: PackedByteArray) -> void:
	var json_string: String = new_data.get_string_from_utf8()
	var json: Dictionary = JSON.parse_string(json_string)
	var floats: PackedFloat32Array = PackedFloat32Array()
	floats.resize(10)
	floats[0] = json["move_up"]
	floats[1] = json["move_down"]
	floats[2] = json["move_right"]
	floats[3] = json["move_left"]
	floats[4] = json["yaw_left"]
	floats[5] = json["yaw_right"]
	floats[5] = json["roll_left"]
	floats[5] = json["roll_right"]
	floats[5] = json["pitch_forward"]
	floats[5] = json["pitch_backward"]
	# TODO other variables once connector supports them
	_cached_bytes = floats.to_byte_array()
	_process_raw_data(_cached_bytes) # IRONICALLY for this specific usecase its easiest for downstream devs is to have a dictionary, so we are going to turn it back lol.
	# This is only being done since later we will migrate away from this format

func is_using_automatic_input_key_emulation() -> bool:
	return len(automatically_emulate_keys) != 0


func _process_raw_data(raw_data: PackedByteArray) -> void:
	_output = FEAGI_IOHandler_Motor_MotionControl.byte_array_to_dictionary(raw_data)
	if !_data_reciever.is_null():
		_data_reciever.call(_output.duplicate())
	
