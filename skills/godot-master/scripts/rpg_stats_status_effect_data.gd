# status_effect_data.gd
# Data definition for buffs and debuffs
class_name StatusEffectData extends Resource

# EXPERT NOTE: Defining effects as Resources makes them 
# strictly data-driven and easy to serialize/save.

enum Type { ADDITIVE, MULTIPLICATIVE, OVERRIDE }

@export var name: String = "Effect"
@export var type: Type = Type.ADDITIVE
@export var attribute: String = "strength"
@export var value: float = 0.0
@export var duration: float = 5.0
@export var icon: Texture2D
