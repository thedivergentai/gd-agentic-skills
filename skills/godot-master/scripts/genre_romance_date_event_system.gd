# date_event_system.gd
# Manages date logic, location preferences, and outcome calculations.
# Designed to be used with a Resource-based system for DateLocations (not included).

class_name DateEventSystem
extends Node

## Emitted when a date concludes.
signal date_finished(character_id: String, outcome: String, score: int)

## Emitted when a specific interaction occurs during a date.
signal date_interaction(character_id: String, dialogue_key: String)

enum Outcome { DISASTER, MILD, SUCCESS, PERFECT }

# Tracker to prevent "Same Date Order" trap
# { "character_id": ["park", "cafe", "cinema"] }
var _date_history: Dictionary = {}

## Evaluates a date at a given location.
## location_data structure: { "id": "park", "trust_weight": 0.5, "attraction_weight": 1.5, "thresholds": [0, 10, 30, 50] }
func evaluate_date(character_id: String, location_data: Dictionary, choice_modifiers: int = 0) -> Outcome:
	var stats: Dictionary = AffectionManager.get_stats(character_id)
	
	# Weighted success calculation
	var score: float = 0.0
	score += stats["attraction"] * location_data.get("attraction_weight", 1.0)
	score += stats["trust"] * location_data.get("trust_weight", 1.0)
	score += stats["comfort"] * location_data.get("comfort_weight", 1.0)
	score += choice_modifiers
	
	# Apply variety penalty if same location repeated recently
	var history = _date_history.get(character_id, [])
	if history.size() > 0 and history[-1] == location_data["id"]:
		score *= 0.7 # 30% penalty for repetitiveness
		date_interaction.emit(character_id, "repetitive_date_complaint")
	
	# Add to history
	_add_to_history(character_id, location_data["id"])
	
	# Determine outcome
	var result_score = int(score)
	var thresholds = location_data.get("thresholds", [-10, 10, 30, 60])
	var outcome: Outcome = Outcome.DISASTER
	
	if result_score >= thresholds[3]: outcome = Outcome.PERFECT
	elif result_score >= thresholds[2]: outcome = Outcome.SUCCESS
	elif result_score >= thresholds[1]: outcome = Outcome.MILD
	
	_apply_outcome_rewards(character_id, outcome)
	date_finished.emit(character_id, _get_outcome_string(outcome), result_score)
	
	return outcome

func _add_to_history(character_id: String, location_id: String) -> void:
	if not _date_history.has(character_id):
		_date_history[character_id] = []
	_date_history[character_id].append(location_id)
	if _date_history[character_id].size() > 5:
		_date_history[character_id].remove_at(0)

func _get_outcome_string(outcome: Outcome) -> String:
	match outcome:
		Outcome.DISASTER: return "DISASTER"
		Outcome.MILD: return "MILD"
		Outcome.SUCCESS: return "SUCCESS"
		Outcome.PERFECT: return "PERFECT"
	return "UNKNOWN"

func _apply_outcome_rewards(char_id: String, outcome: Outcome) -> void:
	match outcome:
		Outcome.PERFECT:
			AffectionManager.add_stat(char_id, AffectionManager.RelationStat.ATTRACTION, 10)
			AffectionManager.add_stat(char_id, AffectionManager.RelationStat.TRUST, 5)
		Outcome.SUCCESS:
			AffectionManager.add_stat(char_id, AffectionManager.RelationStat.ATTRACTION, 5)
		Outcome.DISASTER:
			AffectionManager.add_stat(char_id, AffectionManager.RelationStat.TRUST, -5)
			AffectionManager.add_stat(char_id, AffectionManager.RelationStat.ATTRACTION, -2)
