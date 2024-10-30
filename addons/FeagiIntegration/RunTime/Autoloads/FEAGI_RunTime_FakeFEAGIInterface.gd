extends RefCounted
class_name FEAGI_RunTime_FakeFEAGIInterface
## Handles communication with browser level fake feagi emulator via postmessage

signal recieved_bytes(bytes: PackedByteArray)

var _callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_recieve_message)

func _init() -> void:
	var browser_window: JavaScriptObject = JavaScriptBridge.get_interface("window")
	browser_window.addEventListener("message", _callback)

func _on_recieve_message(incoming_JS_data) -> void:
	#print("1: " + str(incoming_JS_data))
	#print("2: " + (incoming_JS_data as String))
	print("first 2 removed")
	print("42: + " + incoming_JS_data[0]) # WHY  https://docs.godotengine.org/cs/4.x/tutorials/platform/web/javascript_bridge.html#callbacks
	print("first 2 removed 1")
	print("420 + " + incoming_JS_data[0].data) # WHY  https://docs.godotengine.org/cs/4.x/tutorials/platform/web/javascript_bridge.html#callbacks
	print("first 2 removed 2")
	print("421 + " + str(JSON.parse_string(incoming_JS_data[0])))
	print("first 2 removed 3")
	print("422 + " + str(JSON.parse_string(incoming_JS_data[0].data)))
	print("first 2 removed 4")
	if incoming_JS_data.data:
		print("3: " + (incoming_JS_data.data))
	if incoming_JS_data.message:
		print("4: " + (incoming_JS_data.message))
	print("99: " + (incoming_JS_data)["data"])
	print("first 2 removed 6")
	print("990: " + (incoming_JS_data as Dictionary)["data"])
	print("first 2 removed 7")
	
	#recieved_bytes.emit(incoming_JS_data.data as PackedByteArray)
