extends RefCounted
class_name FEAGI_RunTime_MetricReporting

const FEAGI_PATH_FITNESS_CRITERIA: StringName = "/v1/training/fitness_criteria"
const FEAGI_PATH_FITNESS_STATS: StringName = "/v1/training/fitness_stats"

var _full_endpoint_URL: StringName
var _node_for_parenting_http_node: Node
var _sent_configuration: bool = false
var _acceptable_keys: PackedStringArray

func _init(feagi_URL: StringName, parent_node: Node):
	_full_endpoint_URL = feagi_URL
	_node_for_parenting_http_node = parent_node

## A default / starting point metric setup to use in the 'configure_endgame_metric_settings' call. NOTE all values must be positive
const DEFAULT_KEYS_AND_WEIGHTS: Dictionary = {
		"time_alive": 0.5,
		"max_level_reached": 0.5,
		"score_trying_to_max": 1.0,
}

## Attempts to configure FEAGI with metric settings to be used. Returns true is succesful 
func configure_endgame_metric_settings(string_keys_mapped_to_float_weights: Dictionary = DEFAULT_KEYS_AND_WEIGHTS) -> bool:
	if !_node_for_parenting_http_node:
		push_error("FEAGI: Invalid parent node specified for metric endpoint worker!")
		return false
	var keys_to_accept: PackedStringArray = []
	
	## Check keys are valid
	if len(string_keys_mapped_to_float_weights) == 0:
		push_error("FEAGI: At least one key-pair must be specified for the metrics!")
		return false
	for key in string_keys_mapped_to_float_weights.keys():
		if not (key is String or key is StringName):
			push_error("FEAGI: Invalid key type for endpoint metric configuration! Expected String!")
			return false 
		elif string_keys_mapped_to_float_weights[key] is not float:
			push_error("FEAGI: Invalid value type for endpoint metric configuration!") # I Never Asked for This
			return false
		elif string_keys_mapped_to_float_weights[key] < 0.0:
			push_error("FEAGI: Float Scalars must all be positive!")
			return false
		else:
			keys_to_accept.append(key)
	
	# All is good, send request
	_acceptable_keys = keys_to_accept
	var worker: FEAGIHTTP = FEAGIHTTP.new()
	_node_for_parenting_http_node.add_child(worker)
	worker.send_POST_request(_full_endpoint_URL, FEAGI_PATH_FITNESS_CRITERIA, JSON.stringify(string_keys_mapped_to_float_weights))
	var results: Array = await worker.FEAGI_call_complete
	if results[0] == 200:
		_sent_configuration = true
		print("FEAGI: Sent Metric Configuration!")
		return true
	_acceptable_keys = []
	push_error("FEAGI: Was unable to send metric configuration to FEAGI!")
	return false


## Sends the metrcs of game to FEAGI. Returns true if succesful
func send_endgame_metrics(string_keys_mapped_to_float_values: Dictionary, metadata: Dictionary = {}) -> bool:
	if !_node_for_parenting_http_node:
		push_error("FEAGI: Invalid parent node specified for metric endpoint worker!")
		return false
	if !_sent_configuration:
		push_error("FEAGI: Configuration must be sent first before sending metrics!")
		return false
	
	# Check data is valid
	var searching_keys: Array = string_keys_mapped_to_float_values.keys() # Seperated to avoid issues of array size changes
	var remaining: Array = searching_keys.duplicate()
	for key in searching_keys:
		if not (key is String or key is StringName):
			push_error("FEAGI: Invalid key type for endpoint metrics! Expected String!")
			return false
		elif key as String not in _acceptable_keys:
			push_error("FEAGI: Unknown metric key %s! Skipping!")
		elif string_keys_mapped_to_float_values[key] is not float:
			push_error("FEAGI: Invalid value type for endpoint metrics!")
			return false
		remaining.erase(key)
	if len(remaining) != 0:
			push_error("FEAGI: Unexpected keys in metrics!")
			return false
	
	# Check metadata is all strings
	for key in metadata.keys():
		if not (key is String or key is StringName):
			push_error("FEAGI: All Metadata keys must be strings!") 
			return false
		if not (metadata[key] is String or metadata[key] is StringName):
			push_error("FEAGI: All Metadata values must be strings!")
			return false
	
	# All looks good, lets send request
	var sending_dict: Dictionary = {
		"FITNESS_KEYS": string_keys_mapped_to_float_values,
		"METADATA": metadata
		}
	var worker: FEAGIHTTP = FEAGIHTTP.new()
	_node_for_parenting_http_node.add_child(worker)
	worker.send_PUT_request(_full_endpoint_URL, FEAGI_PATH_FITNESS_STATS, JSON.stringify(sending_dict))
	var results: Array = await worker.FEAGI_call_complete
	if results[0] == 200:
		print("FEAGI: Sent Metric Data!")
		return true
	return false
