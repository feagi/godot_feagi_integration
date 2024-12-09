@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_EmuInputConfigurations

const EMUINPUT_CONFIGURATOR_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Resources/Prefabs/EmuInputsConfiguration/Editor_FEAGI_UI_Panel_EmuInputConfiguration.tscn")



var _device_UI_holder: VBoxContainer
var _input_node: RichTextLabel
var _collabsible: FEAGI_UI_Prefab_Collapsible


## Creates all EmuInput controls for given motor (including prefilling them if values are given)
func setup_for_motor(motor: FEAGI_IOConnector_Motor_Base) -> Error:
	if motor == null:
		push_error("FEAGI Configurator: Unable to initialize EmuInput configuration panels for a null motor reference!")
		return Error.ERR_INVALID_PARAMETER

	var names: Array[StringName] = motor.get_InputEmulator_names()
	var types:  Array[FEAGI_IOConnector_Motor_Base.INPUT_EMULATOR_DATA_TYPE] = motor.get_InputEmulator_data_types()
	
	if len(names) != len(types):
		push_error("FEAGI Configurator: Unable to initialize EmuInput configuration panels as motor reference has unequal names / types EmuInput parameters!")
		return Error.ERR_INVALID_DATA
	
	if !motor.InputEmulators.is_empty() and len(motor.InputEmulators) != len(names):
		push_error("FEAGI Configurator: Unable to initialize EmuInput configuration panels as motor reference has InputEmulator definitions but the incorrect amount!")
		return Error.ERR_INVALID_DATA
	
	for i in len(names):
		var emuInput_configurator: Editor_FEAGI_UI_Panel_EmuInputConfiguration = EMUINPUT_CONFIGURATOR_PREFAB.instantiate()
		if motor.InputEmulators.is_empty():
			emuInput_configurator.setup(names[i], types[i])
		else:
			emuInput_configurator.setup(names[i], types[i], motor.InputEmulators[i])
		add_child(emuInput_configurator)
	return Error.OK

## Export the correct number of EmuInput objects for the given motor
func export_emuinputs_for_motor() -> Array[FEAGI_EmuInput_Abstract]:
	var output: Array[FEAGI_EmuInput_Abstract] = []
	for child in get_children():
		if child is not Editor_FEAGI_UI_Panel_EmuInputConfiguration:
			#wtf
			push_error("FEAGI Configurator: EmuInputConfiguration failed to init child correctly!")
			output.append(null)
		else:
			output.append((child as Editor_FEAGI_UI_Panel_EmuInputConfiguration).export_emu_input())
	return output
