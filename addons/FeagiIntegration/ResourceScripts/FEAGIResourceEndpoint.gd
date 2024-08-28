@tool
extends Resource
class_name FEAGIResourceEndpoint

@export var magic_URL: StringName
@export var FEAGI_endpoint: StringName
@export var connector_endpoint: StringName
@export var FEAGI_API_port: int
@export var connector_API_port: int
@export var connector_WS_port: int

static func create_from(FEAGI_endpoint: StringName, FEAGI_API_port: int,
	connector_endpoint: StringName, connector_API_port: int, connector_WS_port: int,
	magic_URL: StringName = "") -> FEAGIResourceEndpoint:
	
	var output: FEAGIResourceEndpoint = FEAGIResourceEndpoint.new()
	output.magic_URL = magic_URL
	output.FEAGI_endpoint = FEAGI_endpoint
	output.connector_endpoint = connector_endpoint
	output.FEAGI_API_port = FEAGI_API_port
	output.connector_API_port = connector_API_port
	output.connector_WS_port = connector_WS_port
	return output

func confirm_endpoint_valid() -> bool:
	#TODO
	return false

func save_config() -> void:
	FEAGIPluginInit.confirm_config_directory()
	ResourceSaver.save(self, FEAGIPluginInit.get_endpoint_path())
