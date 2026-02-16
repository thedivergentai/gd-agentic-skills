# godot-master/scripts/tower_defense_tower.gd
extends Node2D

## Tower Logic (Expert Pattern)
## Autonomous turret with targeting priority and projectile prediction.
## Separates visual rotation from firing logic.

class_name Tower

enum TargetPriority { FIRST, LAST, CLOSEST, STRONGEST }

@export var range_radius: float = 200.0
@export var fire_rate: float = 1.0 # Shots per second
@export var projectile_scene: PackedScene
@export var turret_visual: Node2D
@export var priority: TargetPriority = TargetPriority.FIRST

var targets_in_range: Array[Node2D] = []
var current_target: Node2D
var _cooldown: float = 0.0

func _ready() -> void:
    # Setup Area2D for range
    var area = Area2D.new()
    var shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = range_radius
    shape.shape = circle
    area.add_child(shape)
    add_child(area)
    
    area.body_entered.connect(_on_body_entered)
    area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
    _cooldown -= delta
    
    if not is_instance_valid(current_target):
        _acquire_target()
        
    if current_target:
        _rotate_toward(current_target.global_position)
        if _cooldown <= 0:
            _fire()

func _acquire_target() -> void:
    if targets_in_range.is_empty():
        current_target = null
        return
        
    # Sort or pick based on priority
    # Simplified: just pick first valid
    current_target = targets_in_range[0]

func _fire() -> void:
    _cooldown = 1.0 / fire_rate
    
    if projectile_scene:
        var proj = projectile_scene.instantiate()
        get_tree().root.add_child(proj)
        proj.global_position = global_position
        # Assume projectile has setup method
        if proj.has_method("setup") and current_target:
            var dir = global_position.direction_to(current_target.global_position)
            proj.setup(dir, global_position)

func _rotate_toward(pos: Vector2) -> void:
    if turret_visual:
        turret_visual.look_at(pos)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemy"):
        targets_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
    targets_in_range.erase(body)
    if body == current_target:
        current_target = null

## EXPERT USAGE:
## Assign projectile_scene. Ensure enemies are in "enemy" group.
## Adjust Range Radius in inspector.
