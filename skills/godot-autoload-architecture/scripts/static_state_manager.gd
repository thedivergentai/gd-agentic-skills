# static_state_manager.gd
# Using static variables for high-performance global state
extends RefCounted
class_name GlobalState

# EXPERT NOTE: static var is shared across all instances of the class. 
# It does NOT require an Autoload node in the SceneTree. 
# Access via: GlobalState.score += 10

static var score: int = 0
static var player_name: String = "Player1"
static var unlocked_levels: Array[int] = [1]

static func add_score(val: int) -> void:
	score += val

static func is_level_unlocked(lvl: int) -> bool:
	return unlocked_levels.has(lvl)
