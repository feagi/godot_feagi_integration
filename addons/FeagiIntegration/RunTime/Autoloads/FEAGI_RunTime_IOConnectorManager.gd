extends RefCounted
class_name FEAGI_RunTime_IOConnectorManager
## Handles all FEAGI Devices ([FEAGI_IOHandler_Base]). NOTE that these are static after initialization, you cannot change feagi device mappings!
## Not to be confused with [FEAGI_RunTime_RegistrationAgentManager) which works with dynamic Registration Agents! Game Devleopers likely don't need to interact with this class!

var _debug_interface: FEAGI_RunTime_DebugInterface
var _FEAGI_interface: FEAGI_RunTime_FEAGIInterface


var _FEAGI_sensors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_IOConnector_Sensor_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_sensors_reference_arr: Array[FEAGI_IOConnector_Sensor_Base] # cached since "values" is slow
var _FEAGI_motors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_IOConnector_Motor_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_motors_reference_arr: Array[FEAGI_IOConnector_Motor_Base] # cached since "values" is slow


func _init(reference_to_FEAGI_sensors: Dictionary, reference_to_FEAGI_motors: Dictionary) -> void:
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	_FEAGI_sensors_reference_arr.assign(_FEAGI_sensors_reference.values())
	_FEAGI_motors_reference = reference_to_FEAGI_motors
	_FEAGI_motors_reference_arr.assign(_FEAGI_motors_reference.values())


func setup_external_interface(connector_to_init: FEAGI_NetworkingConnector_Base, init_call: Callable, parent_node: Node, is_debugger_enabled: bool) -> bool:
	_FEAGI_interface = FEAGI_RunTime_FEAGIInterface.new()
	_FEAGI_interface.name = "FEAGI Interface"
	parent_node.add_child(_FEAGI_interface)
	
	if is_debugger_enabled:
		if _setup_debugger():
			_FEAGI_interface.interface_recieved_motor_data.connect(_debug_interface.alert_debugger_about_motor_update)
	
	if !await _FEAGI_interface.define_interface(connector_to_init, init_call):
		push_error("FEAGI: Unable to define interface!")
		return false # Interface isn't valid
	
	_FEAGI_interface.set_cached_device_dicts(_FEAGI_sensors_reference, _FEAGI_motors_reference)
	return true


func send_configurator_and_enable(initial_configurator_json: StringName) -> void:
	# check network active
	if !_FEAGI_interface:
		return
	if !_FEAGI_interface.connection_active:
		return
	
	# check URl params, update configurator
	if FEAGI_JS.is_web_build():
		var configurator: Dictionary = JSON.parse_string(initial_configurator_json)
		configurator = FEAGI_JS.overwrite_config(configurator)
		initial_configurator_json = JSON.stringify(configurator)
	
	# send param over socket
	_FEAGI_interface.send_final_configurator_JSON(initial_configurator_json)
	print("FEAGI: Sent the Configurator JSON!")


func on_sensor_tick() -> void:
	# Update all sensor values
	for sensor_IO in _FEAGI_sensors_reference_arr:
		sensor_IO.update_cache_with_sensory_call() # ensure all the data is fresh!
	
	if _debug_interface:
		_debug_interface.alert_debugger_about_sensor_update()
	if _FEAGI_interface:
		_FEAGI_interface.on_sensor_tick()

## Initializes the debugger with all FEAGI Devices! Returns true if succesful
func _setup_debugger() -> bool:
	if !OS.is_debug_build():
		push_warning("FEAGI: This is a non-debug build, yet debugging is enabled as per config. Ignoring config and not enabling the debugger...")
		_debug_interface = null
		return false
	if FEAGI_JS.is_web_build():
		push_warning("FEAGI: This is a web build, yet debugging is enabled as per config. Ignoring config and not enabling the debugger...")
		_debug_interface = null
		return false
	_debug_interface = FEAGI_RunTime_DebugInterface.new()
	for sensor: FEAGI_IOConnector_Sensor_Base in _FEAGI_sensors_reference_arr:
		_debug_interface.alert_debugger_about_sensor_creation(sensor)
	for motor: FEAGI_IOConnector_Motor_Base in _FEAGI_motors_reference_arr:
		_debug_interface.alert_debugger_about_motor_creation(motor)
	return true
