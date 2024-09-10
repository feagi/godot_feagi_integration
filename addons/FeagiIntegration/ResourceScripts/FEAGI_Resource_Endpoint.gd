@tool
extends Resource
class_name FEAGI_Resource_Endpoint

@export var magic_URL: StringName
@export var is_using_SSL: bool
@export var FEAGI_endpoint: StringName
@export var connector_endpoint: StringName
@export var automatic_port_assignment: bool = true
@export var FEAGI_API_port: int
@export var connector_WS_port: int

static func create_from(FEAGI_endpoint: StringName, FEAGI_API_port: int,
	connector_endpoint: StringName, connector_WS_port: int,
	magic_URL: StringName = "") -> FEAGI_Resource_Endpoint:
	
	var output: FEAGI_Resource_Endpoint = FEAGI_Resource_Endpoint.new()
	output.magic_URL = magic_URL
	output.FEAGI_endpoint = FEAGI_endpoint
	output.connector_endpoint = connector_endpoint
	output.FEAGI_API_port = FEAGI_API_port
	output.connector_WS_port = connector_WS_port
	return output

func confirm_endpoint_valid() -> bool:
	#TODO
	return false

func save_config() -> void:
	FEAGI_PLUGIN.confirm_config_directory()
	if FileAccess.file_exists(FEAGI_PLUGIN.get_endpoint_path()):
		var error: Error = DirAccess.remove_absolute(FEAGI_PLUGIN.get_endpoint_path())
		if error != OK:
			push_error("FEAGI: Unable to overwrite Endpoint file!")
	ResourceSaver.save(self, FEAGI_PLUGIN.get_endpoint_path())
	take_over_path(FEAGI_PLUGIN.get_genome_mapping_path()) # work around for godot failing to automatically reload file
