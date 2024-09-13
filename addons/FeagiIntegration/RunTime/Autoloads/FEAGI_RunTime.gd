extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI

## TODO signals & vars for state
signal ready_for_godot_device_registration()

var godot_device_manager: FEAGI_RunTime_GodotDeviceManager = null
var _FEAGI_device_manager: FEAGI_RunTime_FEAGIDeviceManager = null
var _automatic_device_generator: FEAGIAutomaticDeviceGenerator = null
var _tick_engine: FEAGI_RunTime_TickEngine = null

var _FEAGI_sensors: Dictionary = {} ## Key'd by the device name, value is the relevant [FEAGI_IOHandler_Sensory_Base]. Beware of name conflicts! Should be treated as static after devices added!
var _FEAGI_motors: Dictionary = {} ## ditto but with [FEAGI_IOHandler_Motor_Base]

func _enter_tree() -> void:
	initialize_FEAGI_runtime() ## TODO have seperate autoload autostart this as a config


	#_tick_engine = FEAGI_RunTime_TickEngine.new()
	#add_child(_tick_engine)




# General overview of startup
# Read / verify configs, stop if not enabled
# Load in sensor / motor FEAGI Device objects
# Activate FEAGI Device manager, including the Debugger (if enabled) and the FEAGI Network Interface (if enabled)
# Activate Godot Device Manager to act as an endpoint for Godot Devices to register themselves to
# Add all devices that have been requested to be auto-generated
# Initialize tick engine
func initialize_FEAGI_runtime(mapping_config: FEAGI_Genome_Mapping = null, endpoint_config: FEAGI_Resource_Endpoint = null) -> void:
	print("FEAGI Interface starting up!")
	
	# If the mapping config isnt defined, attempt to load it from disk. If still not defined -> failure
	if !mapping_config:
		mapping_config = load(FEAGI_PLUGIN.get_genome_mapping_path())
		if !mapping_config:
			push_error("FEAGI: No mapping settings given or found on disk for FEAGI configuration! The FEAGI integration will now halt!")
			return
	
	if !mapping_config.FEAGI_enabled:
		push_warning("FEAGI: FEAGI disabled as per configuration")
		return
	
	# If endpoint isnt defined, attempt to load it from disk. If still not defined -> create one with localhost settings
	# NOTE: Regardless of what endpoint settings are in the object at this point, they can still be overwritten by URL parameters!
	if !endpoint_config:
		endpoint_config = load(FEAGI_PLUGIN.get_endpoint_path())
		if !endpoint_config:
			push_warning("FEAGI: No endpoint settings were given or found on disk. Defaulting to localhost settings for initial endpoint!")
			endpoint_config = FEAGI_Resource_Endpoint.new()
	
	# Load in sensor FEAGI Device objects
	for incoming_FEAGI_sensor in mapping_config.sensors.values():
		if incoming_FEAGI_sensor is not FEAGI_IOHandler_Sensory_Base:
			push_error("FEAGI: Unknown object attempted to be added as a FEAGI Sensor! Skipping!")
			continue
		if (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).is_disabled:
			print("FEAGI: Sensor %s is disabled! Not using it for the debugger AND for FEAGI!" % (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name)
			continue
		if (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name in _FEAGI_sensors:
			push_error("FEAGI: Sensor %s is already defined! Ensure there are no sensor devices with repeating names! Skipping" % (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name)
			continue
		_FEAGI_sensors[(incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name] = incoming_FEAGI_sensor
	
	# Load in motor FEAGI Device objects
	for outgoing_FEAGI_motor in mapping_config.motors.values():
		if outgoing_FEAGI_motor is not FEAGI_IOHandler_Motor_Base:
			push_error("FEAGI: Unknown object attempted to be added as a FEAGI Motor! Skipping!")
			continue
		if (outgoing_FEAGI_motor as FEAGI_IOHandler_Motor_Base).is_disabled:
			print("FEAGI: Motor %s is disabled! Not using it for the debugger AND for FEAGI!" % (outgoing_FEAGI_motor as FEAGI_IOHandler_Motor_Base).device_name)
			continue
		if (outgoing_FEAGI_motor as FEAGI_IOHandler_Motor_Base).device_name in _FEAGI_motors:
			push_error("FEAGI: Motor %s is already defined! Ensure there are no motor devices with repeating names! Skipping" % (outgoing_FEAGI_motor as FEAGI_IOHandler_Motor_Base).device_name)
			continue
		_FEAGI_motors[(outgoing_FEAGI_motor as FEAGI_IOHandler_Motor_Base).device_name] = outgoing_FEAGI_motor
	
	
	# Activate FEAGI Device manager, including the Debugger (if enabled) and the FEAGI Network Interface (if enabled)
	_FEAGI_device_manager = FEAGI_RunTime_FEAGIDeviceManager.new(_FEAGI_sensors, _FEAGI_motors)
	if mapping_config.debugger_enabled:
		_FEAGI_device_manager.setup_debugger()
	if mapping_config.FEAGI_enabled:
		_FEAGI_device_manager.setup_FEAGI_networking(endpoint_config, self)
	
	# Activate Godot Device Manager to act as an endpoint for Godot Devices to register themselves to
	godot_device_manager = FEAGI_RunTime_GodotDeviceManager.new(_FEAGI_sensors, _FEAGI_motors)
	ready_for_godot_device_registration.emit()
	
	# Add all devices that have been requested to be auto-generated
	_automatic_device_generator = FEAGIAutomaticDeviceGenerator.new()
	add_child(_automatic_device_generator)
	_automatic_device_generator.add_all_autogenerated_objects(_FEAGI_sensors, _FEAGI_motors)
	
	# Initialize tick engine
	_tick_engine = FEAGI_RunTime_TickEngine.new()
	add_child(_tick_engine)
	_tick_engine.setup(mapping_config.delay_seconds_between_frames)
	_tick_engine.tick.connect(_FEAGI_device_manager.on_sensor_tick)
	
	
	
	




	
	
	
