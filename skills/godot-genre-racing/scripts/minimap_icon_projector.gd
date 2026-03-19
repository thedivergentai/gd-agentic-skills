# minimap_icon_projector.gd
extends Control
class_name MinimapIconProjector

# Minimap Projection (Camera3D Unprojection)
# Maps 3D global positions to a 2D UI minimap rectangle.

@export var map_rect: Rect2
@export var track_bounds: Rect2
@export var target_node: Node3D

func _process(_delta: float) -> void:
    if not target_node: return
    
    var pos_3d = target_node.global_position
    
    # Pattern: Normalize world position within track bounds then scale to UI rect.
    var nx = inv_lerp(track_bounds.position.x, track_bounds.end.x, pos_3d.x)
    var ny = inv_lerp(track_bounds.position.y, track_bounds.end.y, pos_3d.z)
    
    position.x = map_rect.position.x + (nx * map_rect.size.x)
    position.y = map_rect.position.y + (ny * map_rect.size.y)
