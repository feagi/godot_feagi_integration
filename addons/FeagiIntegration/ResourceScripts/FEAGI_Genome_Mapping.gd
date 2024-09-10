@tool
extends Resource
class_name FEAGI_Genome_Mapping

@export var FEAGI_enabled: bool = true
@export var debugger_enabled: bool = true
@export var delay_seconds_between_frames: float = 0.05
@export var configuration_JSON: StringName = ""

@export var sensors: Dictionary = {} ## A dictionary of [FEAGI_IOHandler_Sensory_Base]s key'd by their device type name + "_" + device name

func save_config() -> void:
	FEAGI_PLUGIN.confirm_config_directory()
	ResourceSaver.save(self, FEAGI_PLUGIN.get_genome_mapping_path())
