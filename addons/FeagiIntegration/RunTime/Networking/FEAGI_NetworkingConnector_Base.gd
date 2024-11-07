extends RefCounted
class_name FEAGI_NetworkingConnector_Base
# Base interface for all networking operations

enum MODE {NONE, WS_ONLY, PM_ONLY, WS_AND_PM}

signal connection_closed()
signal recieved_bytes(bytes: PackedByteArray)

var connection_active: bool:
	get: return _connection_active

var _connection_active: bool  = false

func _init() -> void:
	connection_closed.connect(_on_connection_close)

func run_process(_delta: float) -> void:
	assert(false, "Do not use the base class directly!")

func send_data(_data_uncompressed: PackedByteArray) -> void:
	assert(false, "Do not use the base class directly!")
 
func send_configurator_JSON(_final_JSON: StringName) -> void:
	assert(false, "Do not use the base class directly!")

func _on_connection_close() -> void:
	_connection_active = false
