class_name WebVisibilityAutoPause
extends Node

## Expert tab visibility manager for Web exports.
## Automatically pauses the engine and audio when the tab is hidden.

func _ready() -> void:
	if not OS.has_feature("web"): return
	
	var js_callback := JavaScriptBridge.create_callback(_on_visibility_changed)
	JavaScriptBridge.eval("""
		document.addEventListener('visibilitychange', function() {
			window.onVisibilityChange(document.hidden);
		});
	""")
	var window := JavaScriptBridge.get_interface("window")
	window.onVisibilityChange = js_callback

func _on_visibility_changed(args: Array) -> void:
	var is_hidden: bool = args[0]
	get_tree().paused = is_hidden
	AudioServer.set_bus_mute(0, is_hidden)

## Rule: Always pause audio on visibility change to respect browser user experience.
