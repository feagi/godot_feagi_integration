@tool
extends Resource
class_name FEAGI_Resource_Endpoint
## Resource that holds what the connection endpoint details are for FEAGI. Initializes to use FEAGI on localhost

@export var magic_link_full: StringName = ""

@export var is_using_SSL: bool = false

@export var FEAGI_TLD: StringName = "127.0.0.1"
@export var FEAGI_API_port: int = 8000

@export var connector_TLD: StringName = "127.0.0.1"
@export var connector_ws_port: int = 9055


func contains_magic_link() -> bool:
	return magic_link_full == &""

## returns tue if ALL parameters required for URL parsing are available in the URL
func contains_URL_parameters_needed_for_URL_parsing() -> bool:
	return FEAGI_JS.attempt_get_parameter_from_URL("feagi_url") and FEAGI_JS.attempt_get_parameter_from_URL("connector_url")

## returns tue if parameter of the magic link exists in the URL
func contains_URL_parameters_needed_for_magic_link_parsing() -> bool:
	return FEAGI_JS.attempt_get_parameter_from_URL("magic_link")

## Attempts to update internal vars from magic link. Returns true if successful
func update_internal_vars_from_magic_link() -> bool:
	#todo
	return false

## Attempts to update internal vars from URL parameters. Returns true if successful
func update_internal_vars_from_URL_parameters() -> bool:
	if !contains_URL_parameters_needed_for_URL_parsing():
		return false
	var feagi_full_URL: String = FEAGI_JS.attempt_get_parameter_from_URL("feagi_url")
	var connector_full_URL: String = FEAGI_JS.attempt_get_parameter_from_URL("connector_url")
	
	var success: bool = false
	success = parse_full_FEAGI_URL(feagi_full_URL)
	if success:
		return parse_full_connector_URL(connector_full_URL)
	return false

func get_full_FEAGI_API_URL() -> StringName:
	var prefix: StringName = "http://"
	if is_using_SSL:
		prefix = "https://"
	return prefix + FEAGI_TLD + ":" + str(FEAGI_API_port)

func get_full_connector_ws_URL() -> StringName:
	var prefix: StringName = "ws://"
	if is_using_SSL:
		prefix = "wss://"
	return prefix + connector_TLD + ":" + str(connector_ws_port)

## Attempts to parse a full URL as a FEAGI URL. Returns true if there were no issues
func parse_full_FEAGI_URL(full_URL: String) -> bool:
	var set_SSL: bool = is_using_SSL
	var set_TLD: StringName = FEAGI_TLD
	var set_port: int = FEAGI_API_port
	if full_URL.contains("://"):
		if full_URL.contains("https://"):
			set_SSL = true
		elif full_URL.contains("http://"):
			set_SSL = false
		else:
			# some other sort of header was sent. WS?
			return false
		full_URL = full_URL.split("://")[1] # We only want the TLD
	if full_URL.contains(":"):
		var port_str = full_URL.split(":")[1]
		if !port_str.is_valid_int():
			return false
		set_port = port_str.to_int()
		full_URL = full_URL.split(":")[0]
	set_TLD = full_URL
	
	# everything seems good, apply and return successful
	is_using_SSL = set_SSL
	FEAGI_TLD = set_TLD
	FEAGI_API_port = set_port
	return true

## Attempts to parse a full URL as a connector ws URL. Returns true if there were no issues
func parse_full_connector_URL(full_URL: String) -> bool:
	var set_SSL: bool = is_using_SSL
	var set_TLD: StringName = connector_TLD
	var set_port: int = connector_ws_port
	if full_URL.contains("://"):
		if full_URL.contains("wss://"):
			set_SSL = true
		elif full_URL.contains("ws://"):
			set_SSL = false
		else:
			# some other sort of header was sent. HTTP?
			return false
		full_URL = full_URL.split("://")[1] # We only want the TLD
	if full_URL.contains(":"):
		var port_str = full_URL.split(":")[1]
		if !port_str.is_valid_int():
			return false
		set_port = port_str.to_int()
		full_URL = full_URL.split(":")[0]
	set_TLD = full_URL
	
	# everything seems good, apply and return successful
	is_using_SSL = set_SSL
	connector_TLD = set_TLD
	connector_ws_port = set_port
	return true

func save_config() -> void:
	FEAGI_PLUGIN_CONFIG.confirm_config_directory()
	if FileAccess.file_exists(FEAGI_PLUGIN_CONFIG.get_endpoint_path()):
		var error: Error = DirAccess.remove_absolute(FEAGI_PLUGIN_CONFIG.get_endpoint_path())
		if error != OK:
			push_error("FEAGI: Unable to overwrite Endpoint file!")
	ResourceSaver.save(self, FEAGI_PLUGIN_CONFIG.get_endpoint_path())
	take_over_path(FEAGI_PLUGIN_CONFIG.get_genome_mapping_path()) # work around for godot failing to automatically reload file
