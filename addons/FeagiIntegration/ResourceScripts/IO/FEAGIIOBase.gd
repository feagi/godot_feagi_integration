@tool
extends Resource
class_name FEAGIIOBase
## Base class for all IO objects (for recieving and sending data to FEAGI)

@export var device_name: StringName
@export var FEAGI_index: int
@export var device_ID: int

## Easy way to set all required base settings
func setup_required_base_settings(name_of_device: StringName, index_FEAGI: int, ID_device: int) -> void:
	device_name = name_of_device
	FEAGI_index = index_FEAGI
	device_ID = ID_device

## Called after all nodes in the tree are ready
func post_initialize_required_dependencies() -> void:
	assert(true, "Do not use 'FEAGIIOBase' Directly!")
	pass

## Called by debug views to return data used for showing current state of things
func get_debug_data() -> Variant:
	assert(true, "Do not use 'FEAGIIOBase' Directly!")
	return null
