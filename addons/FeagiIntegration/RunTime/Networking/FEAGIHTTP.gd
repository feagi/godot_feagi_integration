extends HTTPRequest
class_name FEAGIHTTP
##Single use node for sending API requests to FEAGI

signal FEAGI_call_complete(response_code: int, data: PackedByteArray)

const HEADER: PackedStringArray = ["Content-Type: application/json"]

func _ready() -> void:
	request_completed.connect(_on_call_complete)

func send_GET_request(base_URL: StringName, URL_path: StringName = "") -> void:
	request(base_URL + URL_path, HEADER, HTTPClient.METHOD_GET)

func send_POST_request(base_URL: StringName, URL_path: StringName, json: StringName) -> void:
	request(base_URL + URL_path, HEADER, HTTPClient.METHOD_POST, json)

func send_PUT_request(base_URL: StringName, URL_path: StringName, json: StringName) -> void:
	request(base_URL + URL_path, HEADER, HTTPClient.METHOD_PUT, json)

func send_DELETE_request(base_URL: StringName, URL_path: StringName, json: StringName) -> void:
	request(base_URL + URL_path, HEADER, HTTPClient.METHOD_DELETE, json)

func _on_call_complete(_result: HTTPRequest.Result, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	FEAGI_call_complete.emit(response_code, body)
	queue_free()
