extends RefCounted
class_name FEAGI_RunTime_FEAGIDeviceManager
## Handles all FEAGI Devices ([FEAGI_IOHandler_Base]). NOTE that these are static after initialization, you cannot change feagi device mappings!
## Not to be confused with [FEAGI_RunTime_GodotDeviceManager) which works with dynamic Godot Devices! Game Devleopers likely don't need to interact with this class!

var _debug_interface: FEAGI_RunTime_DebugInterface
var _FEAGI_interface: FEAGI_RunTime_FEAGIInterface

var _FEAGI_sensors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_IOHandler_Sensory_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_sensors_reference_arr: Array[FEAGI_IOHandler_Sensory_Base] # cached since "values" is slow
var _is_ready: bool = false


func _init(reference_to_FEAGI_sensors: Dictionary) -> void:
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	_FEAGI_sensors_reference_arr.assign(_FEAGI_sensors_reference.values)


## Initializes the debugger with all FEAGI Devices!
func setup_debugger() -> void:
	_debug_interface = FEAGI_RunTime_DebugInterface.new()
	for sensor: FEAGI_IOHandler_Sensory_Base in _FEAGI_sensors_reference.values():
		_debug_interface.alert_debugger_about_sensor_creation(sensor)
	# TODO motor

func on_tick() -> void:
	# Update all sensor values
	for sensor_IO in _FEAGI_sensors_reference_arr:
		sensor_IO.refresh_cached_sensory_data() # ensure all the data is fresh!
		
	if _debug_interface:
		_debug_interface.alert_debugger_about_sensor_update()
	if _FEAGI_interface:
		_FEAGI_interface.on_tick()



## OLD
## Called from [FEAGI_RunTime] To initialize this object with all FEAGI Devices
func setup(reference_to_FEAGI_sensors: Dictionary, endpoint_details: FEAGI_Resource_Endpoint, configuration_JSON: StringName, enable_debug: bool, enable_FEAGI: bool) -> void: #TODO add motors
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	
	if enable_debug:
		_debug_interface = FEAGI_RunTime_DebugInterface.new()
		for sensor: FEAGI_IOHandler_Sensory_Base in _FEAGI_sensors_reference.values():
			_debug_interface.alert_debugger_about_device_creation(sensor)
		
	if enable_FEAGI:
		_FEAGI_interface = FEAGI_RunTime_FEAGIInterface.new()
		var result: bool = await _FEAGI_interface.setup(endpoint_details, configuration_JSON, reference_to_FEAGI_sensors)
		
		
	
	_is_ready = true
	
