extends Camera2D
class_name ScrollWheelZoomer

## Expert Mouse Wheel Zoomer
## Mobile uses "Pinch-To-Zoom", but PC relies almost exclusively on the Scroll Wheel.
## This script handles discrete scroll "ticks" and interpolates smoothly to target zoom levels.

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var interpolation_speed: float = 10.0

var target_zoom: float = 1.0

func _ready() -> void:
    target_zoom = zoom.x

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _increment_zoom(zoom_speed)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _increment_zoom(-zoom_speed)

func _increment_zoom(amount: float) -> void:
    # Add to the TARGET zoom, rather than immediately mutating the current zoom
    target_zoom = clampf(target_zoom + amount, min_zoom, max_zoom)

func _process(delta: float) -> void:
    # Smoothlerp the actual camera zoom towards the target scroll wheel tick
    zoom.x = lerpf(zoom.x, target_zoom, delta * interpolation_speed)
    zoom.y = zoom.x
