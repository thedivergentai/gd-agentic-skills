# godot-master/scripts/action_rpg_telegraphed_enemy.gd
extends CharacterBody2D

## Telegraphed Enemy Expert Pattern
## Manages attack states with clear visual telegraphs (wind-up) before striking.

class_name TelegraphedEnemy

enum State { IDLE, CHASE, CHARGE, ATTACK, RECOVERY }

@export var attack_range: float = 60.0
@export var windup_time: float = 0.5
@export var recovery_time: float = 1.0
@export var damage: int = 20

@onready var telegraph_visual: Node2D = $TelegraphVisual # Area indicator
@onready var hitbox: Area2D = $Hitbox

var _state: State = State.IDLE
var _timer: float = 0.0
var target: Node2D

func _physics_process(delta: float) -> void:
    match _state:
        State.IDLE:
             _find_target()
        State.CHASE:
             _chase_target(delta)
        State.CHARGE:
             _process_charge(delta)
        State.ATTACK:
             _execute_attack()
        State.RECOVERY:
             _process_recovery(delta)

func _find_target() -> void:
    # Simple logic: assume player is in group "player"
    var tree = get_tree()
    if tree.has_group("player"):
        target = tree.get_nodes_in_group("player")[0]
        _state = State.CHASE

func _chase_target(delta: float) -> void:
    if not target: 
        _state = State.IDLE
        return
        
    var dist = global_position.distance_to(target.global_position)
    if dist <= attack_range:
        _start_attack()
    else:
        velocity = global_position.direction_to(target.global_position) * 100.0
        move_and_slide()

func _start_attack() -> void:
    _state = State.CHARGE
    _timer = windup_time
    velocity = Vector2.ZERO
    
    # Show telegraph
    if telegraph_visual:
        telegraph_visual.visible = true
        telegraph_visual.modulate.a = 0.5
        # Tween transparency to imply buildup
        var tween = create_tween()
        tween.tween_property(telegraph_visual, "modulate:a", 1.0, windup_time)

func _process_charge(delta: float) -> void:
    _timer -= delta
    if _timer <= 0:
        _state = State.ATTACK

func _execute_attack() -> void:
    # Activate hitbox
    if hitbox:
        hitbox.monitoring = true
        # Check overlapping bodies immediately or wait for next physics frame
        # For simplicity, we assume Area2D monitors
        
    if telegraph_visual:
        telegraph_visual.visible = false
        
    _state = State.RECOVERY
    _timer = recovery_time
    
    # Deactivate hitbox after 0.1s
    await get_tree().create_timer(0.1).timeout
    if hitbox: hitbox.monitoring = false

func _process_recovery(delta: float) -> void:
    _timer -= delta
    if _timer <= 0:
        _state = State.CHASE

## EXPERT USAGE:
## Assign a Sprite or Polygon2D as 'TelegraphVisual'.
## Enemy freezes during Charge, giving player time to dodge.
