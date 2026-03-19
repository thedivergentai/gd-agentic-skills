# rts_unit_stat_duplicator.gd
extends Node
class_name RTSUnitStatDuplicator

# Deep Duplication of Unit Stats
# Ensures unique health/armor per unit instead of sharing a global Resource.

@export var base_stats: Resource
var active_stats: Resource

func _ready() -> void:
    if base_stats:
        # Pattern: Deep duplication to isolate dictionaries/arrays within the resource.
        active_stats = base_stats.duplicate(true)

func modify_stat(stat_name: StringName, amount: float) -> void:
    if active_stats and stat_name in active_stats:
        active_stats.set(stat_name, active_stats.get(stat_name) + amount)
