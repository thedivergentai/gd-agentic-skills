class_name WebJavaScriptBridgeCallback
extends Node

## Expert two-way communication between GDScript and JavaScript.
## Demonstrates create_callback for receiving async data from browser APIs.

func _ready() -> void:
	if not OS.has_feature("web"): return
	
	# Create a persistent callback to JS
	var js_callback := JavaScriptBridge.create_callback(_on_js_called)
	
	# Pass the callback to a JS function (e.g., a custom analytic or login hook)
	var window := JavaScriptBridge.get_interface("window")
	if window:
		window.registerGodotCallback(js_callback)

func _on_js_called(args: Array) -> void:
	var message = args[0]
	print("Web: Received message from JavaScript: ", message)

## Rule: Always keep a reference to 'js_callback' to prevent garbage collection.
