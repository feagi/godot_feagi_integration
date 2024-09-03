extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI

signal signal_all_autoregister_sensors_to_register()
signal signal_all_autoregister_motors_to_register()

var mapping_config: FEAGIGenomeMapping
var endpoint_config: FEAGIResourceEndpoint

var _debug_interface: FEAGIRunTimeDebugInterface
var _automatic_device_generator: FEAGIAutomaticDeviceGenerator

# General overview of startup
# Read / verify configs
# initial loading and setup of variables, check if enabled
# initialize debugger views
# Wait for game tree to be ready
# confirm network connection to feagi
# Overwrite any feagi indexes on the device listing if mentioned in the URL parameters
# Have virtual FEAGI devices register themselves to the FEAGI runtime
# start tick system

func _enter_tree() -> void:
	print("FEAGI Interface starting up!")
	mapping_config = load(FEAGIPluginInit.get_genome_mapping_path())
	endpoint_config = load(FEAGIPluginInit.get_endpoint_path())
	
	# Checks to ensure everything is valid and enabled
	
	if !mapping_config:
		push_error("FEAGI: No settings found for FEAGI configuration! The FEAGI integration will now halt!")
		return
	if !mapping_config.FEAGI_enabled:
		push_warning("FEAGI: FEAGI disabled as per configuration")
		return
	if !endpoint_config:
		push_error("FEAGI: No connection settings found for FEAGI configuration! THe FEAGI integration will now halt!")
		return
	
	# process nodes
	_automatic_device_generator = FEAGIAutomaticDeviceGenerator.new()
	add_child(_automatic_device_generator)
	_debug_interface = FEAGIRunTimeDebugInterface.new()
	
	# Certain sensor instances may be requesting automatic device generation
	# But every sensor instance has a debug system that should be hooked up
	for sensor: FEAGISensoryBase in mapping_config.sensors.values():
		
		if sensor is FEAGISensoryCamera:
			if (sensor as FEAGISensoryCamera).automatically_create_screengrabber:
				_automatic_device_generator.add_camera_screencapture(sensor.device_name)
		
		# Debug System Registration
		_debug_interface.message_FEAGI_device_creation(false, sensor.get_device_type(), sensor.device_name)
		
		

	
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
