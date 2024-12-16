@tool
extends MarginContainer
class_name Editor_FEAGI_UI_Panel_InputSequenceElement
## Handles the panel UI for a specific step of a Input Sequence

signal request_add_sequence_element_to_index(requested_index: int)

var _step1_selection: VBoxContainer
var _step2_delay: VBoxContainer
var _step2_input: VBoxContainer
var _option_buttons: HBoxContainer
var _emu_input_config: Editor_FEAGI_UI_Panel_EmuInputConfiguration
var _delay_length_UI: SpinBox
var _input_hold_length_UI: SpinBox

## Initialize the UI element, including with a existing predefined input step if available
func setup(predefined_input: FEAGI_EmuPredefinedInput = null) -> void:
	_step1_selection = $PanelContainer/MarginContainer/VBoxContainer/Step1_type
	_step2_delay = $PanelContainer/MarginContainer/VBoxContainer/Step2_Delay
	_step2_input = $PanelContainer/MarginContainer/VBoxContainer/Step2_Input
	_option_buttons = $PanelContainer/MarginContainer/VBoxContainer/options
	_emu_input_config = $PanelContainer/MarginContainer/VBoxContainer/Step2_Input/EditorFeagiUiPanelEmuInputConfiguration
	_delay_length_UI = $PanelContainer/MarginContainer/VBoxContainer/Step2_Delay/HBoxContainer/SpinBox
	_input_hold_length_UI = $PanelContainer/MarginContainer/VBoxContainer/Step2_Input/HBoxContainer/SpinBox
	
	_emu_input_config.hide_feagi_threshold_UI()
	
	if !predefined_input:
		_step1_choose_mode()
		return
	if predefined_input.emu_input:
		_step2_choose_input(predefined_input.emu_input, predefined_input.seconds_to_hold)
	else:
		_step2_choose_delay(predefined_input.seconds_to_hold)

## Return the predefined input step as configured in the UI
func export() -> FEAGI_EmuPredefinedInput:
	if _step1_selection.visible:
		# user picked nothing
		return null
	var output: FEAGI_EmuPredefinedInput = FEAGI_EmuPredefinedInput.new()
	
	if _step2_delay.visible:
		output.seconds_to_hold = _delay_length_UI.value
	
	if _step2_input.visible:
		output.emu_input = _emu_input_config.export_emu_input()
		if !output.emu_input:
			# user selected input but failed to configure it
			return null
		output.seconds_to_hold = _input_hold_length_UI.value
	return output

func _step1_choose_mode() -> void:
	_step1_selection.visible = true
	_step2_delay.visible = false
	_step2_input.visible = false
	_option_buttons.visible = false

func _step2_choose_delay(delay: float = 0.1) -> void:
	_step1_selection.visible = false
	_step2_delay.visible = true
	_step2_input.visible = false
	_option_buttons.visible = true
	
	_delay_length_UI.value = delay

func _step2_choose_input(input: FEAGI_EmuInput_Abstract = null, seconds_to_hold: float = 0.1) -> void:
	_step1_selection.visible = false
	_step2_delay.visible = false
	_step2_input.visible = true
	_option_buttons.visible = true
	_emu_input_config.setup("Predefined Input", FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1, input)
	_input_hold_length_UI.value = seconds_to_hold

func _add_step_before_pressed():
	request_add_sequence_element_to_index.emit(get_index())
