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
	if !OS.is_debug_build():
		push_warning("FEAGI: This is a non-debug build, yet debugging is enabled as per config. Ignoring config and not enabling the debugger...")
		_debug_interface = null
		return
	if FEAGI_JS.is_web_build():
		push_warning("FEAGI: This is a web build, yet debugging is enabled as per config. Ignoring config and not enabling the debugger...")
		_debug_interface = null
		return
	_debug_interface = FEAGI_RunTime_DebugInterface.new()
	for sensor: FEAGI_Device_Sensor_Base in _FEAGI_sensors_reference_arr:
		_debug_interface.alert_debugger_about_sensor_creation(sensor)
	for motor: FEAGI_Device_Motor_Base in _FEAGI_motors_reference_arr:
		_debug_interface.alert_debugger_about_motor_creation(motor)

## An ASYNC function that initiates the API and websocket conneciton to FEAGI and the connector, but nothing else. Returns true if succesful
func setup_FEAGI_networking(endpoint: FEAGI_Resource_Endpoint, parent_node: Node) -> bool:
	_FEAGI_interface = FEAGI_RunTime_FEAGIInterface.new()
	_FEAGI_interface.socket_closed.connect(_on_socket_close)
	_FEAGI_interface.name = "FEAGI Networking"
	parent_node.add_child(_FEAGI_interface)
	
	if FEAGI_JS.is_web_build() and endpoint.contains_all_URL_parameters_needed_for_URL_parsing():
		push_warning("FEAGI: Please note that any Web URL parameters from the endpoint file are ignored as we loaded them directly from URL Parameters instead")
		endpoint.update_internal_vars_from_URL_parameters()
	else:
		if endpoint.contains_magic_link():
			if !await endpoint.update_internal_vars_from_magic_link(parent_node):
				# failed get endpoints from magic link
				push_error("FEAGI: Failed to get endpoint information from supplied magic link!")
				return false
			print("FEAGI: Updated endpoint information from supplied magic link!")
			# We updated the endpoints from magic link!
			
	print("FEAGI: Network prep complete! Using %s for FEAGI endpoint and %s for WS endpoint!" % [endpoint.get_full_FEAGI_API_URL(), endpoint.get_full_connector_ws_URL()])
	# check HTTP connection
	var is_FEAGI_available: bool = await _FEAGI_interface.ping_feagi_available(endpoint.get_full_FEAGI_API_URL())
	if not is_FEAGI_available:
		push_error("FEAGI: Unable to connect to FEAGI API at %s!" % endpoint.get_full_FEAGI_API_URL())
		_FEAGI_interface = null
		return false
	print("FEAGI: Confirmed FEAGI HTTP connection at %s!" % endpoint.get_full_FEAGI_API_URL())
	
	# establish WS connection, but do not send data
	var connected_to_ws: bool = await _FEAGI_interface.setup_websocket(endpoint.get_full_connector_ws_URL())
	if not connected_to_ws:
		push_error("FEAGI: Unable to connect to connector websocket at %s!" % endpoint.get_full_connector_ws_URL())
		_FEAGI_interface = null
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
	if FEAGI_JS.is_web_build():
		var configurator: Dictionary = JSON.parse_string(initial_configurator_json)
		configurator = FEAGI_JS.overwrite_config(configurator)
		initial_configurator_json = JSON.stringify(configurator)
	
	# send param over socket
	_FEAGI_interface.send_final_configurator_JSON(initial_configurator_json)
	print("FEAGI: Sent the Configurator JSON!")
	
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
