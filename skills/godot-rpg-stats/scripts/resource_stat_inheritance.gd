# resource_stat_inheritance.gd
# Specialized stat containers (e.g., Elemental Resistances)
class_name ElementalStats extends BaseStats

@export var fire_res: float = 0.0
@export var ice_res: float = 0.0

func get_res(element: String) -> float:
	return get(element + "_res")
