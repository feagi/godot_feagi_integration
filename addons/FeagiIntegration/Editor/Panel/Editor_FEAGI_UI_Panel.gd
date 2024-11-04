@tool
extends PanelContainer
class_name Editor_FEAGI_UI_Panel

var _section_agent: Editor_FEAGI_UI_Panel_AgentSettings
var _section_sensory: Editor_FEAGI_UI_Panel_Devices
var _section_motor: Editor_FEAGI_UI_Panel_Devices
var _import_button: Button
var _json_base_template: Dictionary

func setup() -> void:
	_section_agent = $ScrollContainer/Options/TabContainer/FEAGI/PanelContainer/FEAGIPanelFEAGIAgentSettings
	_section_sensory = $ScrollContainer/Options/TabContainer/Sensory/PanelContainer/FeagiUiPanelDevices
	_section_motor = $ScrollContainer/Options/TabContainer/Motor/PanelContainer/FeagiUiPanelDevices
	_import_button = $ScrollContainer/Options/HBoxContainer/import
	
	_section_agent.initialize_references()
	_json_base_template= JSON.parse_string(FileAccess.get_file_as_string(FEAGI_PLUGIN_CONFIG.TEMPLATE_DIR))
	_section_sensory.setup(true, _json_base_template["input"])
	_section_motor.setup(false, _json_base_template["output"])
	
	_import_button.disabled = !(FEAGI_PLUGIN_CONFIG.does_mapping_file_exist() or FEAGI_PLUGIN_CONFIG.does_endpoint_file_exist())
	
	if FEAGI_PLUGIN_CONFIG.does_mapping_file_exist() and FEAGI_PLUGIN_CONFIG.does_endpoint_file_exist():
		print("FEAGI: Found mapping and endpoint files. Importing Automatically!")
		_import_config()
	

func _export_config() -> void:
	var endpoint: FEAGI_Resource_Endpoint = _section_agent.export_endpoint()
	
	var JSON_dict: Dictionary = {"capabilities": {"input": {}, "output": {}}}
	JSON_dict["capabilities"]["input"] =  _section_sensory.export_as_FEAGI_config_JSON_device_objects()
	JSON_dict["capabilities"]["output"] =  _section_motor.export_as_FEAGI_config_JSON_device_objects()
	
	var sensory_devices: Array[FEAGI_IOConnector_Sensor_Base] = []
	sensory_devices.assign(_section_sensory.export_FEAGI_IOHandlers())
	var sensory: Dictionary = {}
	for sensory_device in sensory_devices:
		sensory[sensory_device.get_device_type() + "_" + sensory_device.device_friendly_name] = sensory_device
	
	var motor_devices: Array[FEAGI_IOConnector_Motor_Base] = []
	motor_devices.assign(_section_motor.export_FEAGI_IOHandlers())
	var motor: Dictionary = {}
	for motor_device in motor_devices:
		motor[motor_device.get_device_type() + "_" + motor_device.device_friendly_name] = motor_device
	
	var mapping: FEAGI_Genome_Mapping = FEAGI_Genome_Mapping.new()
	mapping.FEAGI_enabled = _section_agent.FEAGI_enabled
	mapping.debugger_enabled = _section_agent.debug_enabled
	mapping.delay_seconds_between_frames = 1.0 / float(_section_agent.refresh_rate)
	mapping.configuration_JSON = JSON.stringify(JSON_dict)
	mapping.sensors = sensory
	mapping.motors = motor
	
	endpoint.save_config()
	mapping.save_config()
	_import_button.disabled = false

func _import_config() -> void:
	if !(FEAGI_PLUGIN_CONFIG.does_mapping_file_exist() or FEAGI_PLUGIN_CONFIG.does_endpoint_file_exist()):
		push_error("FEAGI: No config of any kind found!")
		_import_button.disabled = true
		return


	if FEAGI_PLUGIN_CONFIG.does_mapping_file_exist():
		var loading_mapping: FEAGI_Genome_Mapping = load(FEAGI_PLUGIN_CONFIG.get_genome_mapping_path())
		if !loading_mapping:
			push_error("FEAGI: Mapping file appears corrupt?")
			_import_button.disabled = true
			return
		
		_section_agent.FEAGI_enabled = loading_mapping.FEAGI_enabled
		# Endpoint details are handled seperately below
		_section_agent.debug_enabled = loading_mapping.debugger_enabled
		_section_agent.refresh_rate = int(1.0 / float(loading_mapping.delay_seconds_between_frames))
		
		_section_sensory.clear()
		_section_motor.clear()
		var json_dict: Dictionary = JSON.parse_string(loading_mapping.configuration_JSON)
		var sensors: Array[FEAGI_IOConnector_Base] = []
		var motors: Array[FEAGI_IOConnector_Base] = []
		sensors.assign(loading_mapping.sensors.values())
		motors.assign(loading_mapping.motors.values())
		_section_sensory.load_sort_and_spawn_devices(sensors, _json_base_template["input"], json_dict["capabilities"]["input"])
		_section_motor.load_sort_and_spawn_devices(motors, _json_base_template["output"], json_dict["capabilities"]["output"])
	else:
		push_warning("FEAGI: No Mapping file found. Not loading those parameters!")
	
	if FEAGI_PLUGIN_CONFIG.does_endpoint_file_exist():
		var loading_endpoint: FEAGI_Resource_Endpoint = load(FEAGI_PLUGIN_CONFIG.get_endpoint_path())
		_section_agent.import_endpoint(loading_endpoint)
		print("FEAGI: Imported saved data!")
	else:
		push_warning("FEAGI: No endpoint file found. Not loading network information!")
	
	
	
