extends RefCounted
class_name FEAGI_RunTime_FakeFEAGIInterface
## Handles communication with browser level fake feagi emulator via postmessage

signal recieved_bytes(bytes: PackedByteArray)

var _callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_recieve_message)

func _init() -> void:
	var browser_window: JavaScriptObject = JavaScriptBridge.get_interface("window")
	browser_window.addEventListener("message", _callback)

func _on_recieve_message(incoming_JS_data) -> void:
	print(incoming_JS_data.data)
	recieved_bytes.emit(incoming_JS_data.data as PackedByteArray)
