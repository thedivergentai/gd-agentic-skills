# leveling_table.gd
# Data-driven XP required curves
extends Resource
class_name LevelingTable

# EXPERT NOTE: Using a curve or a formula in a Resource 
# allows balancing progression without touching code.

@export var xp_curve: Curve

func get_required_xp(level: int) -> int:
	# Sample from the designer-defined balance curve
	return int(xp_curve.sample(float(level) / 100.0) * 1000)
