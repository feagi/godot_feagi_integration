@tool
extends Resource
class_name FEAGI_IOHandler_Base
## Base class for all IO objects (for recieving and sending data to FEAGI)
## WARNING: Do NOT use this class directly. Use one of the actual device type classes

@export var device_name: StringName
@export var FEAGI_index: int
@export var device_ID: int
@export var is_disabled: bool

var is_registered_to_godot_device: bool:
	get: return _is_registered_to_godot_device

var _is_registered_to_godot_device: bool = false

func get_device_type() -> StringName:
	# override me in all child device classses to easily get the FEAGI string name of the class
	assert(false, "Do not use 'FEAGI_IOHandler_Base' Directly!")
	return ""

## The debugger needs information in order to create the correct view type in the debugger panel. This creates that array
func get_debug_interface_device_creation_array() -> Array:
	assert(false, "Do not use 'FEAGI_IOHandler_Base' Directly!")
	return [] # NOTE: Array follows this format -> [bool is_motor, str device_type_name, str device_name, (ONLY IN SOME DEVICES: Variant extra parameter(s)]
	
## Get data of this device (reading from a sensor or cached value from a motor)
func get_data_as_byte_array() -> PackedByteArray:
	assert(false, "Do not use 'FEAGI_IOHandler_Sensory_Base' Directly!")
	return PackedByteArray()
