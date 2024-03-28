extends HTTPRequest
class_name FEAGIHTTP
##Allows for sending of HTTP requests to FEAGI
const DEF_HEADERSTOUSE: PackedStringArray = ["Content-Type: application/json"]

signal FEAGI_call_complete(response_code: int, data: PackedByteArray)

func _ready() -> void:
	request_completed.connect(_on_call_complete)

func send_POST_request(base_URL: StringName, URL_path: StringName, json: StringName) -> void:
	request(base_URL + URL_path, DEF_HEADERSTOUSE, HTTPClient.METHOD_POST, json)

func _on_call_complete(_result: HTTPRequest.Result, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	FEAGI_call_complete.emit(response_code, body)
	queue_free()
