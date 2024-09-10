extends Node
class_name FEAGI_RunTime_FEAGIInterface

var _socket: Feagi_Network_Socket

var _FEAGI_sensors_reference: Dictionary ## WARNING: For performance reasons, we pass this by reference, and changes may occur to this dictionary outside this class. Be EXTREMELY careful with caching!
var _FEAGI_data: Dictionary


## Initializes the network system. Returns true if connection succeeds
func setup(network_details: FEAGI_Resource_Endpoint, initial_JSON: StringName, sensors_reference: Dictionary) -> bool:
	var configuration_json: Dictionary = FEAGI_Network_URLParser.overwrite_config(JSON.parse_string(initial_JSON))
	network_details = FEAGI_Network_URLParser.update_network_endpoint(network_details)
	_socket = Feagi_Network_Socket.new(network_details.connector_ws_endpoint)
	await _socket.connection_attempt_complete
	if _socket.websocket_state == WebSocketPeer.State.STATE_CLOSED:
		push_error("FEAGI: Failed to connect!")
		_socket = null
		return false
	print("FEAGI: Connected to endpoint!")
	_socket.send(JSON.stringify(configuration_json))
	await get_tree().create_timer(1.0).timeout # wait a second for connector
	_FEAGI_sensors_reference = sensors_reference
	return true

func on_tick() -> void:
	_FEAGI_data = {}
	if _socket:
		for device_name in _FEAGI_sensors_reference:
			_FEAGI_data[device_name] = _FEAGI_sensors_reference[device_name].get_data_as_byte_array()
		_socket.websocket_send_text(str(_FEAGI_data))

func _process(delta: float) -> void:
	if _socket:
		_socket.socket_status_poll()
	pass
