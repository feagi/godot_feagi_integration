@tool
extends MarginContainer
class_name Editor_FEAGI_UI_Panel_EmuInputConfiguration

var _data_type: FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE

var _1button: Button
var _2scroll: ScrollContainer
var _2scroll_godotInputEvent: Button
var _2scroll_keyboard: Button
var _2scroll_mouseClick: Button
var _2scroll_mouseMovement: Button
var _3godotInputEvent: BoxContainer
var _3keyboard: BoxContainer
var _3mouseClick: BoxContainer
var _3mouseMovement: BoxContainer
var _reset: Button

var _all_controls: Array[Control]

func setup(motor_output_name: StringName, motor_output_datatype: FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE, preinit_emuInput: FEAGI_EmuInput_Abstract = null) -> void:
	$PanelContainer/HBoxContainer/GodotInputName.text = "[center][b][u]%s[/u][/b][/center]" % motor_output_name
	_data_type = motor_output_datatype
	match(motor_output_datatype):
		FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1:
			$PanelContainer/HBoxContainer/GodotInputType.text = "0 to 1"
		FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_M1_TO_1:
			$PanelContainer/HBoxContainer/GodotInputType.text = "-1 to 1"
		FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.VEC2:
			$PanelContainer/HBoxContainer/GodotInputType.text = "<-1, -1> to <1, 1>"
	_1button = $PanelContainer/HBoxContainer/VBoxContainer/start
	_2scroll = $PanelContainer/HBoxContainer/VBoxContainer/emuselect
	_2scroll_godotInputEvent = $PanelContainer/HBoxContainer/VBoxContainer/emuselect/VBoxContainer/GodotInputEvent
	_2scroll_keyboard = $PanelContainer/HBoxContainer/VBoxContainer/emuselect/VBoxContainer/Keyboard
	_2scroll_mouseClick = $PanelContainer/HBoxContainer/VBoxContainer/emuselect/VBoxContainer/MouseClick
	_2scroll_mouseMovement = $PanelContainer/HBoxContainer/VBoxContainer/emuselect/VBoxContainer/MouseMovement
	_3godotInputEvent = $PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig
	_3keyboard = $PanelContainer/HBoxContainer/VBoxContainer/Keyboard
	_3mouseClick = $PanelContainer/HBoxContainer/VBoxContainer/MouseClick
	_3mouseMovement = $PanelContainer/HBoxContainer/VBoxContainer/MouseMovement
	_reset = $PanelContainer/HBoxContainer/VBoxContainer/Reset
	
	var all_properties: Array[Dictionary] = get_property_list()
	for property in all_properties:
		if get(property["name"]) is Control:
			_all_controls.append(get(property["name"]))
	
	if !preinit_emuInput:
		_step_1_set_to_unconfigured()
		return
	if preinit_emuInput is FEAGI_EmuInput_GodotInputEvent:
		_step_3_configure_godotInputEvent(preinit_emuInput)
	if preinit_emuInput is FEAGI_EmuInput_KeyboardPress:
		_step_3_configure_keyboard(preinit_emuInput)
	if preinit_emuInput is FEAGI_EmuInput_MouseClick:
		_step_3_configure_mouseClick(preinit_emuInput)
	if preinit_emuInput is FEAGI_EmuInput_MouseMotion:
		_step_3_configure_mouseMotion(preinit_emuInput)

## Exports an emu input object. Will either export a specific child of [FEAGI_EmuInput_Abstract] or null if none is selected (or if something is wrong)
func export_emu_input() -> FEAGI_EmuInput_Abstract:
	if _3godotInputEvent.visible:
		var output: FEAGI_EmuInput_GodotInputEvent = FEAGI_EmuInput_GodotInputEvent.new()
		var dropdown: OptionButton = $PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer/OptionButton
		output.godot_input_event_name = dropdown.get_item_text(dropdown.selected)
		output.use_bang_bang_instead_of_actual_value = $PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer2/enablethresholding.button_pressed
		output.bang_bang_threshold = $PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer3/SpinBox.value
		return output
	
	if _3keyboard.visible:
		var output: FEAGI_EmuInput_KeyboardPress = FEAGI_EmuInput_KeyboardPress.new()
		var dropdown: OptionButton = $PanelContainer/HBoxContainer/VBoxContainer/Keyboard/HBoxContainer/OptionButton
		output.key_to_press = dropdown.get_item_id(dropdown.selected)
		output.bang_bang_threshold = $PanelContainer/HBoxContainer/VBoxContainer/Keyboard/HBoxContainer3/SpinBox.value
		return output
	
	if _3mouseClick.visible:
		var output: FEAGI_EmuInput_MouseClick = FEAGI_EmuInput_MouseClick.new()
		var dropdown: OptionButton = $PanelContainer/HBoxContainer/VBoxContainer/MouseClick/HBoxContainer/OptionButton
		output.mouse_button_to_click = dropdown.get_item_id(dropdown.selected)
		output.bang_bang_threshold = $PanelContainer/HBoxContainer/VBoxContainer/MouseClick/HBoxContainer3/SpinBox.value
		output.is_double_click = $PanelContainer/HBoxContainer/VBoxContainer/MouseClick/HBoxContainer2/CheckButton.button_pressed
		return output
	
	if _3mouseMovement.visible:
		var output: FEAGI_EmuInput_MouseMotion = FEAGI_EmuInput_MouseMotion.new()
		output.movement_scaling = $PanelContainer/HBoxContainer/VBoxContainer/MouseMovement/HBoxContainer3/SpinBox.value
		output.mirror_y_axis = $PanelContainer/HBoxContainer/VBoxContainer/MouseMovement/HBoxContainer2/CheckButton.button_pressed
		return output
		
	return null

## Used in the case of sequences, when we dont care to set FEAGI thresholding since we ourselves are supplying the information, so no need to show those options
func hide_feagi_threshold_UI() -> void:
	$PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer2.visible = false
	$PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer3.visible = false
	$PanelContainer/HBoxContainer/VBoxContainer/Keyboard/HBoxContainer3.visible = false

func _step_1_set_to_unconfigured() -> void:
	_hide_controls_except([_1button])


func _step_2_ask_emuInput_type() -> void:
	_hide_controls_except([_2scroll])
	
	# enable input as per data type
	# TODO UI options for FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_M1_TO_1
	_2scroll_godotInputEvent.visible = _data_type == FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1
	_2scroll_keyboard.visible = _data_type == FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1
	_2scroll_mouseClick.visible = _data_type == FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.FLOAT_0_TO_1
	_2scroll_mouseMovement.visible = _data_type ==  FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE.VEC2


## Jumps to the Godot Input Event Configuration, including prefilling from given values
func _step_3_configure_godotInputEvent(preset_godot_event: FEAGI_EmuInput_GodotInputEvent = null) -> void:
	_hide_controls_except([_3godotInputEvent, _reset])

	var dropdown: OptionButton = $PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer/OptionButton
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
	$PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer2/enablethresholding.button_pressed = preset_godot_event.use_bang_bang_instead_of_actual_value
	$PanelContainer/HBoxContainer/VBoxContainer/InputEventConfig/HBoxContainer3/SpinBox.value = preset_godot_event.bang_bang_threshold
	

func _step_3_configure_keyboard(preset_keyboard_event: FEAGI_EmuInput_KeyboardPress = null) -> void:
	_hide_controls_except([_3keyboard, _reset])
	
	var dropdown: OptionButton = $PanelContainer/HBoxContainer/VBoxContainer/Keyboard/HBoxContainer/OptionButton
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
	$PanelContainer/HBoxContainer/VBoxContainer/Keyboard/HBoxContainer3/SpinBox.value = preset_keyboard_event.bang_bang_threshold

func _step_3_configure_mouseClick(preset_mouseClick_event: FEAGI_EmuInput_MouseClick = null) -> void:
	_hide_controls_except([_3mouseClick, _reset])
	
	var dropdown: OptionButton = $PanelContainer/HBoxContainer/VBoxContainer/MouseClick/HBoxContainer/OptionButton
	dropdown.clear()
	
	for possible in FEAGI_EmuInput_MouseClick.SUPPORTED_KEY.keys():
		dropdown.add_item(possible, int(FEAGI_EmuInput_MouseClick.SUPPORTED_KEY[possible])) # the dropdown click value will be the key int index
	dropdown.selected = 0 # the None mouse button
	
	if !preset_mouseClick_event:
		return
	
	if  preset_mouseClick_event.mouse_button_to_click in FEAGI_EmuInput_MouseClick.SUPPORTED_KEY.values():
		var index_to_select: int = dropdown.get_item_index(preset_mouseClick_event.mouse_button_to_click)
		dropdown.select(index_to_select)
	else:
		push_error("FEAGI Configurator: Unsupported mouse button defined for mouse button input! Defaulting to None!")
	$PanelContainer/HBoxContainer/VBoxContainer/MouseClick/HBoxContainer3/SpinBox.value = preset_mouseClick_event.bang_bang_threshold
	$PanelContainer/HBoxContainer/VBoxContainer/MouseClick/HBoxContainer2/CheckButton.set_pressed_no_signal(preset_mouseClick_event.is_double_click)

func _step_3_configure_mouseMotion(preset_mouseMotion_event: FEAGI_EmuInput_MouseMotion = null) -> void:
	_hide_controls_except([_3mouseMovement, _reset])
	
	if !preset_mouseMotion_event:
		return
	
	$PanelContainer/HBoxContainer/VBoxContainer/MouseMovement/HBoxContainer3/SpinBox.value = preset_mouseMotion_event.movement_scaling
	$PanelContainer/HBoxContainer/VBoxContainer/MouseMovement/HBoxContainer2/CheckButton.set_pressed_no_signal(preset_mouseMotion_event.mirror_y_axis)

func _hide_controls_except(controls_to_show: Array[Control]) -> void:
	for control in _all_controls:
		control.visible = control in controls_to_show
