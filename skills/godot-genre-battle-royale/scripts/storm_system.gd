# skills/genre-battle-royale/code/storm_system.gd
extends Node

## Storm System Expert Pattern
## Features Dynamic Zone Shrinking and Damage Interpolation.

signal zone_shrunk(new_safe_center: Vector2, new_safe_radius: float)

@export var initial_radius: float = 2000.0
@export var damage_per_tick: float = 5.0
@export var tick_rate: float = 1.0

var current_center: Vector2 = Vector2.ZERO
var current_radius: float = initial_radius
var _time_since_last_tick: float = 0.0

func _process(delta: float) -> void:
    _time_since_last_tick += delta
    if _time_since_last_tick >= tick_rate:
        _time_since_last_tick = 0
        _check_players_in_storm()

func shrink_zone(new_center: Vector2, new_radius: float, duration: float) -> void:
    # 1. Smooth Interpolation
    # Uses a Tween to shrink the visual and logical safe zone over time.
    var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "current_center", new_center, duration)
    tween.tween_property(self, "current_radius", new_radius, duration)
    
    tween.finished.connect(func(): zone_shrunk.emit(new_center, new_radius))

func _check_players_in_storm() -> void:
    var players = get_tree().get_nodes_in_group("players")
    for player in players:
        var dist = player.global_position.distance_to(current_center)
        if dist > current_radius:
            _apply_storm_damage(player)

func _apply_storm_damage(player: Node) -> void:
    # 2. Threshold Scaling
    # Increase damage as the radius gets smaller (End-game intensity).
    var scale_factor = (initial_radius / current_radius)
    var final_damage = damage_per_tick * scale_factor
    
    if player.has_method("take_damage"):
        player.take_damage(final_damage, "Storm")

## EXPERT NOTE:
## Use a Global Shader to visualize the storm boundary. 
## Pass 'current_center' and 'current_radius' as Uniforms for perfect sync.
