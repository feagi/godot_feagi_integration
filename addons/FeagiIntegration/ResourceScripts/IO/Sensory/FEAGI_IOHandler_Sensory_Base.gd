@tool
extends FEAGI_IOHandler_Base
class_name FEAGI_IOHandler_Sensory_Base
## Base class for all Sensory IO objects (for sending data to FEAGI)

var _data_grabber: Callable = Callable() # WARNING: Make sure for the proper class, that this callable returns the expected type

## Get data to be outputted to FEAGI and the debugger
func get_data_as_byte_array() -> PackedByteArray:
	assert(false, "Do not use 'FEAGI_IOHandler_Sensory_Base' Directly!")
	return PackedByteArray()

## Most sensors will just need this to define their creation to the debugger
func get_debug_interface_device_creation_array() -> Array:
	return [false, get_device_type(), device_name]
	# [bool is motor, str device type, str name of device]
	

# Register a godot device to this device
func register_godot_device_sensor(data_grabbing_function: Callable) -> void:
	if !_data_grabber.is_null():
		push_warning("FEAGI: A sensor attempted to register itself to %s when it was already registered to another sensor! Overwriting the registration!" % device_name)
	_data_grabber = data_grabbing_function
	_is_registered_to_godot_device = true

## Have a sensor deregister itself
func deregister_godot_device_sensor() -> void:
	if _data_grabber.is_null():
		push_warning("FEAGI: A call to deregister sensor %s was made when it had nothing registered anyways! Skipping!" % device_name)
		return
	_data_grabber = Callable()
	_is_registered_to_godot_device = false
