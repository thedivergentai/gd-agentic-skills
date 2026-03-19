# stat_modifier_stacking.gd
# Preventing modifier bloat and conflicts
extends Node

# EXPERT NOTE: Use a unique ID or Name check if you don't 
# want the same buff to stack multiple times.

func apply_unique_buff(stats: StatsComponent, mod: StatusEffectData):
	for existing in stats.modifiers:
		if existing.name == mod.name:
			# Refresh duration instead of adding new
			return
			
	stats.apply_modifier(mod)
