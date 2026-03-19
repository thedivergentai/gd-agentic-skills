# score_combo_manager.gd
extends Node
class_name ScoreComboManager

# Functional Reduction for Multipliers
# Manages combo-based scoring with persistent state.

var score := 0
var combo := 0
var max_combo := 0

func add_hit(multiplier: int) -> void:
    combo += 1
    max_combo = max(combo, max_combo)
    
    # Pattern: Scale score by combo milestones.
    var combo_bonus = 1.0 + (floor(combo / 10.0) * 0.1)
    score += int(100 * multiplier * combo_bonus)

func reset_combo() -> void:
    combo = 0
