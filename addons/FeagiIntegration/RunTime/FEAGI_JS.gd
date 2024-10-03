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
	
	
	
