@tool
extends FEAGI_IOHandler_Motor_Base
class_name FEAGI_IOHandler_Motor_MotionControl
## Motion Control, recieves data from FEAGI to go forward, backward, right, and left.
## NOTE: _data_reciever in this class is to accept 2 parameters: 
## - A Vector4 (with floats 0.0-1.0 representing strength of forward, backward, right, left in that order),
## - A Vector2 that represents the above, but as XY movement with floats from -1.0 to 1.0

var _vec4: Vector4
var _vec2: Vector2

func get_device_type() -> StringName:
	return "motion_control"

## OVERRIDDEN - right now we recieve data as dicts. So for now we will translate it like this
func update_state_with_retrieved_date(new_data: PackedByteArray) -> void:
	var json_string: String = new_data.get_string_from_utf8()
	var json: Dictionary = JSON.parse_string(json_string)
	var floats: PackedFloat32Array = PackedFloat32Array()
	floats.resize(4)
	floats[0] = json["move_up"]
	floats[1] = json["move_down"]
	floats[2] = json["move_right"]
	floats[3] = json["move_left"]
	_cached_data = floats.to_byte_array()
	_process_raw_data(_cached_data)


func _process_raw_data(raw_data: PackedByteArray) -> void:
	var floats: PackedFloat32Array = raw_data.to_float32_array()
	_vec4 = Vector4(floats[0], floats[1], floats[2], floats[3])
	_vec2 = Vector2(floats[0] - floats[1], floats[2] - floats[3])
	if !_data_reciever.is_null():
		_data_reciever.call(_vec4, _vec2)
	
