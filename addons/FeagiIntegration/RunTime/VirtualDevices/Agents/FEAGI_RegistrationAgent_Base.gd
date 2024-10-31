extends Resource
class_name FEAGI_RegistrationAgent_Base
## Base class for handling Registration Agents registering to FEAGI Devices

@export var default_device_name: StringName = "" ## The name of the FEAGI device this will connect to. MUST MATCH EXACTLY

var _is_registered_with: FEAGI_IOConnector_Base = null
var _registered_device_type: StringName = "INVALID" # NOTE: On init of child classes, this is filled in properly
var _registered_device_name: StringName
var _registered_callable: Callable

## Is this agent registered under a FEAGI device?
func is_registered() -> bool:
	return _is_registered_with != null

func get_device_type() -> StringName:
	return _registered_device_type
	
func get_device_name() -> StringName:
	return _registered_device_name

## Attempts to register to FEAGI this Registration Agent by its callable
func register_with_FEAGI(callable: Callable, override_device_type: StringName = _registered_device_type, override_device_name: StringName = default_device_name) -> bool:
	# override me in all child device classses to easily get the FEAGI string name of the class
	assert(false, "Do not use 'FEAGI_RegistrationAgent_Base' Directly!")
	return false

func _check_if_registration_valid_base(callable: Callable, device_name: StringName) -> bool:
	if device_name.is_empty():
		push_error("FEAGI: Device name for agent cannot be empty! Refusing to allow registration!")
		_is_registered_with = null
		return false
	if callable.is_null():
		push_error("FEAGI: The given callable does not seem valid!")
		_is_registered_with = null
		return false
	if is_registered():
		push_error("FEAGI: This Registration Agent is already registered to a FEAGI Device and cannot register again!")
		return false
	return true
