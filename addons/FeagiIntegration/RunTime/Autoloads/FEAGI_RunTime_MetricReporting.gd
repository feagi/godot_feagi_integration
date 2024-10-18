extends RefCounted
class_name FEAGI_RunTime_MetricReporting

const PATH_TO_METRIC: StringName = ""

var _full_endpoint_URL: StringName
var _node_for_parenting_http_node: Node
var _sent_configuration: bool = false
var _acceptable_keys: PackedStringArray

func _init(feagi_URL: StringName, parent_node: Node):
	_full_endpoint_URL = feagi_URL
	_node_for_parenting_http_node = parent_node


func configure_endgame_metric_settings(string_keys_mapped_to_float_weights: Dictionary) -> bool:
	for key in string_keys_mapped_to_float_weights.keys():
		if not (key is String or key is StringName):
			push_error("FEAGI: Invalid key type for endpoint metric configuration!")
			return false
		elif string_keys_mapped_to_float_weights[key] is not float:
			push_error("FEAGI: Invalid value type for endpoint metric configuration!")
			return false
		else:
			_acceptable_keys.append(key)
	var sending_dict: Dictionary = {"FITNESS_KEYS_SCALING": string_keys_mapped_to_float_weights}
	if await _send_dictionary_to_endpoint(sending_dict):
		_sent_configuration = true
		return true
	_acceptable_keys = []
	return false

func send_endgame_metrics(string_keys_mapped_to_float_values: Dictionary, metadata: Dictionary) -> bool:
	var searching_keys: Array = string_keys_mapped_to_float_values.keys() # Seperated to avoid issues of array size changes
	for key in searching_keys:
		if not (key is String or key is StringName):
			push_error("FEAGI: Invalid key type for endpoint metrics!")
			return false
		elif key as String not in _acceptable_keys:
			push_error("FEAGI: Unknown metric key %s! Skipping!")
			string_keys_mapped_to_float_values.erase(key)
		elif string_keys_mapped_to_float_values[key] is not float:
			push_error("FEAGI: Invalid value type for endpoint metrics!")
			return false
	var sending_dict: Dictionary = {
		"FITNESS_KEYS": string_keys_mapped_to_float_values,
		"METADATA": metadata
		}
	return await _send_dictionary_to_endpoint(sending_dict)

func _send_dictionary_to_endpoint(dict: Dictionary) -> bool:
	if !_node_for_parenting_http_node:
		push_error("FEAGI: Invalid parent node specified for metric endpoint worker!")
		return false
	var worker: FEAGIHTTP = FEAGIHTTP.new()
	_node_for_parenting_http_node.add_child(worker)
	worker.send_POST_request(_full_endpoint_URL, PATH_TO_METRIC, JSON.stringify(dict))
	var results: Array = await worker.FEAGI_call_complete
	if results[0] != 200:
		push_error("FEAGI: Unable to connect to metric endpoint!")
		return false
	return true
