@tool
extends VBoxContainer
class_name Editor_FEAGI_UI_Panel_Device_ParameterManager

# remove "list" support since it is redudant in all our current uses. use vector3 instead
const SUPPORTED_TYPES: Array[StringName] = ["string", "boolean", "integer", "float", "percentage", "object", "vector2", "vector3"] ## The current compenent types we support
const LABEL_NAMES_OF_COMPONENTS_TO_SKIP: Array[StringName] = ["custom_name", "disabled", "feagi_index", "camera_resolution"] ## If a component has this label name property in the template, it will be skipped!


const BOOL_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterBool.tscn"
const FLOAT_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterFloat.tscn"
const INT_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterInt.tscn"
const LIST_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterList.tscn"
const OBJECT_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterObject.tscn"
const PERCENTAGE_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterPercentage.tscn"
const STRING_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterString.tscn"
const VECTOR2_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterVector2.tscn"
const VECTOR3_PREFAB_PATH: StringName = "res://addons/FeagiIntegration/Editor/Panel/Components/Devices/ConfiguratorTemplateGenerator/Parameters/Editor_FEAGI_UI_Panel_Device_ParameterVector3.tscn"

var _parameter_objects: Array[Editor_FEAGI_UI_Panel_Device_ParameterBase] = []

## Creates all FEAGI Configurator enteries (minus the ones to skip as declared above) and adds them to the UI
func setup(device_parameters: Array[Dictionary], existing_values: Dictionary = {}) -> void:
	_parameter_objects = _generate_parameter_controls(device_parameters, existing_values)
	for object in _parameter_objects:
		add_child(object)

## Exports the dict of thje actual values of a specific device instance.
## IE -> {"capabilities" : {"input / output" : {"device_type_name": {"int device index as a str": THIS DICTIONARY}}}}
func export_as_dict() -> Dictionary:
	# WARNING: Some values may be missing, check "LABEL_NAMES_OF_COMPONENTS_TO_SKIP" to see what needs to be merged with this dictionary
	var output: Dictionary = {}
	for object in _parameter_objects:
		if !object.visible:
			continue # dont add invisible parameters
		output.merge(object.get_value_as_dict())
	return output
	



## Responsible for building the array of all parameters that will be added as per the template, as well as prepoulating any defaults
func _generate_parameter_controls(object_parameters: Array[Dictionary], existing_values_for_device: Dictionary = {}) -> Array[Editor_FEAGI_UI_Panel_Device_ParameterBase]:
	var building_list: Array[Editor_FEAGI_UI_Panel_Device_ParameterBase] = []
	# TODO logic for default values? Right now example output shows them as dict, discuss this
	for parameter: Dictionary in object_parameters:
		var object: Editor_FEAGI_UI_Panel_Device_ParameterBase = _spawn_parameter(parameter, existing_values_for_device)
		if object != null:
			_attempt_connect_visibity_toggle(object, building_list)
			building_list.append(object) 
	return building_list

## Responsible for spawning a single parameter gven the properties of the template json (and any predefined values). Skips the disabled and custom_name parameters!
func _spawn_parameter(parameter_template: Dictionary, paremeter_given_values: Dictionary = {}) -> Editor_FEAGI_UI_Panel_Device_ParameterBase:
	# Validation
	if "type" not in parameter_template:
		push_error("No parameter type given!")
		return null
	if parameter_template["type"] not in SUPPORTED_TYPES:
		push_error("Unknown type %s!" % parameter_template["type"])
		return null
	if "label" not in parameter_template:
		push_error("No label given for %s parameter!" % parameter_template["type"])
		return null
	if "description" not in parameter_template:
		push_error("No description given for %s parameter!" % parameter_template["type"])
		return null
	
	## Get some vars
	var label: StringName = parameter_template["label"]
	var description: StringName = parameter_template["description"]
	var appending: Editor_FEAGI_UI_Panel_Device_ParameterBase = null
	
	#NOTE This part is unique to this project over the generic configurator!
	# Since we handle certain flags seperately, those parameters must be removed / skipped!
	if label in LABEL_NAMES_OF_COMPONENTS_TO_SKIP:
		return null
	
	
	# Grab default value
	var default_value: Variant = null
	if label in paremeter_given_values:
		default_value = paremeter_given_values[label]
	elif default_value == null and "default" in parameter_template:
		default_value = parameter_template["default"]
	
	# Logic if parameter depends on another bool parameter
	var toggle_parameter_name: StringName = ""
	var toggle_invert: bool = false
	if "depends_on" in parameter_template:
		if str(parameter_template["depends_on"]).begins_with("!"):
			toggle_parameter_name = str(parameter_template["depends_on"]).lstrip("!")
			toggle_invert = true
		else:
			toggle_parameter_name = str(parameter_template["depends_on"])
	
	# Spawning
	match(parameter_template["type"]):
		"string":
			appending = load(STRING_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterString).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterString).set_value(default_value)
		"boolean":
			appending = load(BOOL_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterBool).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterBool).set_value(default_value)
		"integer":
			appending = load(INT_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterInt).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterInt).set_value(default_value)
			if "min" in parameter_template:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterInt).set_min(parameter_template["min"])
			if "max" in parameter_template:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterInt).set_max(parameter_template["max"])
		"float":
			appending = load(FLOAT_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterFloat).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterFloat).set_value(default_value)
			if "min" in parameter_template:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterFloat).set_min(parameter_template["min"])
			if "max" in parameter_template:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterFloat).set_max(parameter_template["max"])
		"percentage":
			appending = load(PERCENTAGE_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterPercentage).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterPercentage).set_value(default_value)
			if "min" in parameter_template:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterPercentage).set_min(parameter_template["min"])
			if "max" in parameter_template:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterPercentage).set_max(parameter_template["max"])
		"object":
			if "parameters" not in parameter_template:
				push_error("No parameter defined for object type parameter!")
				return null
			appending = load(OBJECT_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterObject).setup(label, description)
			var subparameters_array: Array[Dictionary]
			subparameters_array.assign(parameter_template["parameters"])
			if paremeter_given_values.has(label):
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterObject).setup_internals(_generate_parameter_controls(subparameters_array, paremeter_given_values[label]))
			else:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterObject).setup_internals(_generate_parameter_controls(subparameters_array))
		"vector2":
			appending = load(VECTOR2_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterVector2).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterVector2).set_value(default_value)
		"vector3":
			appending = load(VECTOR3_PREFAB_PATH).instantiate()
			(appending as Editor_FEAGI_UI_Panel_Device_ParameterVector3).setup(label, description)
			if default_value:
				(appending as Editor_FEAGI_UI_Panel_Device_ParameterVector3).set_value(default_value)
	
	if toggle_invert:
		appending.flag_for_inverse_toggle_by_parameter_of_name = toggle_parameter_name
	else:
		appending.flag_for_toggle_by_parameter_of_name = toggle_parameter_name
	return appending

func _attempt_connect_visibity_toggle(toggling_object: Editor_FEAGI_UI_Panel_Device_ParameterBase, existing_objects: Array[Editor_FEAGI_UI_Panel_Device_ParameterBase]) -> void:
	if !toggling_object.flag_for_toggle_by_parameter_of_name.is_empty():
		for object in existing_objects:
			if object.name != toggling_object.flag_for_toggle_by_parameter_of_name:
				continue
			if object is Editor_FEAGI_UI_Panel_Device_ParameterBool:
				(object as Editor_FEAGI_UI_Panel_Device_ParameterBool).bool_changed.connect(toggling_object.set_visible)
				toggling_object.visible = (object as Editor_FEAGI_UI_Panel_Device_ParameterBool).get_value()
				return
			push_error("Attempt to make visibility of %s depend on %s, but %s is not a boolean parameter!" % [toggling_object.name, object.name, object.name])
			return
		push_error("Attempt to make visibility of %s depend on unknown object %s! was it initialized prior?" % [toggling_object.name, toggling_object.flag_for_toggle_by_parameter_of_name])
		return
	if !toggling_object.flag_for_inverse_toggle_by_parameter_of_name.is_empty():
		for object in existing_objects:
			if object.name != toggling_object.flag_for_inverse_toggle_by_parameter_of_name:
				continue
			if object is Editor_FEAGI_UI_Panel_Device_ParameterBool:
				(object as Editor_FEAGI_UI_Panel_Device_ParameterBool).bool_changed_inversed.connect(toggling_object.set_visible)
				toggling_object.visible = !(object as Editor_FEAGI_UI_Panel_Device_ParameterBool).get_value()
				return
			push_error("Attempt to make visibility of %s inversely depend on %s, but %s is not a boolean parameter!" % [toggling_object.name, object.name, object.name])
			return
		push_error("Attempt to make visibility of %s inversely depend on unknown object %s! was it initialized prior?" % [toggling_object.name, toggling_object.flag_for_toggle_by_parameter_of_name])
		return
	return
