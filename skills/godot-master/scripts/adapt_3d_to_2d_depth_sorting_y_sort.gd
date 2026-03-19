extends Node2D

## Expert Z-Index management for 2.5D games
## Instead of relying purely on Y-Sort (which groups by Node hierarchy),
## this script dynamically assigns absolute Z-Index values based on the global Y position,
## allowing completely disconnected trees (particles, UI, actors) to sort together.

@export var depth_offset: float = 0.0
@export var is_static: bool = false

func _ready() -> void:
    if is_static:
        _update_sorting()
        set_process(false)

func _process(_delta: float) -> void:
    _update_sorting()

func _update_sorting() -> void:
    # Z-index is clamped in Godot to [-4096, 4096]. 
    # If the world is larger, you must use CanvasLayer or scaled division.
    var calculated_z = int(global_position.y + depth_offset)
    z_index = clampi(calculated_z, RenderingServer.CANVAS_ITEM_Z_MIN, RenderingServer.CANVAS_ITEM_Z_MAX)
