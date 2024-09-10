extends RefCounted
class_name FEAGI_RunTime_FEAGIDeviceManager
## Handles all FEAGI Devices ([FEAGI_IOHandler_Base]). NOTE that these are static after initialization, you cannot change feagi device mappings!
## Not to be confused with [FEAGI_RunTime_GodotDeviceManager) which works with dynamic Godot Devices!

var _debug_interface: FEAGI_RunTime_DebugInterface

var _FEAGI_sensors_reference: Dictionary ## WARNING: For performance reasons, we pass this by reference, and changes may occur to this dictionary outside this class. Be EXTREMELY careful with caching!
var _is_ready: bool = false

## Called from [FEAGI_RunTime] To initialize this object with all FEAGI Devices
func setup(reference_to_FEAGI_sensors: Dictionary, enable_debug: bool, enable_FEAGI: bool) -> void: #TODO add motors
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	
	if enable_debug:
		_debug_interface = FEAGI_RunTime_DebugInterface.new()
		for sensor: FEAGI_IOHandler_Sensory_Base in _FEAGI_sensors_reference.values():
			_debug_interface.alert_debugger_about_device_creation(sensor)
		
	
	
	_is_ready = true
	
	
