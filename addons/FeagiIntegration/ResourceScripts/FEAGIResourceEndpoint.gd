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

## TODO move me

const CONFIG_DIR: StringName = "res://FEAGI_config/"
const CONFIG_ENDPOINT_NAME: StringName = "endpoint.tres"
const CONFIG_GENOME_NAME: StringName = "genome_mapping.tres"
const CONFIG_GITIGNORE_TEXT: StringName = CONFIG_ENDPOINT_NAME

static func get_gitignore_path() -> StringName:
	return CONFIG_DIR + ".gitignore"

static func get_endpoint_path() -> StringName:
	return CONFIG_DIR + CONFIG_ENDPOINT_NAME


static func confirm_config_directory() -> void:
	if not DirAccess.dir_exists_absolute(CONFIG_DIR):
		DirAccess.make_dir_absolute(CONFIG_DIR)
	if not FileAccess.file_exists(get_gitignore_path()):
		var file: FileAccess = FileAccess.open(get_gitignore_path(), FileAccess.WRITE)
		file.store_string(CONFIG_GITIGNORE_TEXT)
		file.close()

func save_config() -> void:
	confirm_config_directory()
	ResourceSaver.save(self, get_endpoint_path())
