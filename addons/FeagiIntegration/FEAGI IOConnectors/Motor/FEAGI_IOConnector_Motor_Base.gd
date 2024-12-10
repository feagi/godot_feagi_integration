@tool
extends FEAGI_IOConnector_Base
class_name FEAGI_IOConnector_Motor_Base

enum INPUT_EMULATOR_DATA_TYPE{
	FLOAT_0_TO_1, # 0 to 1
	FLOAT_M1_TO_1, # -1 to 1,
	VEC2 # Vector2(0,0) to Vector2(1,1)
}

@export var InputEmulators: Array[FEAGI_EmuInput_Abstract] = [] ## A sequence of Input Emulators (or nulls) that are ordered to match certain usecases. This is set by the editor

var _function_to_interact_with_godot_with: Callable = Callable() ## Function that will be called with the single expected argument type that this motor type outputs. This callable will interact with FEAGI

## Updates the cache with the latest data from FEAGI
func update_cache_with_latest_FEAGI_data(new_data: PackedByteArray) -> void:
	_cached_bytes = new_data
	if _function_to_interact_with_godot_with.is_valid():
		_parse_FEAGI_raw_data(_cached_bytes)

# Register a registration agent to this device
func register_registration_agent_motor(data_receiving_function: Callable) -> FEAGI_IOConnector_Motor_Base:
	if !_function_to_interact_with_godot_with.is_null():
		push_warning("FEAGI: A motor attempted to register itself to %s when it was already registered to another motor! Overwriting the registration!" % device_friendly_name)
	_function_to_interact_with_godot_with = data_receiving_function
	_is_registered_to_registration_agent = true
	return self

## Have a sensor deregister itself
func deregister_registration_agent_motor() -> void:
	if _function_to_interact_with_godot_with.is_null():
		push_warning("FEAGI: A call to deregister motor %s was made when it had nothing registered anyways! Skipping!" % device_friendly_name)
		return
	_function_to_interact_with_godot_with = Callable()
	_is_registered_to_registration_agent = false

## Get ordered list of names of possible inputs to emulate. Each child class has these hard coded Length of this must == Length get_InputEmulator_data_types
func get_InputEmulator_names() -> Array[StringName]:
	assert(false, "Do not use 'FEAGI_IOConnector_Motor_Base' Directly!")
	return []

## Get ordered list of data types of possible inputs to emulate. Each child class has these hard coded.
func get_InputEmulator_data_types() -> Array[INPUT_EMULATOR_DATA_TYPE]:
	assert(false, "Do not use 'FEAGI_IOConnector_Motor_Base' Directly!")
	return []

## If callable is valid, upon recvieving the byte data from feagi, parse the data into the expected form and execute the callable on it
func _parse_FEAGI_raw_data(raw_FEAGI_data: PackedByteArray) -> void:
	assert(false, "Do not use 'FEAGI_IOConnector_Motor_Base' Directly!")
	# parse the byte data into the expected data type, then run "_function_to_interact_with_godot_with" on it
	return
