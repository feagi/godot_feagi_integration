extends FEAGI_NetworkingConnector_Base
class_name FEAGI_NetworkingConnector_PM
## "Network" IO using PostMessage to FakeFEAGI

var _callback: JavaScriptObject = JavaScriptBridge.create_callback(_on_recieve_message)

func setup_post_message() -> bool:
	if !FEAGI_JS.is_web_build():
		return false
	var browser_window: JavaScriptObject = JavaScriptBridge.get_interface("window")
	if !browser_window:
		return false
	browser_window.addEventListener("message", _callback)
	return true
	
func run_process(_delta: float) -> void:
	pass # We have no need to process anything

func send_data(_data: PackedByteArray) -> void:
	pass # as of now PM cannot be used for this

func _on_recieve_message(incoming_JS_data) -> void:
	var js_data = incoming_JS_data[0] # data is encapsulated in an array, within a [JavaScriptObject]
	var js_string: String =  js_data["data"]
	recieved_bytes.emit(js_string.to_ascii_buffer())
