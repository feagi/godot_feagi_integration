@tool
extends PanelContainer
class_name FEAGI_UI_Panel

var _section_sensory: FEAGI_UI_Panel_Devices

func setup() -> void:
	_section_sensory = $ScrollContainer/Options/TabContainer/Sensory/PanelContainer/FeagiUiPanelDevices
	
	var json: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FEAGI_PLUGIN.TEMPLATE_DIR))
	_section_sensory.setup(true, json["input"])
