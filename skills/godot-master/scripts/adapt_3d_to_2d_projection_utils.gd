# skills/adapt-3d-to-2d/scripts/projection_utils.gd
class_name ProjectionUtils

## Projection Utils Expert Pattern
## Helpers for projecting 3D positions to 2D screen space (UI, Indicators).

# Check if a 3D point is visible on screen and in front of camera
static func is_on_screen(camera: Camera3D, global_pos: Vector3, margin: float = 0.0) -> bool:
    if not camera: return false
    
    # Check if behind camera
    if camera.is_position_behind(global_pos):
        return false
        
    var screen_pos = camera.unproject_position(global_pos)
    var viewport_rect = camera.get_viewport().get_visible_rect()
    
    # Apply margin
    viewport_rect = viewport_rect.grow(margin)
    
    return viewport_rect.has_point(screen_pos)

# Get screen position, clamping to edges if off-screen (for indicators)
static func get_clamped_screen_pos(camera: Camera3D, global_pos: Vector3, edge_margin: float = 20.0) -> Vector2:
    var screen_pos = camera.unproject_position(global_pos)
    var viewport_rect = camera.get_viewport().get_visible_rect()
    var center = viewport_rect.get_center()
    
    # If behind camera, mirror logic to show indicator at bottom/top correctly
    if camera.is_position_behind(global_pos):
        screen_pos = center + (center - screen_pos)
        
    # Clamp to screen rect
    var min_pos = Vector2(edge_margin, edge_margin)
    var max_pos = viewport_rect.size - Vector2(edge_margin, edge_margin)
    
    return screen_pos.clamp(min_pos, max_pos)

# Calculate scale factor based on distance (simulate perspective for 2D UI)
static func get_perspective_scale(camera: Camera3D, global_pos: Vector3, reference_dist: float = 10.0) -> float:
    var dist = camera.global_position.distance_to(global_pos)
    if dist == 0: return 1.0
    return reference_dist / dist

## EXPERT USAGE:
## target_indicator.position = ProjectionUtils.get_clamped_screen_pos(cam, enemy.position)
