extends Node
class_name FEAGI_RunTime_FEAGIInterface

const HTTP_WORKER_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/RunTime/Networking/FEAGIHTTP.tscn")

signal socket_state_changed(new_state: WebSocketPeer.State)
var connection_active: bool = false

var _socket: WebSocketPeer
var _socket_state: WebSocketPeer.State = WebSocketPeer.State.STATE_CLOSED

var _FEAGI_sensors_reference: Dictionary ## WARNING: For performance reasons, we pass this by reference, and changes may occur to this dictionary outside this class. Be EXTREMELY careful with caching!

var _FEAGI_data: Dictionary
var _endpoint: FEAGI_Resource_Endpoint


func _process(delta: float) -> void:
	if not _socket:
		return
	_socket.poll()
	if _socket.get_ready_state() != _socket_state:
		_socket_state = _socket.get_ready_state()
		socket_state_changed.emit(_socket_state)

## ASYNC function that returns true if feagis healthcheck returns at the given address
func ping_feagi_available(full_feagi_address: StringName) -> bool:
	var health_check_add: StringName = full_feagi_address + "/v1/system/health_check"
	var worker: FEAGIHTTP = FEAGIHTTP.new()
	worker.name = "health_check"
	add_child(worker)
	worker.send_GET_request(full_feagi_address, "/v1/system/health_check")
	var response: Array = await worker.FEAGI_call_complete
	if len(response) != 2:
		return false
	return response[0] != 0

## ASYNC Initialize Websocket
func setup_websocket(full_connector_WS_address: StringName) -> bool:
	set_process(true)
	_socket = WebSocketPeer.new()
	_socket_state = WebSocketPeer.State.STATE_CLOSED
	_socket.connect_to_url(full_connector_WS_address)
	_socket_state = WebSocketPeer.State.STATE_CONNECTING
	await socket_state_changed
	var successful: bool = _socket_state == WebSocketPeer.State.STATE_OPEN
	if not successful:
		set_process(false)
		_socket = null
		connection_active = false
		return false
	connection_active = true
	return true
	
## ASYNC initialize connector with the configurator json
func send_final_configurator_JSON(configurator_JSON: StringName) -> void:
	if not _socket:
		return
	_socket.send((configurator_JSON.to_ascii_buffer()).compress(FileAccess.COMPRESSION_DEFLATE))
	await get_tree().create_timer(0.2).timeout # await connector to process





func on_tick() -> void:
	_FEAGI_data = {}
	if _socket:
		for device_name in _FEAGI_sensors_reference:
			_FEAGI_data[device_name] = _FEAGI_sensors_reference[device_name].get_data_as_byte_array()
		_socket.websocket_send_text(str(_FEAGI_data))
