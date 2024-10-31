@tool
extends Resource
class_name FEAGI_Genome_Mapping

@export var FEAGI_enabled: bool = true
@export var debugger_enabled: bool = true
@export var delay_seconds_between_frames: float = 0.05
@export var configuration_JSON: StringName = ""

@export var sensors: Dictionary = {} ## A dictionary of [FEAGI_IOConnector_Sensor_Base]s key'd by their device type name + "_" + device name
@export var motors: Dictionary = {} ## A dictionary of [FEAGI_IOConnector_Motor_Base]s key'd by their device type name + "_" + device name

func save_config() -> void:
	FEAGI_PLUGIN_CONFIG.confirm_config_directory()
	if FileAccess.file_exists(FEAGI_PLUGIN_CONFIG.get_genome_mapping_path()):
		var error: Error = DirAccess.remove_absolute(FEAGI_PLUGIN_CONFIG.get_genome_mapping_path())
		if error != OK:
			push_error("FEAGI: Unable to overwrite Genome Mapping file!")
	ResourceSaver.save(self, FEAGI_PLUGIN_CONFIG.get_genome_mapping_path())
	take_over_path(FEAGI_PLUGIN_CONFIG.get_genome_mapping_path()) # work around for godot failing to automatically reload file
