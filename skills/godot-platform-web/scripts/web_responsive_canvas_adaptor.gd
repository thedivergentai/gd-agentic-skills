class_name WebResponsiveCanvasAdaptor
extends Node

## Expert canvas resize management for responsive web games.
## Dynamically updates the HTML canvas size via JavaScriptBridge.

func _ready() -> void:
	get_window().size_changed.connect(_update_canvas_size)

func _update_canvas_size() -> void:
	if not OS.has_feature("web"): return
	
	# Force browser canvas to match window inner dimensions
	JavaScriptBridge.eval("""
		var canvas = document.getElementById('canvas');
		canvas.width = window.innerWidth;
		canvas.height = window.innerHeight;
	""")

## Tip: Set 'Stretch Mode' to 'canvas_items' and 'Aspect' to 'expand' in Project Settings.
