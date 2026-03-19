# exp_progression_resource.gd
# Data-driven level up curve
class_name ExpProgression extends Resource

@export var base_exp: int = 100
@export var growth_factor: float = 1.2

func get_required_exp(level: int) -> int:
	return int(base_exp * pow(growth_factor, level - 1))
