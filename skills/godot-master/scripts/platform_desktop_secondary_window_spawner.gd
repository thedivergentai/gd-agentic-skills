class_name SecondaryWindowSpawner
extends Node

## Expert multi-window support for tools or secondary displays.
## Requires 'display/window/subwindows/embed_subwindows' to be set to false.

func spawn_floating_window(scene: PackedScene, title: String = "Tool") -> Window:
	var window := Window.new()
	window.title = title
	window.wrap_controls = true
	window.transient = false # Allow it to be moved to other monitors
	
	var ui := scene.instantiate()
	window.add_child(ui)
	
	add_child(window)
	window.popup_centered(Vector2i(800, 600))
	return window

## Rule: Multi-window is best for desktop productivity or local-multiplayer status screens.
