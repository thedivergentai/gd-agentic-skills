# skills/particles/scripts/particle_burst_emitter.gd
extends GPUParticles3D

## Particle Burst Emitter Expert Pattern
## One-shot particle bursts with automatic cleanup.

class_name ParticleBurstEmitter

signal burst_completed

@export var auto_cleanup := true

func emit_burst(count: int, at_position: Vector3 = Vector3.ZERO) -> void:
	global_position = at_position
	amount = count
	one_shot = true
	emitting = true
	
	if auto_cleanup:
		await get_tree().create_timer(lifetime).timeout
		burst_completed.emit()
		queue_free()

func emit_burst_with_velocity(count: int, at_position: Vector3, direction: Vector3, speed_range: Vector2) -> void:
	var process_mat := process_material as ParticleProcessMaterial
	if not process_mat:
		push_error("ParticleProcessMaterial required")
		return
	
	# Configure velocity
	process_mat.direction = direction
	process_mat.initial_velocity_min = speed_range.x
	process_mat.initial_velocity_max = speed_range.y
	
	emit_burst(count, at_position)

static func create_burst(
	particle_scene: PackedScene,
	count: int,
	at_position: Vector3,
	parent: Node
) -> ParticleBurstEmitter:
	var instance := particle_scene.instantiate() as ParticleBurstEmitter
	if not instance:
		push_error("Scene must be ParticleBurstEmitter")
		return null
	
	parent.add_child(instance)
	instance.emit_burst(count, at_position)
	return instance

## EXPERT USAGE:
## # Method 1: Extend this script on GPUParticles3D
## extends ParticleBurstEmitter
## 
## func _ready():
##     emit_burst(50, Vector3.UP * 2)
## 
## # Method 2: Static creation
## ParticleBurstEmitter.create_burst(
##     load("res://fx/explosion.tscn"),
##     100,
##     hit_position,
##     get_tree().current_scene
## )
