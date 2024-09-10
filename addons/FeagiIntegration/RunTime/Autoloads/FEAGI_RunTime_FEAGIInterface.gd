extends Node
class_name FEAGI_RunTime_FEAGIInterface


var _socket: WebSocketPeer




func initialize(network_details: FEAGI_Resource_Endpoint, initial_JSON: StringName) -> void:
	var configuration_json: Dictionary = FEAGI_Network_URLParser.overwrite_config(JSON.parse_string(initial_JSON))
	network_details = FEAGI_Network_URLParser.update_network_endpoint(network_details)
	

	
	
	_socket = WebSocketPeer.new()
	
	
	# Contact the web server to update the json
	
	# await for response to update this
	
	pass
