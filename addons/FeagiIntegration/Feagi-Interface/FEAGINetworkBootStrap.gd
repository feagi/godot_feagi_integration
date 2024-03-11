"""
Copyright 2016-2024 The FEAGI Authors. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================
"""
extends Object
class_name FEAGINetworkBootStrap
## Pings the webpage for the FEAGI connection issue, the sotres as public vars the conneciton details

# Static Network Configuration / defaults
const DEF_HEADERSTOUSE: PackedStringArray = ["Content-Type: application/json"]
const DEF_FEAGI_TLD: StringName = "127.0.0.1"
const DEF_FEAGI_SSL: StringName = "http://"
const DEF_SOCKET_SSL: StringName = "ws://"
const DEF_WEB_PORT: int = 8000
const DEF_SOCKET_PORT: int = 9055
const DEF_SOCKET_MAX_QUEUED_PACKETS: int = 10000000
const DEF_SOCKET_INBOUND_BUFFER_SIZE: int = 10000000
const DEF_SOCKET_BUFFER_SIZE: int = 10000000

signal base_network_initialization_completed() ## Bootstrap Complete

var feagi_TLD: StringName
var feagi_SSL: StringName
var feagi_web_port: int
var feagi_socket_port: int
var feagi_root_web_address: StringName
var feagi_socket_SSL: StringName
var feagi_socket_address: StringName
var feagi_outgoing_headers: PackedStringArray

func init_network() -> void:
	var ip_result = JavaScriptBridge.eval(""" 
		function getIPAddress() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("ip_address");
			return ipAddress;
		}
		getIPAddress();
		""")
	var port_disabled = JavaScriptBridge.eval(""" 
		function get_port() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("port_disabled");
			return ipAddress;
		}
		get_port();
		""")
	var websocket_url = JavaScriptBridge.eval(""" 
		function get_port() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("websocket_url");
			return ipAddress;
		}
		get_port();
		""")
	var http_type = JavaScriptBridge.eval(""" 
		function get_port() {
			var url_string = window.location.href;
			var url = new URL(url_string);
			const searchParams = new URLSearchParams(url.search);
			const ipAddress = searchParams.get("http_type");
			return ipAddress;
		}
		get_port();
		""")
	if http_type != null:
		feagi_SSL = http_type
	else:
		feagi_SSL= DEF_FEAGI_SSL
	if ip_result != null:
		feagi_TLD = ip_result
	else:
		feagi_TLD = DEF_FEAGI_TLD
	feagi_web_port = DEF_WEB_PORT
	feagi_socket_port = DEF_SOCKET_PORT
	feagi_socket_SSL = DEF_SOCKET_SSL
	feagi_outgoing_headers = DEF_HEADERSTOUSE


	if port_disabled != null:
		if port_disabled.to_lower() == "true":
			feagi_root_web_address = feagi_SSL + feagi_TLD
		else:
			feagi_root_web_address = feagi_SSL + feagi_TLD + ":" + str(feagi_web_port)
	else:
		feagi_root_web_address = feagi_SSL + feagi_TLD + ":" + str(feagi_web_port)

	if websocket_url != null:
		feagi_socket_address = websocket_url
	else:
		feagi_socket_address = feagi_socket_SSL + feagi_TLD + ":" + str(feagi_socket_port)

	# Network ready,
	base_network_initialization_completed.emit()
