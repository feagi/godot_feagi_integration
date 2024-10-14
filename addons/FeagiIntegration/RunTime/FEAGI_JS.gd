extends Object # This is static
class_name FEAGI_JS

## Returns true if this is a web export
static func is_web_build() -> bool:
	return OS.get_name() == "Web" # Not JS but I dont care

## attempts to return the value of a URL parameter as a string. Returns null if the parameter is not found or if we are not running in a webpage at all
static func attempt_get_parameter_from_URL(parameter_name: String) -> Variant:
	var JS_func: String = """ 
		function JS_function() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("%s");
			return ipAddress;
		}
		JS_function();
		""" % parameter_name
	return JavaScriptBridge.eval(JS_func)
	
static func overwrite_config(configuration: Dictionary) -> Dictionary:
	if !FEAGI_JS.is_web_build():
		return configuration
	
	var url_parameter_string: String = "capabilities"
	var feagi_indexes = FEAGI_JS.attempt_get_parameter_from_URL(url_parameter_string)
	
	if feagi_indexes:
		var str_index_replacements: StringName = str(feagi_indexes)
		var str_index_replacement_arr: PackedStringArray = str_index_replacements.split("|")
		for str_index_replacement in str_index_replacement_arr:
			var replacing_device: PackedStringArray = str_index_replacement.split(".")
			var key_and_val_replacing: String = replacing_device[3]
			var key: String = key_and_val_replacing.split("=")[0]
			var val_as_int: int = key_and_val_replacing.split("=")[1].to_int()
			if not configuration["capabilities"].has(replacing_device[0]):
				continue
			if not configuration["capabilities"][replacing_device[0]].has(replacing_device[1]):
				continue
			if not configuration["capabilities"][replacing_device[0]][replacing_device[1]].has(replacing_device[2]):
				continue
			if not configuration["capabilities"][replacing_device[0]][replacing_device[1]][replacing_device[2]].has(key):
				continue
			configuration["capabilities"][replacing_device[0]][replacing_device[1]][replacing_device[2]][key] = val_as_int
	return configuration
	
