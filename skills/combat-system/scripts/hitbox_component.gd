# skills/combat-system/scripts/hitbox_component.gd
extends Area3D

## Hitbox Component Expert Pattern
## Standardized damage delivery system working in tandem with HurtboxComponent.

class_name HitboxComponent

@export var damage := 10.0
@export var knockback_force := 5.0
@export var hit_stun_time := 0.2
@export var attack_element := "Physical" # Or Enum

# Optional: Team filtering (layer/mask is preferred, but this adds logic layer)
@export var team_index := 0 

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitorable = true
	monitoring = true

func _on_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		if area.team_index != team_index: # Prevent friendly fire
			var attack_data = AttackData.new()
			attack_data.damage = damage
			attack_data.knockback_force = knockback_force
			attack_data.hit_stun_time = hit_stun_time
			attack_data.element = attack_element
			attack_data.source_position = global_position
			attack_data.attacker = owner
			
			area.receive_hit(attack_data)

## EXPERT USAGE:
## 1. Add HitboxComponent to Weapon/Projectile
## 2. Set Collision Layer to 'Hitbox'
## 3. Set Collision Mask to 'Hurtbox'
