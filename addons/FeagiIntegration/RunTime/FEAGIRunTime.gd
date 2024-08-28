extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI

signal sensory_setup_event()
signal motor_setup_event()

var mapping_config: FEAGIGenomeMapping
var endpoint_config: FEAGIResourceEndpoint

# Read / verify configs
# initial loading and setup of variables, check if enabled
# emit signals when tree is ready, have devices register
# initialize debugger views
# confirm network connection to feagi
# start tick system

func _enter_tree() -> void:
	mapping_config = load(FEAGIPluginInit.get_genome_mapping_path())
	endpoint_config = load(FEAGIPluginInit.get_endpoint_path())
	
	if !mapping_config:
		push_error("FEAGI: No settings found for FEAGI configuration! The FEAGI integration will now halt!")
		return
	if !endpoint_config:
		push_error("FEAGI: No connection settings found for FEAGI configuration! THe FEAGI integration will now halt!")
		return
	
	
