# static_var_singleton_alt.gd
# Using static variables for global state without Autoloads
extends Node
class_name GlobalState

# EXPERT NOTE: static var is shared across all scripts. 
# Accessible via GlobalState.score from anywhere.

static var score: int = 0
static var unlocked_levels: Array[int] = [1]

static func add_score(val: int):
	score += val

static func is_unlocked(lvl: int) -> bool:
	return unlocked_levels.has(lvl)
