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

var _disable_automatic_port_addition_API: bool = false
var _disable_automatic_port_addition_WS: bool = false

func contains_magic_link() -> bool:
	return magic_link_full != &""

## returns tue if ALL parameters required for URL parsing are available in the URL
func contains_all_URL_parameters_needed_for_URL_parsing() -> bool:
	return (FEAGI_JS.attempt_get_parameter_from_URL("feagi_url") != null) and (FEAGI_JS.attempt_get_parameter_from_URL("ws_url") != null)

## ASYNC Attempts to update internal vars from magic link. Returns true if successful
func update_internal_vars_from_magic_link(node_for_HTTP_worker: Node) -> bool:
	if magic_link_full == "":
		return false # no link to update!
	
	var http_worker: FEAGIHTTP = FEAGIHTTP.new()
	node_for_HTTP_worker.add_child(http_worker)
	http_worker.send_GET_request(magic_link_full)
	var arr: Array = await http_worker.FEAGI_call_complete
	
	# NOTE: Since Magic link contains token information, do NOT log it
	if arr[0] != 200:
		push_error("FEAGI: Unable to connect to Magic Link to get FEAGI connection endpoints!")
		return false
	var return_data: String = (arr[1] as PackedByteArray).get_string_from_utf8()
	var parsed_data: Variant = JSON.parse_string(return_data)
	if !parsed_data:
		push_error("FEAGI: Unable to parse data from Magic Link for FEAGI!")
		return false
	if parsed_data is not Dictionary:
		# How did you do this lol
		push_error("FEAGI: Unable to parse data from Magic Link for FEAGI!")
		return false
	var parsed: Dictionary = parsed_data as Dictionary
	if !parsed.has("feagi_url") or !parsed.has("feagi_api_port") or !parsed.has("godot_game_ws_port"):
		push_error("FEAGI: Unable to parse data from Magic Link for FEAGI Due to missing information! Something is wrong with the backend!")
		return false
	if !parsed["feagi_url"]: # If a FEAGI instance is down, the URL returned will be null
		push_error("FEAGI: The FEAGI instance at input Magic Link appears to be down! Is the instance running?")
		return false
	
	# We have all the needed information to parse connection data
	var api_URL: String = parsed["feagi_url"]
	parse_full_FEAGI_URL(api_URL)
	
	var wss_URL: String = parsed["feagi_url"]
	wss_URL = wss_URL.right(wss_URL.length() - 5) # remove "https"
	wss_URL = "wss" + wss_URL + "/p" + parsed["godot_game_ws_port"]
	parse_full_connector_URL(wss_URL)
	return true

## Attempts to update internal vars from URL parameters. Returns true if successful
func update_internal_vars_from_URL_parameters() -> bool:
	if !contains_all_URL_parameters_needed_for_URL_parsing():
		return false
	var feagi_full_URL: String = FEAGI_JS.attempt_get_parameter_from_URL("feagi_url")
	var connector_full_URL: String = FEAGI_JS.attempt_get_parameter_from_URL("ws_url")
	
	var success: bool = false
	success = parse_full_FEAGI_URL(feagi_full_URL)
	if success:
		return parse_full_connector_URL(connector_full_URL)
	return false

func get_full_FEAGI_API_URL() -> StringName:
	var prefix: StringName = "http://"
	if is_using_SSL:
		prefix = "https://"
	if not _disable_automatic_port_addition_API:
		return prefix + FEAGI_TLD + ":" + str(FEAGI_API_port)
	else:
		return prefix + FEAGI_TLD # assuming default HTTP/HTTPS standard ports

func get_full_connector_ws_URL() -> StringName:
	var prefix: StringName = "ws://"
	if is_using_SSL:
		prefix = "wss://"
	if not _disable_automatic_port_addition_WS:
		return prefix + connector_TLD + ":" + str(connector_ws_port)
	else:
		return prefix + connector_TLD # assuming default HTTP/HTTPS standard ports

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
	elif !full_URL.is_valid_ip_address(): # we are assuming that if we pass an IP address for some reason, not to update a port. A domain is free game to assume the standard http/https port though
		_disable_automatic_port_addition_API = true
		if set_SSL:
			set_port = 443
		else:
			set_port = 80
		
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
	elif !full_URL.is_valid_ip_address(): # we are assuming that if we pass an IP address for some reason, not to update a port. A domain is free game to assume the standard http/https port though
		_disable_automatic_port_addition_WS = true
		if set_SSL:
			set_port = 443
		else:
			set_port = 80
	
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
