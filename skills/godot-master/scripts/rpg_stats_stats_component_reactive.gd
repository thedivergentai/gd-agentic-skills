# stats_component_reactive.gd
# Orchestrator for dynamic stat calculation
class_name StatsComponent extends Node

# EXPERT NOTE: The final value is calculated "Just-In-Time" 
# to ensure all active modifiers are correctly applied.

signal stats_recalculated
signal hp_changed(current: int, max: int)

@export var base: BaseStats
var modifiers: Array[StatusEffectData] = []

var current_hp: int = 0

func _ready():
	if base:
		current_hp = base.get_max_hp()

func get_attribute(attr_name: String) -> float:
	var val = base.get(attr_name) as float
	
	# Apply additive modifiers first
	for mod in modifiers:
		if mod.attribute == attr_name and mod.type == StatusEffectData.Type.ADDITIVE:
			val += mod.value
	
	# Then apply multipliers
	for mod in modifiers:
		if mod.attribute == attr_name and mod.type == StatusEffectData.Type.MULTIPLICATIVE:
			val *= mod.value
			
	return val

func apply_modifier(mod: StatusEffectData):
	modifiers.append(mod)
	stats_recalculated.emit()
	
	if mod.duration > 0:
		get_tree().create_timer(mod.duration).timeout.connect(
			func(): remove_modifier(mod)
		)

func remove_modifier(mod: StatusEffectData):
	modifiers.erase(mod)
	stats_recalculated.emit()
