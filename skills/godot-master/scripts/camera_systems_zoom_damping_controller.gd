# zoom_damping_controller.gd
# Smooth, non-linear zoom control for tactical overview
extends Camera2D

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 10.0

var target_zoom: Vector2 = Vector2.ONE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = (target_zoom - Vector2(0.1, 0.1)).max(Vector2(min_zoom, min_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = (target_zoom + Vector2(0.1, 0.1)).min(Vector2(max_zoom, max_zoom))

func _process(delta: float) -> void:
	# Exponential lerp for zoom feels smoother than linear
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
