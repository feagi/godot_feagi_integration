extends Resource
class_name FEAGI_RunTime_GodotDeviceAgent_Base
## Handles base functions required for device registration. This base class should not be used directly

#TODO multi device name registration?

# NOTE: This enum should contain enteries both from [FEAGI_PLUGIN].GODOT_SUPPORTED_SENSORS and [FEAGI_PLUGIN].GODOT_SUPPORTED_MOTORS
@export_enum("camera", "motion_control") var initial_device_type_of_agent: String ## The type of this device. Note this can be overridden from the setup function
@export var initial_device_name_to_map_to_FEAGI: StringName ## The name of this device that will be mapped to FEAGI. Note this can be overridden from the setup function

var _device_type_name: StringName = ""
var _device_name: StringName
var _is_ready_for_registration: bool = false
var _is_registered: bool = false

func is_ready_for_registration() -> bool:
	return _is_ready_for_registration

func is_registered() -> bool:
	return _is_registered

func get_device_type() -> StringName:
	return _device_type_name

func get_device_name() -> StringName:
	return _device_name


func register_device() -> void:
	if not _is_ready_for_registration:
		push_error("FEAGI: Godot Device Agent is not ready for registration! Have you run the setup function on it?")
		return
	if _is_registered:
		push_warning("FEAGI: Device %s attempted to register to FEAGI when it was already registered! Ignoring!" % _device_type_name)
		return
	if _register_device(): # returns true if successful
		_is_registered = true

func deregister_device() -> void:
	if !_is_registered:
		push_warning("FEAGI: Device %s attempted to deregister to FEAGI when it wasnt registered already! Ignoring!" % _device_type_name)
		return
	if _deregister_device(): # returns true if successful
		_is_registered = false


## Checks if setup variables are valid and sets them. Returns True if succeeds. Called from setup_for_X_registration from child classes
func _base_setup_agent_for_registration(allowed_types: PackedStringArray, allowed_names: PackedStringArray, 
device_type: StringName = initial_device_type_of_agent, device_name: StringName = initial_device_name_to_map_to_FEAGI) -> bool:
	#NOTE: This function does not set _is_ready_for_registration to true! That is handled by the child classes!
	
	if device_type.is_empty():
		push_error("FEAGI: Device type for agent cannot be empty! Refusing to allow registration!")
		return false
	if device_type not in allowed_types:
		push_error("FEAGI: Device type %s not allowed by the plugin! Refusing to allow registration!" % device_type)
		return false
	_device_type_name = device_type
		
	if device_name.is_empty():
		push_error("FEAGI: Device name for agent cannot be empty! Refusing to allow registration!")
		return false
	if device_name not in allowed_names:
		push_error("FEAGI: Device name %s is not found as a registered fdevice from the loaded FEAGI config! Refusing to allow registration!" % device_type)
		return false
	_device_name = device_name
	return true


## OVERRIDDEN in the child classes to handle proper registration procedures. Returns if registration was succesful
func _register_device() -> bool:
	assert(false, "Do not use FEAGI_RunTime_GodotDeviceAgent_Base directly for FEAGI devices!")
	return false

## OVERRIDDEN in the child classes to handle proper deregistration procedures Returns if deregistration was succesful
func _deregister_device() -> bool:
	assert(false, "Do not use FEAGI_RunTime_GodotDeviceAgent_Base directly for FEAGI devices!")
	return false
