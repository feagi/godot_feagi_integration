extends FEAGI_NetworkingConnector_Base
class_name FEAGI_NetworkingConnector_PM_and_WS
## Hybrid Network Connector class, can do both PM and WS

var _PM: FEAGI_NetworkingConnector_PM = null
var _WS: FEAGI_NetworkingConnector_WS = null

## Attempts to first setup post message then websocket. If either fails this whole connector has failed
func setup_post_message_and_websocket(full_connector_WS_address: StringName) -> bool:
	_PM = FEAGI_NetworkingConnector_PM.new()
	if !_PM.setup_post_message():
		_PM = null
		return false
	_WS = FEAGI_NetworkingConnector_WS.new()
	if !(await _WS.setup_websocket(full_connector_WS_address)):
		_PM = null
		_WS = null
		return false
	_PM.recieved_bytes.connect(func(data: PackedByteArray): recieved_bytes.emit(data))
	_WS.recieved_bytes.connect(func(data: PackedByteArray): recieved_bytes.emit(data))
	_PM.connection_closed.connect(func(): connection_closed.emit()) # lol
	_WS.connection_closed.connect(func(): connection_closed.emit())
	return true
	
func run_process(_delta: float) -> void:
	if _WS:
		_WS.run_process(_delta)

func send_data(data_uncompressed: PackedByteArray) -> void:
	if _WS:
		_WS.send_data(data_uncompressed)
