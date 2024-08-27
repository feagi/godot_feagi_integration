@tool
extends FEAGIIOBase
class_name FEAGISensoryBase
## A base class for all sensory components (such as cameras), virtual devices that send datat to FEAGI

signal finished_processing_data_for_tick() 

var output_data: PackedByteArray

func get_data_as_byte_array() -> PackedByteArray:
	assert(true, "Do not use 'FEAGISensoryBase' Directly!")
	return PackedByteArray()

#TODO
