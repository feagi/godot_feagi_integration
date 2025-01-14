@tool
extends RefCounted
class_name FEAGI_Data_MotionControl
## Data structure representing the output of the MotionControl FEAGI motor type

var yaw_left: float = 0
var pitch_forward: float = 0
var pitch_backward: float = 0
var yaw_right: float = 0

var roll_left: float = 0
var move_forward: float = 0
var move_backward: float = 0
var roll_right: float = 0

var move_left: float = 0
var move_up: float = 0
var move_down: float = 0
var move_right: float = 0


## Create straight from a byte array segment from FEAGI
static func create_from_bytes(bytes: PackedByteArray) -> FEAGI_Data_MotionControl:
	var output: FEAGI_Data_MotionControl = FEAGI_Data_MotionControl.new()
	output.move_left = bytes.decode_float(0)
	output.move_up = bytes.decode_float(4)
	output.move_down = bytes.decode_float(8)
	output.move_right = bytes.decode_float(12)
	
	output.roll_left = bytes.decode_float(16)
	output.move_forward = bytes.decode_float(20)
	output.move_backward = bytes.decode_float(24)
	output.roll_right = bytes.decode_float(28)
	
	output.yaw_left = bytes.decode_float(32)
	output.pitch_forward = bytes.decode_float(36)
	output.pitch_backward = bytes.decode_float(40)
	output.yaw_right = bytes.decode_float(44)
	return output

## Create straight from a byte array from FEAGI
static func create_from_bytes_offset(bytes: PackedByteArray, offset: int) -> FEAGI_Data_MotionControl:
	var output: FEAGI_Data_MotionControl = FEAGI_Data_MotionControl.new()
	output.move_left = bytes.decode_float(0 + offset)
	output.move_up = bytes.decode_float(4 + offset)
	output.move_down = bytes.decode_float(8 + offset)
	output.move_right = bytes.decode_float(12 + offset)
	
	output.roll_left = bytes.decode_float(16 + offset)
	output.move_forward = bytes.decode_float(20 + offset)
	output.move_backward = bytes.decode_float(24 + offset)
	output.roll_right = bytes.decode_float(28 + offset)
	
	output.yaw_left = bytes.decode_float(32 + offset)
	output.pitch_forward = bytes.decode_float(36 + offset)
	output.pitch_backward = bytes.decode_float(40 + offset)
	output.yaw_right = bytes.decode_float(44 + offset)
	return output

## Cause having over 20 FPS is overrated
static func create_from_FEAGI_JSON(dict: Dictionary) -> FEAGI_Data_MotionControl:
	var output: FEAGI_Data_MotionControl = FEAGI_Data_MotionControl.new()
	if dict.has("move_up"):
		output.move_up = dict["move_up"]
	if dict.has("move_down"):
		output.move_down = dict["move_down"]
	if dict.has("move_left"):
		output.move_left = dict["move_left"]
	if dict.has("move_right"):
		output.move_right = dict["move_right"]
	if dict.has("yaw_left"):
		output.yaw_left = dict["yaw_left"]
	if dict.has("yaw_right"):
		output.yaw_right = dict["yaw_right"]
	if dict.has("roll_left"):
		output.roll_left = dict["roll_left"]
	if dict.has("roll_right"):
		output.roll_right = dict["roll_right"]
	if dict.has("pitch_forward"):
		output.pitch_forward = dict["pitch_forward"]
	if dict.has("pitch_backward"):
		output.pitch_backward = dict["pitch_backward"]
	if dict.has("move_forward"):
		output.move_forward = dict["move_forward"]
	if dict.has("move_backward"):
		output.move_backward = dict["move_backward"]
	return output

func to_bytes() -> PackedByteArray:
	var arr: PackedFloat32Array = PackedFloat32Array([move_left, move_up, move_down, move_right, roll_left, move_forward, move_backward, roll_right, yaw_left, pitch_forward, pitch_backward, yaw_right])
	return arr.to_byte_array()

func get_translation_forward() -> float:
	return move_forward - move_backward

func get_translation_vertical() -> float:
	return move_up - move_down

func get_translation_horizontal() -> float:
	return move_right - move_left

func get_yaw() -> float:
	return yaw_right - yaw_left
	
func get_roll() -> float:
	return roll_right - roll_left

func get_pitch() -> float:
	return pitch_forward - pitch_backward

## Returns a delta vector2 if changes in rotation pitch (up down) and yaw (left right), like the camera in an FPS game
func get_first_person_rotation_delta() -> Vector2:
	return Vector2(yaw_right - yaw_left, pitch_backward - pitch_forward)
	
## Returns a delta vector2 representing up down / left right movement, like for a top down 2D game
func get_2D_movement_delta() -> Vector2:
	return Vector2(move_right - move_left, move_up - move_down)
	
