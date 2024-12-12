@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_EmuInputConfiguration

var _data_type: FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE

var _1button: Button
var _2scroll: ScrollContainer
var _2scroll_godotInputEvent: Button
var _2scroll_keyboard: Button
var _3godotInputEvent: BoxContainer
var _3keyboard: BoxContainer
var _reset: Button

func setup(motor_output_name: StringName, motor_output_datatype: FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE, preinit_emuInput: FEAGI_EmuInput_Abstract = null) -> void:
	$GodotInputName.text = motor_output_name
	_data_type = motor_output_datatype
	match(motor_output_datatype):
		FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1:
			$GodotInputType.text = "0 to 1"
		FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_M1_TO_1:
			$GodotInputType.text = "-1 to 1"
		FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.VEC2:
			$GodotInputType.text = "<-1, -1> to <1, 1>"
	_1button = $VBoxContainer/start
	_2scroll = $VBoxContainer/emuselect
	_2scroll_godotInputEvent = $VBoxContainer/emuselect/VBoxContainer/GodotInputEvent
	_2scroll_keyboard = $VBoxContainer/emuselect/VBoxContainer/Keyboard
	_3godotInputEvent = $VBoxContainer/InputEventConfig
	_3keyboard = $VBoxContainer/Keyboard
	_reset = $VBoxContainer/Reset
	
	if !preinit_emuInput:
		_step_1_set_to_unconfigured()
		return
	if preinit_emuInput is FEAGI_EmuInput_GodotInputEvent:
		_step_3_configure_godotInputEvent(preinit_emuInput)
	if preinit_emuInput is FEAGI_EmuInput_KeyboardPress:
		_step_3_configure_keyboard(preinit_emuInput)

## Exports an emu input object. Will either export a specific child of [FEAGI_EmuInput_Abstract] or null if none is selected (or if something is wrong)
func export_emu_input() -> FEAGI_EmuInput_Abstract:
	if _3godotInputEvent.visible:
		var output: FEAGI_EmuInput_GodotInputEvent = FEAGI_EmuInput_GodotInputEvent.new()
		var dropdown: OptionButton = $VBoxContainer/InputEventConfig/HBoxContainer/OptionButton
		output.godot_input_event_name = dropdown.get_item_text(dropdown.selected)
		output.use_bang_bang_instead_of_actual_value = $VBoxContainer/InputEventConfig/HBoxContainer2/enablethresholding.button_pressed
		output.bang_bang_threshold = $VBoxContainer/InputEventConfig/HBoxContainer3/SpinBox.value
		return output
	
	if _3keyboard.visible:
		var output: FEAGI_EmuInput_KeyboardPress = FEAGI_EmuInput_KeyboardPress.new()
		var dropdown: OptionButton = $VBoxContainer/Keyboard/HBoxContainer/OptionButton
		output.key_to_press = dropdown.get_item_id(dropdown.selected)
		output.bang_bang_threshold = $VBoxContainer/Keyboard/HBoxContainer3/SpinBox.value
		return output
	
	return null

## Used in the case of sequences, when we dont care to set FEAGI thresholding since we ourselves are supplying the information, so no need to show those options
func hide_feagi_threshold_UI() -> void:
	$VBoxContainer/InputEventConfig/HBoxContainer2.visible = false
	$VBoxContainer/InputEventConfig/HBoxContainer3.visible = false
	$VBoxContainer/Keyboard/HBoxContainer3.visible = false

func _step_1_set_to_unconfigured() -> void:
	_1button.visible = true
	_2scroll.visible = false
	_3godotInputEvent.visible = false
	_3keyboard.visible = false
	_reset.visible = false


func _step_2_ask_emuInput_type() -> void:
	_1button.visible = false
	_2scroll.visible = true
	_3godotInputEvent.visible = false
	_3keyboard.visible = false
	_reset.visible = false
	# NOTE make sure you disable irrelevant buttons here depending on _data_type


## Jumps to the Godot Input Event Configuration, including prefilling from given values
func _step_3_configure_godotInputEvent(preset_godot_event: FEAGI_EmuInput_GodotInputEvent = null) -> void:
	_1button.visible = false
	_2scroll.visible = false
	_3godotInputEvent.visible = true
	_3keyboard.visible = false
	_reset.visible = true
	
	var dropdown: OptionButton = $VBoxContainer/InputEventConfig/HBoxContainer/OptionButton
	InputMap.load_from_project_settings() # ensure we have the full info!
	var possible_actions: Array[StringName] = InputMap.get_actions()
	dropdown.clear()
	dropdown.add_item("No Action")
	dropdown.selected = 0
	for possible in possible_actions:
		dropdown.add_item(possible)
	
	if !preset_godot_event:
		return
	
	if preset_godot_event.godot_input_event_name != FEAGI_EmuInput_GodotInputEvent.NO_ACTION:
		var action_index: int = possible_actions.find(preset_godot_event.godot_input_event_name)
		if action_index != -1:
			dropdown.selected = 1 + action_index
		else:
			push_error("FEAGI Configurator: Unable to find preset input event %s in this project's input event settings!" % preset_godot_event.godot_input_event_name)
	$VBoxContainer/InputEventConfig/HBoxContainer2/enablethresholding.button_pressed = preset_godot_event.use_bang_bang_instead_of_actual_value
	$VBoxContainer/InputEventConfig/HBoxContainer3/SpinBox.value = preset_godot_event.bang_bang_threshold
	

func _step_3_configure_keyboard(preset_keyboard_event: FEAGI_EmuInput_KeyboardPress = null) -> void:
	_1button.visible = false
	_2scroll.visible = false
	_3godotInputEvent.visible = false
	_3keyboard.visible = true
	_reset.visible = true
	
	var dropdown: OptionButton = $VBoxContainer/Keyboard/HBoxContainer/OptionButton
	dropdown.clear()
	# We have a none key already with an int value of 0 (both for possible keys and Key)
	for possible in FEAGI_EmuInput_KeyboardPress.SUPPORTED_KEY.keys():
		dropdown.add_item(possible, int(FEAGI_EmuInput_KeyboardPress.SUPPORTED_KEY[possible])) # the dropdown key value will be the key int index
	dropdown.selected = 0 # the None key
	
	if !preset_keyboard_event:
		return
	
	if  preset_keyboard_event.key_to_press in FEAGI_EmuInput_KeyboardPress.SUPPORTED_KEY.values():
		var index_to_select: int = dropdown.get_item_index(preset_keyboard_event.key_to_press)
		dropdown.select(index_to_select)
	else:
		push_error("FEAGI Configurator: Unsupported key defined for keyboard input! Defaulting to None!")
	$VBoxContainer/Keyboard/HBoxContainer3/SpinBox.value = preset_keyboard_event.bang_bang_threshold
