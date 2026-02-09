# skills/platform-web/scripts/web_bridge_sync.gd
extends Node

## Web Bridge Sync Expert Pattern
## JavaScriptBridge helpers for browser API integration (fullscreen, persistence, analytics).

class_name WebBridgeSync

# Persistence
static func save_to_local_storage(key: String, data: Dictionary) -> void:
	if not OS.has_feature("web"):
		return
	
	var json_str = JSON.stringify(data)
	# Encode to base64 to avoid character issues in JS string
	var b64_str = Marshalls.utf8_to_base64(json_str)
	
	var js_code = "localStorage.setItem('%s', '%s');" % [key, b64_str]
	JavaScriptBridge.eval(js_code)

static func load_from_local_storage(key: String) -> Dictionary:
	if not OS.has_feature("web"):
		return {}
	
	# JavaScriptBridge.eval returns the value directly
	var b64_str = JavaScriptBridge.eval("localStorage.getItem('%s');" % key)
	
	if b64_str and b64_str is String:
		var json_str = Marshalls.base64_to_utf8(b64_str)
		var result = JSON.parse_string(json_str)
		if result:
			return result
	
	return {}

# Browser Interaction
static func set_tab_title(title: String) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("document.title = '%s';" % title)

# Analytics Hook (e.g. Google Analytics)
static func send_analytics_event(event_name: String, params: Dictionary = {}) -> void:
	if OS.has_feature("web"):
		# Ensure gtag is defined in index.html, safeguard against missing window.gtag
		# We construct a JS function call dynamically
		var json_params = JSON.stringify(params)
		var js = "if(typeof gtag !== 'undefined') { gtag('event', '%s', %s); }" % [event_name, json_params]
		JavaScriptBridge.eval(js)

## EXPERT USAGE:
## if OS.has_feature("web"): WebBridgeSync.save_to_local_storage("save1", data)
