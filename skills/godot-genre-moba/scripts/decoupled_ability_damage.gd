# decoupled_ability_damage.gd
extends Area2D
class_name DecoupledAbilityDamage

# Safe Duck-Typing for Ability Damage
# Interacts with target heroes/entities without hard class coupling.

@export var damage_amount: int = 50

func _on_body_entered(body: Node) -> void:
    # Pattern: Check if method exists before calling.
    # Allows projectiles to hit minions, heroes, and buildings interchangeably.
    if body.has_method(&"take_damage"):
        body.take_damage(damage_amount)
        _on_hit_confirmed()

func _on_hit_confirmed() -> void:
    # Handle projectile destruction or effects.
    queue_free()
