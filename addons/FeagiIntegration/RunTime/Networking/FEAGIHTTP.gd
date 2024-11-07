extends HTTPRequest
class_name FEAGIHTTP
##Single use node for sending API requests to FEAGI

signal FEAGI_call_complete(response_code: int, data: PackedByteArray)
const HEADER: PackedStringArray = ["Content-Type: application/json"]

## ASYNC, Returns true if FEAGI at the given address is alive or not
static func ping_if_FEAGI_alive(full_feagi_address: StringName, parent_node: Node) -> bool:
	full_feagi_address = full_feagi_address
	var worker: FEAGIHTTP = FEAGIHTTP.new()
	worker.name = "health_check"
	parent_node.add_child(worker)
	worker.send_GET_request(full_feagi_address, "/v1/system/health_check")
	var response: Array = await worker.FEAGI_call_complete
	worker.queue_free()
	if len(response) != 2:
		return false
	return response[0] != 0
	
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
