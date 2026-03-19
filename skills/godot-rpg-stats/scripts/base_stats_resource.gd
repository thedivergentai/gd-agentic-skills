# base_stats_resource.gd
# Core data container for RPG attributes
class_name BaseStats extends Resource

# EXPERT NOTE: Using a Resource for base stats allows for 
# "Template" creation in the Inspector (e.g., GoblinStats, BossStats).

@export_group("Primary Attributes")
@export var strength: int = 10
@export var dexterity: int = 10
@export var intelligence: int = 10

@export_group("Derived Scaling")
@export var hp_per_strength: float = 5.0
@export var mp_per_intelligence: float = 3.0

func get_max_hp() -> int:
	return int(strength * hp_per_strength)

func get_max_mp() -> int:
	return int(intelligence * mp_per_intelligence)
