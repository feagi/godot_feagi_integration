extends RefCounted
class_name FEAGI_Networking_WS
## Handles WebSocket

signal socket_closed()
signal recieved_bytes(bytes: PackedByteArray)
signal socket_state_changed(new_state: WebSocketPeer.State)

var connection_active: bool:
	get: return _connection_active

var _connection_active: bool  = false

var _socket: WebSocketPeer
var _socket_state: WebSocketPeer.State = WebSocketPeer.State.STATE_CLOSED

## Should be called by _process
func process_WS(delta: float) -> void:
	if not _socket:
		return
	_socket.poll()
	if _socket.get_ready_state() != _socket_state:
		_socket_state = _socket.get_ready_state()
		socket_state_changed.emit(_socket_state)
	match(_socket_state):
		WebSocketPeer.State.STATE_OPEN:
			while _socket.get_available_packet_count():
				recieved_bytes.emit(_socket.get_packet())
		WebSocketPeer.State.STATE_CLOSED:
			_on_socket_death()

## ASYNC Initialize Websocket
func setup_websocket(full_connector_WS_address: StringName) -> bool:
	_socket = WebSocketPeer.new()
	_socket_state = WebSocketPeer.State.STATE_CLOSED
	_socket.connect_to_url(full_connector_WS_address)
	_socket_state = WebSocketPeer.State.STATE_CONNECTING
	await socket_state_changed
	var successful: bool = _socket_state == WebSocketPeer.State.STATE_OPEN
	if not successful:
		_on_socket_death()
		return false
	_connection_active = true
	return true

## Send data over websocket. For now since its ascii text (RIP) make sure to convert to ASCII buffer first
func send_over_socket(data_uncompressed: PackedByteArray) -> void:
	if not _socket:
		return
	_socket.send(data_uncompressed.compress(FileAccess.COMPRESSION_DEFLATE))

func _on_socket_death() -> void:
		push_error("FEAGI: WS Socket to connector closed!")
		_connection_active = false
		_socket = null
		socket_closed.emit()
