# godot-master/scripts/combat_system_hitbox_hurtbox.gd
extends Area2D

## Hitbox/Hurtbox Expert Pattern
## Component-based combat with Hit-Stop and Knockback support.

class_name Hitbox # Or Hurtbox, defined by usage

@export var damage: float = 10.0
@export var knockback_force: float = 200.0
@export var hit_stop_duration: float = 0.05 # Engine freeze time

func _on_area_entered(hurtbox: Area2D) -> void:
    if hurtbox.has_method("take_damage"):
        # 1. Calculate Knockback Vector
        var source_pos = global_position
        var target_pos = hurtbox.global_position
        var kb_direction = (target_pos - source_pos).normalized()
        
        # 2. Trigger Hit-Stop (Global Freeze)
        _apply_hit_stop()
        
        # 3. Transmit Data
        hurtbox.take_damage(damage, kb_direction * knockback_force)

func _apply_hit_stop() -> void:
    Engine.time_scale = 0.0
    await get_tree().create_timer(hit_stop_duration, true, false, true).timeout
    Engine.time_scale = 1.0

## EXPERT NOTE:
## Time-scale manipulation for hit-stop must use a SceneTreeTimer 
## with 'ignore_time_scale' set to true, or the timer itself will freeze!
