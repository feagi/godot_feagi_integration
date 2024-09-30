extends RefCounted
class_name FEAGI_Network_URLParser
## Updates the endpoint resource with info parsed form the URL this game is running in (assuming web export)

# Static Network Configuration / defaults
const DEF_HEADERSTOUSE: PackedStringArray = ["Content-Type: application/json"]

static func update_network_endpoint(endpoint_resource: FEAGI_Resource_Endpoint) -> FEAGI_Resource_Endpoint:

	var websocket_port: int = 9050
	var http_port: int = 8000
	var feagi_web_port: int
	var feagi_socket_port: int
	var feagi_TLD: StringName
	var feagi_SSL: StringName
	var feagi_socket_SSL: StringName
	var feagi_root_web_address: StringName
	var feagi_root_websocket_address: StringName
	var feagi_socket_address: StringName
	var DEF_FEAGI_TLD: StringName = "127.0.0.1" # Default localhost
	var DEF_FEAGI_SSL: StringName = "http://" # Default localhost
	
	
	var SSL_type = JavaScriptBridge.eval(""" 
		function get_port() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("http_type");
			return ipAddress;
		}
		get_port();
		""")
	var ip_address_to_connect = JavaScriptBridge.eval(""" 
		function getIPAddress() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("ip_address");
			return ipAddress;
		}
		getIPAddress();
		""")
	var without_port = JavaScriptBridge.eval(""" 
		function get_port() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("port_disabled");
			return ipAddress;
		}
		get_port();
		""")
	var full_dns_of_websocket = JavaScriptBridge.eval(""" 
		function get_port() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("websocket_url");
			return ipAddress;
		}
		get_port();
		""")

	
	## TODO this is very messy. Trying to parse this is extremely frustrating due to conflicting requirements. Instead, we should look to sending the data in a more organized form to begin with
	
	feagi_web_port = http_port
	feagi_socket_port = websocket_port
	if SSL_type != null:
		feagi_SSL = SSL_type
	else:
		feagi_SSL= DEF_FEAGI_SSL
	if ip_address_to_connect != null:
		feagi_TLD = ip_address_to_connect
	else:
		feagi_TLD = DEF_FEAGI_TLD
	if without_port != null:
		if without_port.to_lower() == "true":
			feagi_root_web_address = feagi_SSL + feagi_TLD
		else:
				feagi_root_web_address = feagi_SSL + feagi_TLD + ":" + str(feagi_web_port)
	else:
		feagi_root_web_address = feagi_SSL + feagi_TLD + ":" + str(feagi_web_port)
		# init WebSocket
	if full_dns_of_websocket != null:
		feagi_socket_address = full_dns_of_websocket
	else:
		feagi_socket_address = feagi_socket_SSL + feagi_TLD + ":" + str(feagi_socket_port)
		
	if ip_address_to_connect:
		endpoint_resource.connector_API_endpoint = feagi_socket_address
		endpoint_resource.connector_ws_endpoint = feagi_socket_address
		endpoint_resource.connector_API_endpoint = feagi_root_web_address

	
	return endpoint_resource

static func overwrite_config(configuration: Dictionary) -> Dictionary:
	var feagi_indexes = JavaScriptBridge.eval("""
		function get_indexes() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const capabilities = searchParams.get("capabilities");
			return capabilities;
		}
		get_indexes();
	}""")
	
	if feagi_indexes:
		var str_index_replacements: StringName = str(feagi_indexes)
		var str_index_replacement_arr: PackedStringArray = str_index_replacements.split("|")
		for str_index_replacement in str_index_replacement_arr:
			configuration = FEAGI_Network_URLParser._overwrite_capabilities(str_index_replacement.split("."), configuration)
	
	return configuration


static func _overwrite_capabilities(replacements: PackedStringArray, replacing_dict: Dictionary) -> Dictionary:
	replacing_dict["capabilities"][replacements[0]][replacements[1]][replacements[2]] = replacements[3].to_int()
	return replacing_dict
	
	
	
