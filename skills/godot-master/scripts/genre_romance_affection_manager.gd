# affection_manager.gd
# Handles multi-axis relationship tracking, gift systems, and milestone triggers.
# Optimized for Godot 4.x with static typing and Signal-driven architecture.

class_name AffectionManager
extends Node

## Emitted when a relationship reaches a specific threshold.
signal milestone_reached(character_id: String, milestone_index: int, data: Dictionary)

## Emitted whenever any stats change. Useful for UI updates.
signal stats_changed(character_id: String, new_stats: Dictionary)

enum RelationStat { ATTRACTION, TRUST, COMFORT }

const MIN_STAT = -100
const MAX_STAT = 100

# Dictionary structure: { "character_id": { "attraction": 0, "trust": 0, "comfort": 0, "gift_history": {} } }
var _relationship_data: Dictionary = {}

## Adds to a specific stat for a character.
## Usage: AffectionManager.add_stat("alice", AffectionManager.RelationStat.TRUST, 5)
func add_stat(character_id: String, stat: RelationStat, amount: int) -> void:
	_ensure_character(character_id)
	
	var stat_name: String = _get_stat_name(stat)
	var current_val: int = _relationship_data[character_id][stat_name]
	var new_val: int = clamp(current_val + amount, MIN_STAT, MAX_STAT)
	
	_relationship_data[character_id][stat_name] = new_val
	stats_changed.emit(character_id, _relationship_data[character_id])
	_check_milestones(character_id, stat_name, new_val)

## Handles gift giving with diminishing returns logic.
func give_gift(character_id: String, item_data: Dictionary) -> int:
	_ensure_character(character_id)
	
	var base_value: int = item_data.get("value", 5)
	var gift_id: String = item_data.get("id", "generic")
	
	# Diminishing returns calculation
	var history: Dictionary = _relationship_data[character_id].get("gift_history", {})
	var times_given: int = history.get(gift_id, 0)
	
	# Formula: reduce effectiveness by 20% each time, floor at 1 point
	var multiplier: float = max(0.2, 1.0 - (times_given * 0.2))
	var final_amount: int = int(ceil(base_value * multiplier))
	
	# Apply to Attraction by default for gifts
	add_stat(character_id, RelationStat.ATTRACTION, final_amount)
	
	# Update history
	history[gift_id] = times_given + 1
	_relationship_data[character_id]["gift_history"] = history
	
	return final_amount

func get_stats(character_id: String) -> Dictionary:
	_ensure_character(character_id)
	return _relationship_data[character_id].duplicate()

func _ensure_character(character_id: String) -> void:
	if not _relationship_data.has(character_id):
		_relationship_data[character_id] = {
			"attraction": 0,
			"trust": 0,
			"comfort": 0,
			"milestones": [], # indices of milestones already fired
			"gift_history": {}
		}

func _get_stat_name(stat: RelationStat) -> String:
	match stat:
		RelationStat.ATTRACTION: return "attraction"
		RelationStat.TRUST: return "trust"
		RelationStat.COMFORT: return "comfort"
	return ""

func _check_milestones(character_id: String, _stat_name: String, value: int) -> void:
	# Example threshold-based milestones
	var thresholds = [20, 50, 80]
	var record = _relationship_data[character_id]
	
	for i in range(thresholds.size()):
		if value >= thresholds[i] and not i in record["milestones"]:
			record["milestones"].append(i)
			milestone_reached.emit(character_id, i, {"stat": _stat_name, "value": value})
