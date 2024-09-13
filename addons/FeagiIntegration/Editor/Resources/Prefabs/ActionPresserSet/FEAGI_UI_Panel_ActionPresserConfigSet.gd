@tool
extends VBoxContainer
class_name FEAGI_UI_Panel_ActionPresserConfigSet
## Allows UI configuration for a several [FEAGI_Emulated_Input]s

const PRESSER_UI_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Resources/Prefabs/ActionPresserSet/ActionPresser/FEAGI_UI_Panel_ActionPresserConfig.tscn")

@export_category("Must Be Equal Length")
@export var keys: Array[StringName]
@export var action_pressers: Array[FEAGI_Emulated_Input]
@export var keys_mapped_to_friendly_names: Dictionary # We repeat Keys twice in a sense because we need the array for the order


func setup_from_export_vars() -> void:
	if len(keys) != len(action_pressers) or len(action_pressers) != len(keys_mapped_to_friendly_names):
		push_error("FEAGI: Action presser Set configured with incorrect number of vars!")
		return
	for i in len(action_pressers):
		add_presser_UI(keys_mapped_to_friendly_names[keys[i]], keys[i], action_pressers[i])


func add_presser_UI(friendly_name: StringName, key: StringName, action_presser: FEAGI_Emulated_Input) -> void:
	var UI: FEAGI_UI_Panel_ActionPresserConfig = PRESSER_UI_PREFAB.instantiate()
	add_child(UI)
	UI.setup(key, friendly_name, action_presser)

## Export the values of all UI elements, as a dict key'd by the key value of each [FEAGI_Emulated_Input] value
func export_as_dict() -> Dictionary:
	var output: Dictionary = {}
	for i in len(get_child_count()):
		var child: FEAGI_UI_Panel_ActionPresserConfig = get_child(i)
		output.merge(child.export_as_dict())
	return output
	
