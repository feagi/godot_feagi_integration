@tool
extends RefCounted
class_name FEAGIActionMap
## Essentially just a data structure to pass mapping information

const VAR_NAMES: PackedStringArray = ["OPU_mapping_to", "neuron_X_index", "godot_action", "threshold", "pass_FEAGI_weight_instead_of_max", "optional_signal_name"]

var OPU_mapping_to: StringName
var neuron_X_index: int
var godot_action: StringName
var threshold: float = 0.5
var pass_FEAGI_weight_instead_of_max: bool
var optional_signal_name: StringName

func _init(OPU_mapping_to_: StringName, neuron_X_index_: int, godot_action_: StringName, threshold_: float, pass_FEAGI_weight_instead_of_max_: bool, optional_signal_name_: StringName) -> void:
	OPU_mapping_to = OPU_mapping_to_
	neuron_X_index = neuron_X_index_
	godot_action = godot_action_
	pass_FEAGI_weight_instead_of_max = pass_FEAGI_weight_instead_of_max_
	optional_signal_name = optional_signal_name_
	
## Returns if a Dictionary has the valid keys to be a [FEAGIActionMap]
static func is_valid_dict(verify: Dictionary) -> bool:
	for variable: StringName in VAR_NAMES:
		if !verify.has(variable):
			return false
	return true
	#TODO check types?

## Creates this object from a dictionary that was confirmed valid
static func create_from_valid_dict(dict: Dictionary) -> FEAGIActionMap:
	return FEAGIActionMap.new(
		dict["OPU_mapping_to"],
		dict["neuron_X_index"],
		dict["godot_action"],
		dict["threshold"],
		dict["pass_FEAGI_weight_instead_of_max"],
		dict["optional_signal_name"],
	)

## Exports the contents of this object as a json for easy json export
func export_as_dictionary() -> Dictionary:
	return {
		"OPU_mapping_to": str(OPU_mapping_to),
		"neuron_X_index": neuron_X_index,
		"godot_action": str(godot_action),
		"threshold": threshold,
		"pass_FEAGI_weight_instead_of_max": pass_FEAGI_weight_instead_of_max,
		"optional_signal_name": str(optional_signal_name),
	}
