@tool
extends FEAGI_IOHandler_Base
class_name FEAGI_IOHandler_Sensory_Base
## A base class for all sensory components (such as cameras), virtual devices that send datat to FEAGI

signal finished_processing_data_for_tick() 

var output_data: PackedByteArray

var _data_grabber: Callable = Callable() # Make sure for the proper class, that this callable returns the expected type

func get_data_as_byte_array() -> PackedByteArray:
	assert(false, "Do not use 'FEAGISensoryBase' Directly!")
	return PackedByteArray()

# Register a sensor to this object
func register_sensor(data_grabbing_function: Callable) -> void:
	if !_data_grabber.is_null():
		push_warning("FEAGI: A sensor attempted to register itself to %s when it was already registered to another sensor! Overwriting the registration!" % device_name)
	_data_grabber = data_grabbing_function

## Have a sensor deregister itself
func deregister_sensor() -> void:
	if _data_grabber.is_null():
		push_warning("FEAGI: A call to deregister sensor %s was made when it had nothing registered anyways! Skipping!" % device_name)
		return
	_data_grabber = Callable()
#TODO
