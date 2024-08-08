@tool
extends PanelContainer
class_name FEAGIPluginConfiguratorWindow

@export var initial_configurator: FEAGIAgentConfiguratorConfigurator

var _plugin_main_script: FEAGIPluginInit

var _configurator_configurator: FEAGIAgentConfiguratorConfigurator

var _status_summary: RichTextLabel

var _section_sensory: FEAGISectionSensory



func _ready() -> void:
	_status_summary = $ScrollContainer/Options/DesContainer/Status
	_section_sensory = $ScrollContainer/Options/TabContainer/Sensory/PanelContainer/Sensory
	
	tree_exited.connect(_user_closing_window)
	load_configurator_configurator(initial_configurator)

func setup(plugin_main_script: FEAGIPluginInit) -> void:
	_plugin_main_script = plugin_main_script


func load_configurator_configurator(config: FEAGIAgentConfiguratorConfigurator) -> void:
	_configurator_configurator = config
	_section_sensory.clear()
	_section_sensory.setup(config.supported_input_types)




## Called when the window is closing for any reason. Freeing of the resource is already handled by [FEAGIPluginInit]
func _user_closing_window() -> void:
	pass

## Sets the summary status top label to indicate if FEAGI is ready or not
func _set_status_summary(is_ready: bool) -> void:
	if is_ready:
		_status_summary.text = "Feagi Integration is [b]ready[/b]"
	else:
		_status_summary.text = "Feagi Integration is [b]not ready[/b]"
