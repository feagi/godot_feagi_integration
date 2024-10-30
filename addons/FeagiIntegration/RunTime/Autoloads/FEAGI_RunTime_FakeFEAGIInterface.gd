extends RefCounted
class_name FEAGI_RunTime_FakeFEAGIInterface
## Handles communication with browser level fake feagi emulator via postmessage

signal recieved_bytes(bytes: PackedByteArray)

var _callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_recieve_message)

func _init() -> void:
	var browser_window: JavaScriptObject = JavaScriptBridge.get_interface("window")
	browser_window.addEventListener("message", _callback)

func _on_recieve_message(incoming_JS_data) -> void:
	print("1: " + str(incoming_JS_data))
	print("2: " + (incoming_JS_data as String))
	if incoming_JS_data.data:
		print("3: " + (incoming_JS_data.data))
	if incoming_JS_data.message:
		print("4: " + (incoming_JS_data.message))
	recieved_bytes.emit(incoming_JS_data.data as PackedByteArray)
