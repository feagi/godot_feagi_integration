@tool
extends FEAGI_Device_Base
class_name FEAGI_Device_Motor_Base

var _function_to_interact_with_godot_with: Callable = Callable() ## Function that will be called with the single expected argument type that this motor type outputs. This callable will interact with FEAGI

## Updates the cache with the latest data from FEAGI
func update_cache_with_latest_FEAGI_data(new_data: PackedByteArray) -> void:
	_cached_bytes = new_data
	if _function_to_interact_with_godot_with.is_valid():
		_parse_FEAGI_raw_data(_cached_bytes)

# Register a godot device to this device
func register_godot_device_motor(data_receiving_function: Callable) -> FEAGI_Device_Motor_Base:
	if !_function_to_interact_with_godot_with.is_null():
		push_warning("FEAGI: A motor attempted to register itself to %s when it was already registered to another motor! Overwriting the registration!" % device_friendly_name)
	_function_to_interact_with_godot_with = data_receiving_function
	_is_registered_to_godot_device = true
	return self

## Have a sensor deregister itself
func deregister_godot_device_motor() -> void:
	if _function_to_interact_with_godot_with.is_null():
		push_warning("FEAGI: A call to deregister motor %s was made when it had nothing registered anyways! Skipping!" % device_friendly_name)
		return
	_function_to_interact_with_godot_with = Callable()
	_is_registered_to_godot_device = false

## If callable is valid, upon recvieving the byte data from feagi, parse the data into the expected form and execute the callable on it
func _parse_FEAGI_raw_data(raw_FEAGI_data: PackedByteArray) -> void:
	assert(false, "Do not use 'FEAGI_Device_Motor_Base' Directly!")
	# parse the byte data into the expected data type, then run "_function_to_interact_with_godot_with" on it
	return
