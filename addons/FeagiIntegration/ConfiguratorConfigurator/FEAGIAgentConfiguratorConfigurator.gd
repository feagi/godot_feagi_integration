@tool
extends Resource
class_name FEAGIAgentConfiguratorConfigurator
## Configurator for the configurator for different agent types
## This is the best class name

# WARNING: Order here should be synced with all other systems!
enum INPUT_TYPE {
	CAMERA,
	PROXIMITY
}

# WARNING: Order here should be synced with all other systems!
enum OUTPUT_TYPE {
	SERVO,
	MOTOR
}

@export var supported_input_types: Array[INPUT_TYPE] ## What types of inputs does this agent support?
@export var supported_output_types: Array[OUTPUT_TYPE] ## What types of outputs does this agent support?

@export var input_count_limits: Array[int] ## How many of each device are supported? Make sure you match the index with supported input types! -1 implies no limit!
@export var output_count_limits: Array[int] ## How many of each device are supported? Make sure you match the index with supported output types! -1 implies no limit!

static func get_input_friendly_name(input_type: INPUT_TYPE) -> StringName:
	return str(INPUT_TYPE.keys()[input_type]).to_camel_case()

static func get_output_friendly_name(output_type: OUTPUT_TYPE) -> StringName:
	return str(OUTPUT_TYPE.keys()[output_type]).to_camel_case()

func get_supported_inputs_as_friendly_string_array() -> Array[StringName]:
	var output: Array[StringName] = []
	for input_type in supported_input_types:
		output.append(str(INPUT_TYPE.keys()[input_type]).to_camel_case())
	return output

func get_supported_outputs_as_friendly_string_array() -> Array[StringName]:
	var output: Array[StringName] = []
	for output_type in supported_output_types:
		output.append(str(OUTPUT_TYPE.keys()[output_type]).to_camel_case())
	return output
