@tool
extends Resource
class_name FEAGI_IOConnector_Base
## Base class for all FEAGI Devices. A FEAGI Device is a definition / endpoint / representation for a device found on FEAGI itself.

@export var device_friendly_name: StringName ## What the device is named in FEAGI
@export var FEAGI_index: int
@export var device_ID: int
@export var is_disabled: bool

var is_registered_to_registration_agent: bool:  ## Is this FEAGI device currently suscribed to something?
	get: return _is_registered_to_registration_agent

var _is_registered_to_registration_agent: bool = false
var _cached_bytes: PackedByteArray = [] ## The last state of the device as bytes. Either read from game in the case of a sensor or the last thing retrieved from FEAGI in the case of a motor

## Returns the device name type as FEAGI configurator json expects
func get_device_type() -> StringName:
	# override me in all child device classses to easily get the FEAGI string name of the class
	assert(false, "Do not use 'FEAGI_IOConnector_Base' Directly!")
	return ""

## Most devices will just need this to define their creation to the debugger
func get_debug_interface_device_creation_array() -> Array:
	return [get_device_type(), device_friendly_name]
	# [str device type, str name of device]

## Get the latest cached data of this device (either sensor or motor). NOTE that you need to call for updates to the cache to keep this recent!
func get_cached_data_as_byte_array() -> PackedByteArray:
	return _cached_bytes

## Returns the byte array of if this device was in its "0" state
func retrieve_zero_value_byte_array() -> PackedByteArray:
	assert(false, "Do not use 'FEAGI_IOConnector_Base' Directly!")
	return PackedByteArray()


## A bunch of functions for parsing standard types back, and forth
#region parsers
var _cached_packed_float_array: PackedFloat32Array ## A lot of parsing uses this is a middle step, caching slightly benifits performance
var _cached_dictionary: Dictionary ## Ditto
var _cached_int: int ## Ditto

func _parse_bytes_as_float(bytes: PackedByteArray) -> float:
	return bytes.decode_float(0)

func _parse_bytes_as_vector3(bytes: PackedByteArray) -> Vector3:
	_cached_packed_float_array = bytes.to_float32_array()
	return Vector3(_cached_packed_float_array[0], _cached_packed_float_array[1], _cached_packed_float_array[2])

## WARNING Assumes the length of the bytes is congruent to the number of key names!
func _parse_bytes_as_json_dict_of_floats(bytes: PackedByteArray, key_names: PackedStringArray) -> Dictionary:
	_cached_int = 0
	for key in key_names:
		_cached_dictionary[key] = bytes.decode_float(_cached_int * 4)
		_cached_int += 1
	return _cached_dictionary

## WARNING: Assumes _cached_bytes is already a of length 4 to hold the value!
func _parse_float_into_byte_cache(input_float: float) -> void:
	_cached_bytes.encode_float(0, input_float)

## WARNING: Assumes _cached_bytes is already a of length 12 to hold the value!
func _parse_vector3_into_byte_cache(vector: Vector3) -> void:
	_cached_bytes.encode_float(0, vector.x)
	_cached_bytes.encode_float(4, vector.y)
	_cached_bytes.encode_float(8, vector.z)

## WARNING: Assumes _cached_bytes is long enough, and that all keys in the input dict match key_names!
func _parse_json_dict_of_floats_into_byte_cache(dict: Dictionary, key_names: PackedStringArray) -> void:
	_cached_int = 0
	for key in key_names:
		_cached_bytes.encode_float(_cached_int * 4, dict[key])
		_cached_int += 1
#endregion
