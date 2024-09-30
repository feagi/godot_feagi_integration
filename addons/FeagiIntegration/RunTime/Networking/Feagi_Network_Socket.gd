"""
Copyright 2016-2024 The FEAGI Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================
"""
extends RefCounted
class_name Feagi_Network_Socket
## Essentially an extension of [WebSocketPeer] for FEAGI

const DEF_SOCKET_MAX_QUEUED_PACKETS: int = 10000000 # Cancer
const DEF_SOCKET_INBOUND_BUFFER_SIZE: int = 10000000 # 10 MB holy cow
const DEF_SOCKET_BUFFER_SIZE: int = 10000000 # 10 MB holy cow

signal connection_attempt_complete() ## Fires once an attempt to connect is over (either in success or failure)
signal socket_state_changed(state: WebSocketPeer.State)
signal FEAGI_returned_data(data: PackedByteArray)

var websocket_state: WebSocketPeer.State:
	get: return _websocket_state
var _websocket_state: WebSocketPeer.State = WebSocketPeer.State.STATE_CLOSED
var _socket: WebSocketPeer
var _closed_warning: bool = true
var _ready: bool = false

func _init(feagi_socket_address: StringName) -> void:
	_socket =  WebSocketPeer.new()
	
	_socket.connect_to_url(feagi_socket_address)
	_socket.inbound_buffer_size = DEF_SOCKET_INBOUND_BUFFER_SIZE

## Attempts to send data over websocket
func websocket_send_text(data: String) -> void:
	if _websocket_state != WebSocketPeer.STATE_OPEN:
		if _closed_warning:
			push_warning("FEAGI: Unable to send data to closed socket!")
		_closed_warning = false
		return
	_closed_warning = true
	_socket.send((data.to_ascii_buffer()).compress(FileAccess.COMPRESSION_DEFLATE))

func websocket_send_bytes(data: PackedByteArray) -> void:
	if _websocket_state != WebSocketPeer.STATE_OPEN:
		if _closed_warning:
			push_warning("FEAGI: Unable to send data to closed socket!")
		_closed_warning = false
		return
	_closed_warning = true
	_socket.send(data.compress(FileAccess.COMPRESSION_DEFLATE))

## Triggers a close of the websocket with default code 1000. NOTE: Will trigger 'socket_state_changed'
func websocket_close() -> void:
	_socket.close()

## responsible for polling state of websocket, since its not event driven. This must be called by _process() of a node for this object to function
func socket_status_poll() -> void:
	_socket.poll()
	_refresh_socket_state()
	match _websocket_state:
		WebSocketPeer.STATE_OPEN:
			while _socket.get_available_packet_count():
				#FEAGI_returned_data.emit(_socket.get_packet().decompress(DEF_SOCKET_BUFFER_SIZE, FileAccess.COMPRESSION_DEFLATE)) # If Decompressing
				FEAGI_returned_data.emit(_socket.get_packet())
				
		WebSocketPeer.STATE_CLOSED:
			var close_code: int = _socket.get_close_code()
			var close_reason: String = _socket.get_close_reason()
			push_warning("FEAGI: WebSocket closed with code: %d, reason %s. Clean: %s" % [close_code, close_reason, close_code != -1])

func _refresh_socket_state() -> void:
	var new_state: WebSocketPeer.State = _socket.get_ready_state()
	if new_state == _websocket_state:
		## no change, doesn't matter which we return
		return
	if _websocket_state == WebSocketPeer.State.STATE_CONNECTING:
		## Previously was connecting, now not:
		connection_attempt_complete.emit()
	_websocket_state = new_state
	socket_state_changed.emit(new_state)
