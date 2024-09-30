@tool
extends FEAGI_Device_Base
class_name FEAGI_Device_Sensor_Base

var _function_to_grab_from_godot_with: Callable = Callable() ## A function given by the user that when called, returns sensory data that we cache for sending to FEAGI. This callable should return the type expected of the particular sensor, and it will be processed to a byte array here 


## Updates the cache with the latest sensory information (if the callable is valid, otherwise falls back to backup)
func update_cache_with_sensory_call() -> void:
	if _function_to_grab_from_godot_with.is_valid():
		_process_sensor_input_for_cache_using_callable()
		return
	_fallback_sensory_update_when_no_callable()

# Register a godot device to this FEAGI device
func register_godot_device_sensor(data_grabbing_function: Callable) -> FEAGI_Device_Sensor_Base:
	if !_function_to_grab_from_godot_with.is_null():
		push_warning("FEAGI: A sensor attempted to register itself to %s when it was already registered to another sensor! Overwriting the registration!" % device_friendly_name)
	_function_to_grab_from_godot_with = data_grabbing_function
	_is_registered_to_godot_device = true
	return self

## Have a sensor deregister itself
func deregister_godot_device_sensor() -> void:
	if _function_to_grab_from_godot_with.is_null():
		push_warning("FEAGI: A call to deregister sensor %s was made when it had nothing registered anyways! Skipping!" % device_friendly_name)
		return
	_function_to_grab_from_godot_with = Callable()
	_is_registered_to_godot_device = false


## Given the user defined callable exists, call it , and child classes will do neccasry processing to it to turn that data type into a byte array
func _process_sensor_input_for_cache_using_callable() -> void:
	# Inside here, run _function_to_grab_from_godot_with, then process the data into a [PackedByteArray] and store it in _cached_bytes
	assert(false, "Do not use 'FEAGI_Device_Sensor_Base' Directly!")
	_cached_bytes = PackedByteArray()

## In the case of no user defined callable (due to a lack of device registration. This call will be called instead. Usually returning the previous data is fine, but some child classes may override this
func _fallback_sensory_update_when_no_callable() -> void:
	# type here whatever _cached_bytes should equal, or dont override this function to just do nothing
	return
