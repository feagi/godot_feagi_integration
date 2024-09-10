extends Node
class_name FEAGI_RunTime_FEAGIInterface

var _socket: WebSocketPeer




func initialize(initial_JSON: StringName) -> void:
	_socket = WebSocketPeer.new()
	
	# Contact the web server to update the json
	
	# await for response to update this
	
	pass
