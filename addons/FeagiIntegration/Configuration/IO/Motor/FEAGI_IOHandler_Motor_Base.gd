extends FEAGI_IOHandler_Base
class_name FEAGI_IOHandler_Motor_Base

var _data_reciever: Callable = Callable() # WARNING: Make sure for the proper class, that this callable accepts the expected type

## Data retrieved right from FEAGI, process the data and alert whatever is connected to the motor
func update_state_with_retrieved_date(new_data: PackedByteArray) -> void:
	#NOTE: Right now most child classes override this since data is being sent as dicts, which isnt good performance wise.
	_cached_data = new_data
	_process_raw_data(new_data)

# Register a godot device to this device
func register_godot_device_sensor(data_receiving_function: Callable) -> void:
	if !_data_reciever.is_null():
		push_warning("FEAGI: A motor attempted to register itself to %s when it was already registered to another motor! Overwriting the registration!" % device_name)
	_data_reciever = data_receiving_function
	_is_registered_to_godot_device = true

## Have a sensor deregister itself
func deregister_godot_device_sensor() -> void:
	if _data_reciever.is_null():
		push_warning("FEAGI: A call to deregister motor %s was made when it had nothing registered anyways! Skipping!" % device_name)
		return
	_data_reciever = Callable()
	_is_registered_to_godot_device = false

## Overridden in children, takes the raw data and processes it to a more readable form before executing it in the given callable
func _process_raw_data(raw_data: PackedByteArray) -> void:
	assert(false, "Do not use 'FEAGI_IOHandler_Motor_Base' Directly!")
	return
