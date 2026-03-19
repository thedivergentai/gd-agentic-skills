# stat_reduction_solver.gd
# Calculating complex modifier chains using C++ performance loops
extends Node

# EXPERT NOTE: Using reduce() is faster than manual GDScript loops 
# for calculating total damage from a list of multipliers.

func calculate_total_damage(base_dmg: float, modifiers: Array[float]) -> float:
	# Optimized reduction in the engine's internal VM
	return modifiers.reduce(func(accum, val): return accum * val, base_dmg)

func apply_defense(dmg: float, def_res: BaseStats) -> float:
	return max(0, dmg - def_res.defense)
