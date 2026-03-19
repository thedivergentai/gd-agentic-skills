# entity_stat_duplicator.gd
extends Node
class_name EntityStatDuplicator

# Deep Duplication for Unique Entity State
# Ensures instanced enemies/allies have unique stat blocks, not globally shared ones.

@export var base_stats: CharacterStatsResource
var current_stats: CharacterStatsResource

func _ready() -> void:
    # Pattern: ALWAYS duplicate shared resources to prevent cross-entity state leaks.
    if base_stats:
        # Use DEEP_DUPLICATE_ALL to ensure internal dictionaries/sub-resources are unique.
        current_stats = base_stats.duplicate(true) as CharacterStatsResource
        print("Stats localized for: ", get_parent().name)
