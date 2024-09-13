@tool
extends VBoxContainer
class_name FEAGI_UI_Panel_ActionPresserConfigSet
## Allows UI configuration for a several [FEAGI_Emulated_Input]s

const PRESSER_UI_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Resources/Prefabs/ActionPresserSet/ActionPresser/FEAGI_UI_Panel_ActionPresserConfig.tscn")

@export_category("Must Be Equal Length") # and in same order!
@export var keys: Array[StringName]
@export var action_pressers: Array[FEAGI_Emulated_Input]
@export var keys_mapped_to_friendly_names: Array[StringName]


func setup_from_export_vars() -> void:
	if len(keys) != len(action_pressers) or len(action_pressers) != len(keys_mapped_to_friendly_names):
		push_error("FEAGI: Action presser Set configured with incorrect number of vars!")
		return
	for i in len(action_pressers):
		add_presser_UI(keys_mapped_to_friendly_names[i], keys[i], action_pressers[i])

func setup_given_existing_configs(existing: Dictionary) -> void: ## Key'd by the key string, with the value being the associated [FEAGI_Emulated_Input]
	for key in existing:
		var index: int = keys.find(key)
		add_presser_UI(keys_mapped_to_friendly_names[index], key, existing[key])


func add_presser_UI(friendly_name: StringName, key: StringName, action_presser: FEAGI_Emulated_Input) -> void:
	var UI: FEAGI_UI_Panel_ActionPresserConfig = PRESSER_UI_PREFAB.instantiate()
	add_child(UI)
	UI.setup(key, friendly_name, action_presser)

## Export the values of all UI elements, as a dict key'd by the key value of each [FEAGI_Emulated_Input] value
func export_as_dict() -> Dictionary:
	var output: Dictionary = {}
	for i in get_child_count():
		var child: FEAGI_UI_Panel_ActionPresserConfig = get_child(i)
		output.merge(child.export_as_dict())
	return output

## Deletes all child [FEAGI_UI_Panel_ActionPresserConfig] elements
func clear() -> void:
	while len(get_child_count()) > 0:
		get_child(0).queue_free()
