# status_effect_data.gd
extends Resource
class_name StatusEffectData

# Resource-Based Status Effect Data
# Lightweight persistent container for MOBA buffs/debuffs.

@export var effect_id: StringName = &"stun"
@export var duration: float = 1.0
@export var speed_multiplier: float = 1.0
@export var damage_over_time: int = 0
@export var is_cleansable: bool = true
@export var icon: Texture2D
