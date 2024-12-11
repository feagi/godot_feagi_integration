@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_SpecificDeviceUI_Base
## Some devices have specific settings in their UIs, this script acts as the base class for the non-specific cases, and is the parent class for any customizations to this behavior

const EMUINPUT_HOLDER_UI_PREFAB: PackedScene = preload("res://addons/FeagiIntegration/Editor/Panel/Components/Devices/Device_Specific_UIs/EmuInputConfigurations/Editor_FEAGI_UI_Panel_EmuInputConfigurations.tscn")

var _emuInput_holder: Editor_FEAGI_UI_Panel_EmuInputConfigurations = null # only exists if EmuInput was set during setup

## This function is called by the parent [FEAGI_UI_Panel_Device] node first
func setup(device_config: FEAGI_IOConnector_Base, generate_motor_emuInput_UI: bool) -> Error:
	if generate_motor_emuInput_UI:
		var motor_config: FEAGI_IOConnector_Motor_Base = device_config as FEAGI_IOConnector_Motor_Base
		if motor_config:
			_emuInput_holder = EMUINPUT_HOLDER_UI_PREFAB.instantiate()
			add_child(_emuInput_holder)
			var error: Error = _emuInput_holder.setup_for_motor(motor_config)
			if error:
				return error
		else:
			push_warning("FEAGI Configurator: Unable to generate emuInput for non-motor IOConnector!")
	return Error.OK


## Called by the parent [FEAGI_UI_Panel_Device] node to get any additional data keys that need to be merged in to the configurator JSON. Most cases empty but some classes may override this
func export_additional_JSON_configurator_data() -> Dictionary:
	return {}
	
	
## Add any additional information to the IOHandlers here. This method may be overridden!
func export_additional_IOHandler_data(device: FEAGI_IOConnector_Base) -> FEAGI_IOConnector_Base:
	if _emuInput_holder:
		(device as FEAGI_IOConnector_Motor_Base).InputEmulators = _emuInput_holder.export_emuinputs_for_motor()
	return device

## Some specific devices may have additional UI needed to configure per device. Those devices can have logic for such behavior here in child classes
func _setup_additional_configuration(device_config: FEAGI_IOConnector_Base) -> void:
	pass
