# input_judge_logic.gd
extends Node
class_name InputJudgeLogic

# Window-Based Hit Validation
# Compares input timing against target beat time with specific windows.

@export var window_perfect := 0.05 # 50ms
@export var window_good := 0.1     # 100ms
@export var window_ok := 0.15      # 150ms

enum HitResult { NONE, PERFECT, GOOD, OK, MISS }

func judge_hit(current_time: float, target_time: float) -> HitResult:
    var diff = abs(current_time - target_time)
    
    # Pattern: Sequential window checks from smallest to largest.
    if diff <= window_perfect: return HitResult.PERFECT
    if diff <= window_good: return HitResult.GOOD
    if diff <= window_ok: return HitResult.OK
    return HitResult.MISS
