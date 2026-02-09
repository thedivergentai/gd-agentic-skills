# skills/adapt-2d-to-3d/scripts/sprite_plane.gd
extends Sprite3D

## Sprite Plane Expert Pattern
## Manages 2D-in-3D projection, billboard behaviors, and screen-space interactions.

class_name SpritePlane

@export var interactable: bool = true
@export_flags("Player", "World", "Enemy") var mouse_filter_layers: int = 1

signal clicked(local_pos: Vector2)
signal hover_started
signal hover_ended

var _is_hovered: bool = false
var _camera: Camera3D

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()
	
	# Expert: Ensure correct flags for mixing 2D/3D
	centered = true
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD # Better depth sorting
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS

func _unhandled_input(event: InputEvent) -> void:
	if not interactable or not _camera: return
	
	if event is InputEventMouse:
		var mouse_pos = event.position
		var ray_origin = _camera.project_ray_origin(mouse_pos)
		var ray_normal = _camera.project_ray_normal(mouse_pos)
		
		# Raycast against the sprite's plane
		var global_transform = global_transform
		var plane = Plane(global_transform.basis.z, global_transform.origin)
		
		var intersect = plane.intersects_ray(ray_origin, ray_normal)
		
		if intersect:
			# Check if intersection is within sprite bounds
			var local_pos = global_transform.affine_inverse() * intersect
			var rect = get_item_rect()
			
			if rect.has_point(Vector2(local_pos.x, local_pos.y)):
				if not _is_hovered:
					_is_hovered = true
					hover_started.emit()
				
				if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
					clicked.emit(Vector2(local_pos.x, local_pos.y))
				
				return
		
		if _is_hovered:
			_is_hovered = false
			hover_ended.emit()

func world_to_screen_rect() -> Rect2:
	if not _camera: return Rect2()
	
	var aabb = get_aabb()
	var corners = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + aabb.size
	]
	
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for corner in corners:
		var screen_pos = _camera.unproject_position(global_transform * corner)
		min_pos = min_pos.min(screen_pos)
		max_pos = max_pos.max(screen_pos)
		
	return Rect2(min_pos, max_pos - min_pos)

## EXPERT USAGE:
## Attach to Sprite3D. Use 'world_to_screen_rect()' to position 2D UI elements
## exactly over the 3D sprite (e.g. health bars).
