# base_stat_resource.gd
# Defining character stats as data-driven Resources
class_name BaseStats extends Resource

# EXPERT NOTE: Custom resources allow designers to edit stats 
# directly in the Inspector and save them as .tres files.

@export var max_health: int = 100
@export var attack_power: int = 10
@export var defense: int = 5
@export var speed: float = 300.0

# Mandatory parameterless constructor for Editor support
func _init(p_max_health = 100, p_atk = 10):
	max_health = p_max_health
	attack_power = p_atk
