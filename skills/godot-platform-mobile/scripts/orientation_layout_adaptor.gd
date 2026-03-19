class_name OrientationLayoutAdaptor
extends Node

## Expert adaptive orientation handler.
## Swaps UI layouts dynamically when the device is rotated.

@export var landscape_root: Control
@export var portrait_root: Control

func _ready() -> void:
	get_viewport().size_changed.connect(_on_screen_resized)
	_on_screen_resized()

func _on_screen_resized() -> void:
	var size := DisplayServer.screen_get_size()
	var is_portrait := size.y > size.x
	
	if landscape_root: landscape_root.visible = not is_portrait
	if portrait_root: portrait_root.visible = is_portrait

## Tip: Use separate CanvasLayers for Landscape/Portrait roots for easier design.
