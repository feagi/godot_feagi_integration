extends RefCounted
class_name FEAGI_RunTime_FEAGIDeviceManager
## Handles all FEAGI Devices ([FEAGI_IOHandler_Base]). NOTE that these are static after initialization, you cannot change feagi device mappings!
## Not to be confused with [FEAGI_RunTime_GodotDeviceManager) which works with dynamic Godot Devices! Game Devleopers likely don't need to interact with this class!

var _debug_interface: FEAGI_RunTime_DebugInterface
var _FEAGI_interface: FEAGI_RunTime_FEAGIInterface

var _FEAGI_sensors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_Device_Sensor_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_sensors_reference_arr: Array[FEAGI_Device_Sensor_Base] # cached since "values" is slow
var _FEAGI_motors_reference: Dictionary ## Key'd by the device name, value is the relevant [FEAGI_Device_Motor_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_motors_reference_arr: Array[FEAGI_Device_Motor_Base] # cached since "values" is slow


func _init(reference_to_FEAGI_sensors: Dictionary, reference_to_FEAGI_motors: Dictionary) -> void:
	_FEAGI_sensors_reference = reference_to_FEAGI_sensors
	_FEAGI_sensors_reference_arr.assign(_FEAGI_sensors_reference.values())
	_FEAGI_motors_reference = reference_to_FEAGI_motors
	_FEAGI_motors_reference_arr.assign(_FEAGI_motors_reference.values())


## Initializes the debugger with all FEAGI Devices!
func setup_debugger() -> void:
	_debug_interface = FEAGI_RunTime_DebugInterface.new()
	for sensor: FEAGI_Device_Sensor_Base in _FEAGI_sensors_reference_arr:
		_debug_interface.alert_debugger_about_sensor_creation(sensor)
	for motor: FEAGI_Device_Motor_Base in _FEAGI_motors_reference_arr:
		_debug_interface.alert_debugger_about_motor_creation(motor)

## And ASYNC function that initiates the API and websocket conneciton to FEAGI and the connector, but nothing else. Returns true if succesful
func setup_FEAGI_networking(endpoint: FEAGI_Resource_Endpoint, parent_node: Node) -> bool:
	_FEAGI_interface = FEAGI_RunTime_FEAGIInterface.new()
	_FEAGI_interface.socket_closed.connect(_on_socket_close)
	_FEAGI_interface.name = "FEAGI Networking"
	parent_node.add_child(_FEAGI_interface)
	
	# if have magic link, update values from it (TODO)
	if endpoint.contains_magic_link():
		pass #have endpoint querty magic link to update itself
		
		if FEAGI_JS.is_web_build():
			print("FEAGI: Please note that any Web URL parameters for endpoint settings are ignored as we loaded them from magic link instead")
	
	# otherwise if there are url parameters with endpoint settings
	elif FEAGI_JS.is_web_build():
		pass ## use endpoint to check URL parameters with endpoint settings
	
	# check HTTP connection
	var is_FEAGI_available: bool = await _FEAGI_interface.ping_feagi_available(endpoint.get_full_FEAGI_API_URL())
	if not is_FEAGI_available:
		push_error("FEAGI: Unable to connect to FEAGI API at %s!" % endpoint.get_full_FEAGI_API_URL())
		return false
	print("FEAGI: Confirmed FEAGI HTTP connection at %s!" % endpoint.get_full_FEAGI_API_URL())
	
	# establish WS connection, but do not send data
	var connected_to_ws: bool = await _FEAGI_interface.setup_websocket(endpoint.get_full_connector_ws_URL())
	if not connected_to_ws:
		push_error("FEAGI: Unable to connect to connector websocket at %s!" % endpoint.get_full_connector_ws_URL())
		return false
	print("FEAGI: Connected to connector websocket at %s!" % endpoint.get_full_connector_ws_URL())

	# setup cache device references
	_FEAGI_interface.set_cached_device_dicts(_FEAGI_sensors_reference, _FEAGI_motors_reference)
	
	return true

	

func send_configurator_and_enable(initial_configurator_json: StringName) -> void:
	# check network active
	if !_FEAGI_interface:
		return
	if !_FEAGI_interface.connection_active:
		return
	
	# check URl params, update configurator
	# TODO
	
	
	# send param over socket
	_FEAGI_interface.send_final_configurator_JSON(initial_configurator_json)
	
	# connect motor signals
	if _debug_interface:
		_FEAGI_interface.socket_recieved_motor_data.connect(_debug_interface.alert_debugger_about_motor_update)
	pass


func on_sensor_tick() -> void:
	# Update all sensor values
	for sensor_IO in _FEAGI_sensors_reference_arr:
		sensor_IO.update_cache_with_sensory_call() # ensure all the data is fresh!
	
	if _debug_interface:
		_debug_interface.alert_debugger_about_sensor_update()
	if _FEAGI_interface:
		_FEAGI_interface.on_sensor_tick()

func _on_socket_close() -> void:
	_FEAGI_interface = null