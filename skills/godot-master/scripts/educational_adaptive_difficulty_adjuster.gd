# godot-master/scripts/educational_adaptive_difficulty_adjuster.gd
extends Node

## Adaptive Difficulty Adjuster Expert Pattern
## Features Success-Ratio Tracking and Branching Hint Logic.

signal difficulty_changed(level: int)
signal hint_suggested(hint_text: String)

@export var window_size: int = 5 # Track last 5 attempts
@export var up_threshold: float = 0.8 # Move up if > 80% success
@export var down_threshold: float = 0.4 # Move down if < 40% success

var _recent_results: Array[bool] = []
var _current_difficulty_level: int = 1

func log_result(is_correct: bool) -> void:
    _recent_results.append(is_correct)
    if _recent_results.size() > window_size:
        _recent_results.remove_at(0)
    
    _evaluate_difficulty()
    
    if not is_correct:
        _provide_contextual_hint()

func _evaluate_difficulty() -> void:
    if _recent_results.size() < window_size: return
    
    var correct_count = _recent_results.count(true)
    var ratio = float(correct_count) / window_size
    
    if ratio >= up_threshold:
        _current_difficulty_level += 1
        difficulty_changed.emit(_current_difficulty_level)
        _recent_results.clear() # Reset window after shift
    elif ratio <= down_threshold:
        _current_difficulty_level = max(1, _current_difficulty_level - 1)
        difficulty_changed.emit(_current_difficulty_level)
        _recent_results.clear()

func _provide_contextual_hint() -> void:
    # 1. Branching Hint Logic
    # Professionals provide progressive disclosure: 
    # Small nudge -> Tooltip -> Full explanation.
    var consecutive_fails = 0
    for i in range(_recent_results.size() -1, -1, -1):
        if not _recent_results[i]: consecutive_fails += 1
        else: break
        
    match consecutive_fails:
        1: hint_suggested.emit("Focus on the highlighted area.")
        2: hint_suggested.emit("Remember: Addition happens before multiplication in this step.")
        3: hint_suggested.emit("Let's review the PEMDAS tutorial together.")

## EXPERT NOTE:
## Store '_current_difficulty_level' in a 'StudentProfile' Resource 
## to maintain a tailored experience across sessions.
