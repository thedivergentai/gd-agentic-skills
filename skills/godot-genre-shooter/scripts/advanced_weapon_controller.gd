# skills/genre-shooter/scripts/advanced_weapon_controller.gd
extends Node3D

## Advanced Weapon Controller
## Procedural Recoil, Bloom, and Hybrid Hitscan/Projectile Logic.

class_name AdvancedWeaponController

signal weapon_fired(current_ammo: int)

@export_group("Stats")
@export var fire_rate: float = 0.1
@export var max_ammo: int = 30
@export var damage: float = 25.0
@export var is_hitscan: bool = true
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 50.0

@export_group("Recoil & Spread")
@export var recoil_kick: Vector2 = Vector2(0.5, 2.0) # Horizontal, Vertical (deg)
@export var recoil_recovery: float = 10.0 # deg/sec
@export var max_recoil_x: float = 5.0
@export var max_recoil_y: float = 10.0
@export var spread_per_shot: float = 0.5
@export var max_spread: float = 5.0

# Dependencies
@onready var camera: Camera3D = get_viewport().get_camera_3d()

# State
var current_ammo: int
var _fire_timer: float = 0.0
var _current_recoil: Vector2 = Vector2.ZERO
var _current_spread: float = 0.0
var _trigger_held: bool = false

func _ready() -> void:
	current_ammo = max_ammo

func _process(delta: float) -> void:
	_fire_timer -= delta
	
	# Recoil Recovery
	_current_recoil = _current_recoil.move_toward(Vector2.ZERO, recoil_recovery * delta)
	_current_spread = move_toward(_current_spread, 0.0, recoil_recovery * delta)
	
	# Apply visual rotation to camera (or weapon model)
	if camera:
		# Note: In real FPS, apply this as a separate offset/rotation to avoid drifting the actual view permanently
		# For this snippet, we'll assume a 'recoil_container' or similar approach is best,
		# but here is the logic for the offsets:
		pass

func trigger_down() -> void:
	_trigger_held = true
	if _fire_timer <= 0:
		_fire()

func trigger_up() -> void:
	_trigger_held = false

func _fire() -> void:
	if current_ammo <= 0: return # Play dry fire sound
	
	current_ammo -= 1
	_fire_timer = fire_rate
	
	# calculate spread
	var spread_angle = deg_to_rad(_current_spread)
	var spread_vector = Vector3(randf_range(-spread_angle, spread_angle), randf_range(-spread_angle, spread_angle), 0)
	
	if is_hitscan and camera:
		var forward = -camera.global_transform.basis.z
		# Apply spread rotation
		var aim_dir = forward + camera.global_transform.basis * spread_vector
		aim_dir = aim_dir.normalized()
		
		# Raycast
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position + aim_dir * 1000.0)
		var result = space.intersect_ray(query)
		
		if result:
			if result.collider.has_method("take_damage"):
				result.collider.take_damage(damage)
				
	elif projectile_scene:
		var proj = projectile_scene.instantiate()
		get_tree().root.add_child(proj)
		proj.global_transform = camera.global_transform
		# Apply spread to projectile
		proj.rotation.x += randf_range(-deg_to_rad(_current_spread), deg_to_rad(_current_spread))
		proj.rotation.y += randf_range(-deg_to_rad(_current_spread), deg_to_rad(_current_spread))
		
	# Apply Recoil kick
	_current_recoil.x = clamp(_current_recoil.x + randf_range(-recoil_kick.x, recoil_kick.x), -max_recoil_x, max_recoil_x)
	_current_recoil.y = clamp(_current_recoil.y + recoil_kick.y, 0, max_recoil_y) # Kick up
	_current_spread = clamp(_current_spread + spread_per_shot, 0, max_spread)
	
	weapon_fired.emit(current_ammo)
	
	# Auto-fire logic
	if _trigger_held and fire_rate > 0:
		await get_tree().create_timer(fire_rate).timeout
		if _trigger_held: _fire()

## EXPERT USAGE:
## Call trigger_down()/target_up() from Input. 
## Bind 'current_recoil' to a CameraGL/SpringArm offset script for visual shake.
