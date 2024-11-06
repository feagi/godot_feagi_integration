extends FEAGI_NetworkingConnector_Base
class_name FEAGI_NetworkingConnector_WS
## Handles connection for Websocket

signal _socket_state_changed(new_state: WebSocketPeer.State)

var _socket: WebSocketPeer
var _socket_state: WebSocketPeer.State = WebSocketPeer.State.STATE_CLOSED


## ASYNC Initialize Websocket. Returns true if successful
func setup_websocket(full_connector_WS_address: StringName) -> bool:
	print("FEAGI: Setting up WS connection to %s" % full_connector_WS_address)
	_socket = WebSocketPeer.new()
	_socket_state = WebSocketPeer.State.STATE_CLOSED
	_socket.connect_to_url(full_connector_WS_address)
	_socket_state = WebSocketPeer.State.STATE_CONNECTING
	await _socket_state_changed
	var successful: bool = _socket_state == WebSocketPeer.State.STATE_OPEN
	if not successful:
		push_error("FEAGI: WS Socket failed to connect!")
		_connection_active = false
		_socket = null
		return false
	_connection_active = true
	return true


func run_process(_delta: float) -> void:
	if not _socket:
		return
	_socket.poll()
	if _socket.get_ready_state() != _socket_state:
		_socket_state = _socket.get_ready_state()
		_socket_state_changed.emit(_socket_state)
	match(_socket_state):
		WebSocketPeer.State.STATE_OPEN:
			while _socket.get_available_packet_count():
				recieved_bytes.emit(_socket.get_packet()) 
		WebSocketPeer.State.STATE_CLOSED:
			push_error("FEAGI: WS Socket to connector closed!")
			_socket = null
			connection_closed.emit()

func send_data(data_uncompressed: PackedByteArray) -> void:
	if not _socket:
		return
	_socket.send(data_uncompressed.compress(FileAccess.COMPRESSION_DEFLATE))

func send_configurator_JSON(final_JSON: StringName) -> void:
	send_data(final_JSON.to_ascii_buffer())
