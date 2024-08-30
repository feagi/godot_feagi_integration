extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI

signal signal_all_autoregister_sensors_to_register()
signal signal_all_autoregister_motors_to_register()

var mapping_config: FEAGIGenomeMapping
var endpoint_config: FEAGIResourceEndpoint

# Read / verify configs
# initial loading and setup of variables, check if enabled
# emit signals when tree is ready, have devices register
# initialize debugger views
# confirm network connection to feagi
# Overwrite any feagi indexes on the device listing if mentioned in the URL parameters
# start tick system

func _enter_tree() -> void:
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
	
	# wait for the scene to be ready
	var root: Node = get_tree().root
	var current_scene: Node = root.get_child(root.get_child_count() - 1)
	await current_scene.ready
	
	#TODO ping endpoints, ensure they are valid
	#TODO send configuration json
	
	# alert any virtual devices to register with this autoload if they are enabled to do so automatically
	signal_all_autoregister_sensors_to_register.emit()
	signal_all_autoregister_motors_to_register.emit()
