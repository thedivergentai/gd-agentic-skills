# perspective_overlay.gd
extends Node3D
class_name PerspectiveOverlay

# 3D to 2D Perspective Projection
# Projects 3D points onto 2D viewport for UI alignment.

@export var camera: Camera3D
@export var ui_element: Control

func update_ui_position(world_point: Vector3) -> void:
    if not camera or not ui_element: return
    
    # Pattern: Use is_position_behind to hide elements behind the lens.
    if not camera.is_position_behind(world_point):
        var screen_pos := camera.unproject_position(world_point)
        ui_element.position = screen_pos
        ui_element.show()
    else:
        ui_element.hide()
