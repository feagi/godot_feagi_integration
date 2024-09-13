extends RefCounted
class_name FEAGI_RunTime_FEAGIDeviceManager
## Handles all FEAGI Devices ([FEAGI_IOHandler_Base]). NOTE that these are static after initialization, you cannot change feagi device mappings!
## Not to be confused with [FEAGI_RunTime_GodotDeviceManager) which works with dynamic Godot Devices! Game Devleopers likely don't need to interact with this class!

var _debug_interface: FEAGI_RunTime_DebugInterface
var _FEAGI_interface: FEAGI_RunTime_FEAGIInterface

var _FEAGI_sensors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_IOHandler_Sensory_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_sensors_reference_arr: Array[FEAGI_IOHandler_Sensory_Base] # cached since "values" is slow
var _FEAGI_motors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_IOHandler_Motor_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_motors_reference_arr: Array[FEAGI_IOHandler_Motor_Base] # cached since "values" is slow

var _is_ready: bool = false


func _init(reference_to_FEAGI_sensors: Dictionary, reference_to_FEAGI_motors: Dictionary) -> void:
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	_FEAGI_sensors_reference_arr.assign(_FEAGI_sensors_reference.values())
	_FEAGI_motors_reference = reference_to_FEAGI_motors
	_FEAGI_motors_reference_arr.assign(_FEAGI_motors_reference.values())


## Initializes the debugger with all FEAGI Devices!
func setup_debugger() -> void:
	_debug_interface = FEAGI_RunTime_DebugInterface.new()
	for sensor: FEAGI_IOHandler_Sensory_Base in _FEAGI_sensors_reference_arr:
		_debug_interface.alert_debugger_about_sensor_creation(sensor)
	for motor: FEAGI_IOHandler_Motor_Base in _FEAGI_motors_reference_arr:
		_debug_interface.alert_debugger_about_motor_creation(motor)
		

func on_sensor_tick() -> void:
	# Update all sensor values
	for sensor_IO in _FEAGI_sensors_reference_arr:
		sensor_IO.refresh_cached_sensory_data() # ensure all the data is fresh!
		
	if _debug_interface:
		_debug_interface.alert_debugger_about_sensor_update()
	if _FEAGI_interface:
		_FEAGI_interface.on_tick()

func on_retrieved_motor_data_from_FEAGI(data: PackedByteArray) -> void:
	pass
