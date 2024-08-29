extends Resource
class_name FEAGIRegistrationAgentBase
## This object is a member of any nodes that can interact with FEAGI. Handles registration

#TODO multi device name registration?

@export var device_name_on_startup: StringName = ""
@export var attempt_registeration_on_startup: bool = true

var _device_type_name: StringName = ""
var _device_name: StringName
var _is_registered: bool = false

func _init() -> void:
	_device_name = device_name_on_startup

## Query if this device is registered
func is_registered() -> bool:
	return _is_registered

## Get the name of the device this is currently using!
func get_current_device_name() -> StringName:
	return _device_name

## Set a new device name for this device. Note this will only work if this device is currently not registered to FEAGI
func set_current_device_name(new_name: StringName) -> void:
	if _is_registered:
		push_error("FEAGI: Cannot change device name from %s to %s while it is currently registered! Ignoring name change request!" % [_device_name, new_name])
		return
	_device_name = new_name

func register_device() -> void:
	if _device_type_name.is_empty():
		push_error("FEAGI: Unknown device type attempted to register. Was the registration function called too early before the device was setup?")
		return
	if _device_name.is_empty():
		push_error("FEAGI: Device of type %s attempted to register without having a device name! Did you forget to define the device name?" % _device_type_name)
		return
	if _is_registered:
		push_warning("FEAGI: Device %s attempted to register to FEAGI when it was already registered! Ignoring!" % _device_type_name)
		return
	var registration_target: FEAGIIOBase = _register_device()
	if registration_target:
		_is_registered = true

func deregister_device() -> void:
	if _device_type_name.is_empty():
		push_error("FEAGI: Unknown device type attempted to deregister. Was the deregistration function called too early before the device was setup?")
		return
	if _device_name.is_empty():
		push_error("FEAGI: Device of type %s attempted to deregister without having a device name! Did you forget to define the device name?" % _device_type_name)
		return
	if !_is_registered:
		push_warning("FEAGI: Device %s attempted to deregister to FEAGI when it wasnt registered already! Ignoring!" % _device_type_name)
		return
	var deregistration_target: FEAGIIOBase = _deregister_device()
	if deregistration_target:
		_is_registered = false
	

## OVERRIDDEN in the child classes to handle proper registration procedures
func _register_device() -> FEAGIIOBase:
	assert(false, "Do not use FEAGIRegistrationAgentBase directly for FEAGI devices!")
	return null

## OVERRIDDEN in the child classes to handle proper deregistration procedures
func _deregister_device() -> FEAGIIOBase:
	assert(false, "Do not use FEAGIRegistrationAgentBase directly for FEAGI devices!")
	return null
