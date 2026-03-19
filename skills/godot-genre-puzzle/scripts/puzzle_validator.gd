# puzzle_validator.gd
extends Node
class_name PuzzleValidator

# Array Reduction for Victory Conditions
# Validates completion using optimized functional reduction lambdas.

func check_all_resolved(objectives: Array) -> bool:
    # Pattern: Use Godot 4's functional reduction for concise win checking.
    var completed: int = objectives.reduce(
        func(count, next): return count + 1 if next.get("is_resolved") else count, 0
    )
    return completed == objectives.size()
