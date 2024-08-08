@tool
extends VBoxContainer
class_name FEAGISectionSensory

signal added_sensory(obj)

var _dropdown: OptionButton
var _scroll_contents: VBoxContainer

func _ready() -> void:
	_dropdown = $Header/TypeToAdd
	_scroll_contents = $ScrollContainer/VBoxContainer

func setup(acceptable_input_types: Array[FEAGIAgentConfiguratorConfigurator.INPUT_TYPE]) -> void:
	for acceptable_input_type in acceptable_input_types:
		_dropdown.add_item(FEAGIAgentConfiguratorConfigurator.get_input_friendly_name(acceptable_input_type), int(acceptable_input_type))

## CLears all internal items and dropdown. Essentially a reset
func clear() -> void:
	_dropdown.clear()

func _add_item_pressed() -> void:
	var type_ID_raw: int = _dropdown.get_selected_id()
	
	var section: PackedScene
	match(type_ID_raw):
		_:
			section = load("res://addons/FeagiIntegration/Window/Local_IO/Input_Camera/FEAGIInputGodotCamera.tscn")
	
	var new_section = section.instantiate()
	_scroll_contents.add_child(new_section)
	new_section.setup("Camera", FEAGIInputGodotCamera.CAPTURE_METHOD.WHOLE_SCREEN_CAPTURE)
	added_sensory.emit(new_section)
