@tool
extends PanelContainer
class_name FEAGI_UI_Panel

var _section_agent: FEAGI_UI_Panel_AgentSettings
var _section_sensory: FEAGI_UI_Panel_Devices
var _section_motor: FEAGI_UI_Panel_Devices

func setup() -> void:
	_section_agent = $ScrollContainer/Options/TabContainer/FEAGI/PanelContainer/FEAGIPanelFEAGIAgentSettings
	_section_sensory = $ScrollContainer/Options/TabContainer/Sensory/PanelContainer/FeagiUiPanelDevices
	_section_motor = $ScrollContainer/Options/TabContainer/Motor/PanelContainer/FeagiUiPanelDevices
	
	_section_agent.initialize_references()
	var json: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FEAGI_PLUGIN.TEMPLATE_DIR))
	_section_sensory.setup(true, json["input"])
	_section_motor.setup(false, json["output"])

func _export_config() -> void:
	var endpoint: FEAGI_Resource_Endpoint = _section_agent.export_endpoint()
	# TODO validate endpoint
	
	var JSON_dict: Dictionary = {"capabilities": {"input": {}, "output": {}}}
	JSON_dict["capabilities"]["input"] =  _section_sensory.export_as_FEAGI_config_JSON_device_objects()
	JSON_dict["capabilities"]["output"] =  _section_motor.export_as_FEAGI_config_JSON_device_objects()

	
	var sensory_devices: Array[FEAGI_IOHandler_Sensory_Base] = []
	sensory_devices.assign(_section_sensory.export_FEAGI_IOHandlers())
	var sensory: Dictionary = {}
	for sensory_device in sensory_devices:
		sensory[sensory_device.get_device_type() + "_" + sensory_device.device_name] = sensory_device
	
	var motor_devices: Array[FEAGI_IOHandler_Motor_Base] = []
	motor_devices.assign(_section_motor.export_FEAGI_IOHandlers())
	var motor: Dictionary = {}
	for motor_device in motor_devices:
		motor[motor_device.get_device_type() + "_" + motor_device.device_name] = motor_device
	
	var mapping: FEAGI_Genome_Mapping = FEAGI_Genome_Mapping.new()
	mapping.FEAGI_enabled = _section_agent.FEAGI_enabled
	mapping.debugger_enabled = _section_agent.debug_enabled
	mapping.delay_seconds_between_frames = 1.0 / _section_agent.refresh_rate
	mapping.configuration_JSON = JSON.stringify(JSON_dict)
	mapping.sensors = sensory
	mapping.motors = motor
	
	endpoint.save_config()
	mapping.save_config()
