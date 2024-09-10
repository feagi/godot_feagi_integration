extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI



var godot_device_manager: FEAGI_RunTime_GodotDeviceManager = FEAGI_RunTime_GodotDeviceManager.new()

var _FEAGI_device_manager: FEAGI_RunTime_FEAGIDeviceManager = FEAGI_RunTime_FEAGIDeviceManager.new()

var _FEAGI_sensors: Dictionary = {} ## Key'd by the device name, value is the relevant [FEAGI_IOHandler_Sensory_Base]. Beware of name conflicts!
var _FEAGI_sensors_cache: Array[FEAGI_IOHandler_Sensory_Base] = [] ## NOTE: We cache the results of _FEAGI_sensors.values() since its rather slow



var mapping_config: FEAGI_Genome_Mapping
var endpoint_config: FEAGI_Resource_Endpoint
var _automatic_device_generator: FEAGIAutomaticDeviceGenerator
var _tick_engine: FEAGI_RunTime_TickEngine

# General overview of startup
# Read / verify configs, stop if not enabled
# Load in sensor / motor FEAGI Device objects
# Activate FEAGI Device manager, including the Debugger and the FEAGI Network Interface (if enabled)
# Activate Godot Device Manager



# initialize debugger views
# Wait for game tree to be ready
# confirm network connection to feagi
# Overwrite any feagi indexes on the device listing if mentioned in the URL parameters
# Have virtual FEAGI devices register themselves to the FEAGI runtime
# start tick system

func initialize_FEAGI_runtime() -> void:
	print("FEAGI Interface starting up!")
	
	# Read / verify configs, stop if not enabled
	mapping_config = load(FEAGI_PLUGIN.get_genome_mapping_path())
	endpoint_config = load(FEAGI_PLUGIN.get_endpoint_path())
	if !mapping_config:
		push_error("FEAGI: No settings found for FEAGI configuration! The FEAGI integration will now halt!")
		return
	if !mapping_config.FEAGI_enabled:
		push_warning("FEAGI: FEAGI disabled as per configuration")
		return
	if !endpoint_config:
		push_error("FEAGI: No connection settings found for FEAGI configuration! THe FEAGI integration will now halt!")
		return
	
	# Load in sensor / motor FEAGI Device objects
	for incoming_FEAGI_sensor in mapping_config.sensors.values():
		if incoming_FEAGI_sensor is not FEAGI_IOHandler_Sensory_Base:
			push_error("FEAGI: Unknown object attempted to be added as a FEAGI Sensor! Skipping!")
			continue
			
		if (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).is_disabled:
			print("FEAGI: Sensor %s is disabled! Not using it for the debugger AND to FEAGI!" % (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name)
			continue
		if (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name in _FEAGI_sensors:
			push_error("FEAGI: sensor %s is already defined! Ensure there are no motor / sensor devices with repeating names!" % (incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name)
			continue
		_FEAGI_sensors[(incoming_FEAGI_sensor as FEAGI_IOHandler_Sensory_Base).device_name] = incoming_FEAGI_sensor
	_FEAGI_sensors_cache = _FEAGI_sensors.values()
	
	
	# Activate FEAGI Device manager, including the Debugger and the FEAGI Network Interface (if enabled)
	_FEAGI_device_manager.setup(_FEAGI_sensors, mapping_config.debugger_enabled, mapping_config.FEAGI_enabled)
	
	# Activate Godot Device Manager
	godot_device_manager.setup(_FEAGI_sensors)
	
	
	
	
	

func _enter_tree() -> void:


	
	# process nodes
	_automatic_device_generator = FEAGIAutomaticDeviceGenerator.new()
	add_child(_automatic_device_generator)
	_tick_engine = FEAGI_RunTime_TickEngine.new()
	add_child(_tick_engine)
	_debug_interface = FEAGI_RunTime_DebugInterface.new()
	
	# Certain sensor instances may be requesting automatic device generation
	# But every sensor instance has a debug system that should be hooked up
	for sensor: FEAGI_IOHandler_Sensory_Base in mapping_config.sensors.values():
		
		if sensor is FEAGI_IOHandler_Sensory_Camera:
			if (sensor as FEAGI_IOHandler_Sensory_Camera).automatically_create_screengrabber:
				_automatic_device_generator.add_camera_screencapture(sensor.device_name)
		
		# Debug System Registration
		_debug_interface.alert_debugger_about_device_creation(false, sensor)
		
		

	
	# wait for the scene to be ready
	var root: Node = get_tree().root
	var current_scene: Node = root.get_child(root.get_child_count() - 1)
	await current_scene.ready
	
	#TODO ping endpoints, ensure they are valid
	#TODO update config json with the new feagi indexes
	#TODO send configuration json
	
	# alert any virtual devices to register with this autoload if they are enabled to do so automatically
	signal_all_autoregister_sensors_to_register.emit()
	signal_all_autoregister_motors_to_register.emit()
	
	# Initialize Tick engine
	_tick_engine.tick.connect(_FEAGI_tick)
	_tick_engine.setup(mapping_config.delay_seconds_between_frames)

## Get data from sensors, send to FEAGI, retrieve motor data from FEAGI, send to godot motor devices, update debug information with both
func _FEAGI_tick() -> void:
	# Get sensor data
	
	# Send Sensor data
	
	# Retrieve Motor data
	
	# Apply Motor data
	
	# update debug information
	_debug_interface.alert_debugger_about_data_update()
	
	
	
	pass
	
	
	
