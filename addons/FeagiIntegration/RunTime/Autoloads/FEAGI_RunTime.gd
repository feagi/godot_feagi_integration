extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI

## TODO signals & vars for state
signal ready_for_registration_agent_registration()
signal ready_for_metric_posting()

var metric_reporting: FEAGI_RunTime_MetricReporting:
	get: return _metric_reporting

var registration_agent_manager: FEAGI_RunTime_RegistrationAgentManager = null
var _FEAGI_IOConnector_manager: FEAGI_RunTime_IOConnectorManager = null
var _automatic_device_generator: FEAGIAutomaticDeviceGenerator = null
var _tick_engine: FEAGI_RunTime_TickEngine = null
var _metric_reporting: FEAGI_RunTime_MetricReporting

var _FEAGI_sensors: Dictionary = {} ## Key'd by the device name, value is the relevant [FEAGI_IOConnector_Sensor_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_motors: Dictionary = {} ## ditto but with [FEAGI_IOConnector_Motor_Base]
var _registration_allowed: bool


func _enter_tree() -> void:
	initialize_FEAGI_runtime() ## TODO have seperate autoload autostart this as a config
	name = "FEAGI Runtime"

## Are Registration Agents allowed to register?
func is_ready_for_device_registration() -> bool:
	return _registration_allowed



# General overview of startup
# Read / verify configs, stop if not enabled
# Load in sensor / motor FEAGI Device objects
# Activate FEAGI Device manager, including the Debugger (if enabled) and the FEAGI Network Interface (if enabled)
# Activate Registration Agent Manager to act as an endpoint for Registration Agents to register themselves to
# Add all devices that have been requested to be auto-generated
# Initialize tick engine
func initialize_FEAGI_runtime(mapping_config: FEAGI_Genome_Mapping = null, endpoint_config: FEAGI_Resource_Endpoint = null) -> void:
	print("FEAGI Interface starting up!")
	
	var is_in_post_message_mode: bool = FEAGI_JS.attempt_get_parameter_from_URL("postmessage") != null ## In post message mode, we are using an emulated fake feagi runnign in browser
	
	# If the mapping config isnt defined, attempt to load it from disk. If still not defined -> failure
	if !mapping_config:
		if !FEAGI_PLUGIN_CONFIG.does_mapping_file_exist():
			push_error("FEAGI: No mapping settings file found on disk for FEAGI configuration! The FEAGI integration will now halt!")
			return
		else:
			mapping_config = load(FEAGI_PLUGIN_CONFIG.get_genome_mapping_path())
		if !mapping_config:
			push_error("FEAGI: Mapping settings file found but was unable to be read! The FEAGI integration will now halt!")
			return
	
	if !mapping_config.FEAGI_enabled:
		push_warning("FEAGI: FEAGI disabled as per configuration")
		return
	
	if !is_in_post_message_mode: # we dont care about this in post message mode
		# If endpoint isnt defined, attempt to load it from disk. If still not defined -> create one with localhost settings
		# NOTE: Regardless of what endpoint settings are in the object at this point, they can still be overwritten by URL parameters!
		if !endpoint_config:
			if !FEAGI_PLUGIN_CONFIG.does_endpoint_file_exist():
				push_warning("FEAGI: No endpoint settings were given or found on disk. Defaulting to localhost settings for initial endpoint!")
				endpoint_config = FEAGI_Resource_Endpoint.new()
			else:
				endpoint_config = load(FEAGI_PLUGIN_CONFIG.get_endpoint_path())
			if !endpoint_config:
				push_warning("FEAGI: Endpoint file found but was unable to be read! Defaulting to localhost settings for initial endpoint!")
				endpoint_config = FEAGI_Resource_Endpoint.new()
	
	if is_in_post_message_mode:
		push_warning("FEAGI: Loaded in PostMessage Mode! This means that we expect to use the browserside FakeFeagi. All Sensors will be disabled!")
	else:
		# Load in sensor FEAGI Device objects
		for incoming_FEAGI_sensor in mapping_config.sensors.values():
			if incoming_FEAGI_sensor is not FEAGI_IOConnector_Sensor_Base:
				push_error("FEAGI: Unknown object attempted to be added as a FEAGI Sensor! Skipping!")
				continue
			if (incoming_FEAGI_sensor as FEAGI_IOConnector_Sensor_Base).is_disabled:
				print("FEAGI: Sensor %s is disabled! Not using it for the debugger AND for FEAGI!" % (incoming_FEAGI_sensor as FEAGI_IOConnector_Sensor_Base).device_friendly_name)
				continue
			if (incoming_FEAGI_sensor as FEAGI_IOConnector_Sensor_Base).device_friendly_name in _FEAGI_sensors:
				push_error("FEAGI: Sensor %s is already defined! Ensure there are no sensor devices with repeating names! Skipping" % (incoming_FEAGI_sensor as FEAGI_IOConnector_Sensor_Base).device_friendly_name)
				continue
			_FEAGI_sensors[(incoming_FEAGI_sensor as FEAGI_IOConnector_Sensor_Base).device_friendly_name] = incoming_FEAGI_sensor
	
	#NOTE: We always load motors, whether we are in post message mode or not
	# Load in motor FEAGI Device objects
	for outgoing_FEAGI_motor in mapping_config.motors.values():
		if outgoing_FEAGI_motor is not FEAGI_IOConnector_Motor_Base:
			push_error("FEAGI: Unknown object attempted to be added as a FEAGI Motor! Skipping!")
			continue
		if (outgoing_FEAGI_motor as FEAGI_IOConnector_Motor_Base).is_disabled:
			print("FEAGI: Motor %s is disabled! Not using it for the debugger AND for FEAGI!" % (outgoing_FEAGI_motor as FEAGI_IOConnector_Motor_Base).device_friendly_name)
			continue
		if (outgoing_FEAGI_motor as FEAGI_IOConnector_Motor_Base).device_friendly_name in _FEAGI_motors:
			push_error("FEAGI: Motor %s is already defined! Ensure there are no motor devices with repeating names! Skipping" % (outgoing_FEAGI_motor as FEAGI_IOConnector_Motor_Base).device_friendly_name)
			continue
		_FEAGI_motors[(outgoing_FEAGI_motor as FEAGI_IOConnector_Motor_Base).device_friendly_name] = outgoing_FEAGI_motor

	# Activate FEAGI Device manager, including the Debugger (if enabled) and the FEAGI Network Interface (if enabled)
	_FEAGI_IOConnector_manager = FEAGI_RunTime_IOConnectorManager.new(_FEAGI_sensors, _FEAGI_motors)
	if mapping_config.debugger_enabled:
		_FEAGI_IOConnector_manager.setup_debugger()
	if is_in_post_message_mode:
		var connection_succesful: bool = _FEAGI_IOConnector_manager.setup_FEAGI_fake(self)
		if !connection_succesful:
			push_error("FEAGI: Unable to initialize PostMessage mode! Integration will now halt")
			return
	else:
		var connection_succesful: bool = await _FEAGI_IOConnector_manager.setup_FEAGI_networking(endpoint_config, self)
		if connection_succesful:
			_FEAGI_IOConnector_manager.send_configurator_and_enable(mapping_config.configuration_JSON)
		else:
			push_error("FEAGI: Failed to connect to FEAGI! Integration will now halt!")
			return
		
	# Activate Registration Agent Manager to act as an endpoint for Registration Agents to register themselves to
	registration_agent_manager = FEAGI_RunTime_RegistrationAgentManager.new(_FEAGI_sensors, _FEAGI_motors)
	_registration_allowed = true
	print("FEAGI: Registration Agent registration now enabled! About the sent signal allowing Registration Agents to register themselves to their relevant FEAGI Device!")
	ready_for_registration_agent_registration.emit()
	
	# Add all devices that have been requested to be auto-generated
	_automatic_device_generator = FEAGIAutomaticDeviceGenerator.new()
	add_child(_automatic_device_generator)
	print("FEAGI: Adding all automatically generated Registration Agents as per configuration!")
	_automatic_device_generator.add_all_autogenerated_objects(_FEAGI_sensors, _FEAGI_motors)
	
	if !is_in_post_message_mode:
		# Initialize tick engine to poll sensors
		_tick_engine = FEAGI_RunTime_TickEngine.new()
		add_child(_tick_engine)
		_tick_engine.setup(mapping_config.delay_seconds_between_frames)
		_tick_engine.tick.connect(_FEAGI_IOConnector_manager.on_sensor_tick)
		print("FEAGI: Sensor Tick Engine is now enabled!")
		
		# Initialize Metric Reporting
		_metric_reporting = FEAGI_RunTime_MetricReporting.new(endpoint_config.get_full_FEAGI_API_URL(), self)
		ready_for_metric_posting.emit()
		print("FEAGI: Metrics are now enabled!")
		print("FEAGI: FEAGI plugin Initialization is now complete!")
	
	
