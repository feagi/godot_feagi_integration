extends RefCounted
class_name FEAGI_RunTime_FakeFEAGIInterface
## Handles communication with browser level fake feagi emulator via postmessage

signal recieved_bytes(bytes: PackedByteArray)

var _callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_recieve_message)

func _init() -> void:
	var browser_window: JavaScriptObject = JavaScriptBridge.get_interface("window")
	browser_window.addEventListener("message", _callback)

func _on_recieve_message(incoming_JS_data) -> void:
	var js_data = incoming_JS_data[0] # data is encapsulated in an array, within a [JavaScriptObject]
	var js_string: String =  js_data["data"]
	recieved_bytes.emit(js_string.to_ascii_buffer())
