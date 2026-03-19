# deep_stat_duplicator.gd
# Preventing resource leakage across shared templates
extends Node

# EXPERT NOTE: Resources are shared by reference. 
# You MUST duplicate() them to avoid global state pollution.

@export var template_stats: BaseStats

var current_stats: BaseStats

func _ready():
	# EXPERT: Deep duplicate ensures this instance has its own health/buffs
	current_stats = template_stats.duplicate()

func apply_poison():
	# Only affects this specific instance
	current_stats.max_health -= 5
