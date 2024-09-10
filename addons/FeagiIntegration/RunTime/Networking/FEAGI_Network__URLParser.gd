extends RefCounted
class_name FEAGI_Network_URLParser
## Updates the endpoint resource with info parsed form the URL this game is running in (assuming web export)

# Static Network Configuration / defaults
const DEF_HEADERSTOUSE: PackedStringArray = ["Content-Type: application/json"]

func parse_URL_and_update(array_of_endpoint_resource_and_configuration_JSON_string: Array) -> Array:
	
	if len(array_of_endpoint_resource_and_configuration_JSON_string) != 2:
		push_error("FEAGI: Expected a array of length 2 with the endpoint resource and the configuration JSON string")
		return []
	if array_of_endpoint_resource_and_configuration_JSON_string[0] is not FEAGI_Resource_Endpoint:
		push_error("FEAGI: Expected first element to be FEAGI_Resource_Endpoint")
	var endpoint_resource: FEAGI_Resource_Endpoint = array_of_endpoint_resource_and_configuration_JSON_string[0]
	var temp = JSON.parse_string(str(array_of_endpoint_resource_and_configuration_JSON_string[1]))
	if !temp:
		push_error("FEAGI: Expected second element to be JSON string of configurator value!")
	var configuration: Dictionary = temp
	
	
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
	
	if SSL_type or ip_address_to_connect or without_port or full_dns_of_websocket:
		# If we got a value for any of these, then it means we are a web export with URL parameters. Time to do some overwriting
		print("Found Parameters in the URL to overwrite!")
		
		var is_using_SSL: bool
		var feagi_domain: StringName
		var connector_domain: StringName
		
		var found_ws_port: int
		
		if endpoint_resource.FEAGI_endpoint.contains("://"):
			feagi_domain = endpoint_resource.FEAGI_endpoint.split("://")[1]
		
		if endpoint_resource.connector_endpoint.contains("://"):
			connector_domain = endpoint_resource.FEAGI_endpoint.split("://")[1]
			
		if SSL_type:
			is_using_SSL = str(SSL_type).to_lower().contains("s")
		
		if ip_address_to_connect: ## Assuming this is feagi?
			feagi_domain = ip_address_to_connect
		
		if full_dns_of_websocket: ## also for connector, and why is this formatted seperately? Why is this allowing mixed content?
			full_dns_of_websocket = str(full_dns_of_websocket)
			if full_dns_of_websocket.to_lower().contains("ws://"):
				full_dns_of_websocket = full_dns_of_websocket.substr(4, full_dns_of_websocket.length() - 4)
			if full_dns_of_websocket.to_lower().contains("wss://"):
				full_dns_of_websocket = full_dns_of_websocket.substr(5, full_dns_of_websocket.length() - 5)
			if full_dns_of_websocket.contains(":"):
				full_dns_of_websocket = full_dns_of_websocket.split(":")[0]
				found_ws_port = full_dns_of_websocket.split(":")[1].to_int()
		
		if endpoint_resource.automatic_port_assignment:
			
		
		
		
		if full_dns_of_websocket: # NOTE socket domain and connector domain are the same!
			connector_domain = full_dns_of_websocket # TODO what about connector?
		else: connector_domain = 
		

		endpoint_resource.FEAGI_endpoint = API_SSL + feagi_domain
		endpoint_resource.connector_endpoint = API_SSL + connector_domain
	
		
	
		if 
		
		
		endpoint_resource.FEAGI_endpoint = API_SSL + feagi_domain
		
		
			
	
	
	feagi_web_port = http_port
	feagi_socket_port = websocket_port
	if SSL_type != null:
		feagi_SSL = SSL_type
		recieved_results = true
	else:
		feagi_SSL= DEF_FEAGI_SSL
	if ip_address_to_connect != null:
		feagi_TLD = ip_address_to_connect
		recieved_results = true
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
		
	print("websocket: ", feagi_socket_address, " and api: ", feagi_root_web_address)
	
	
	
	
