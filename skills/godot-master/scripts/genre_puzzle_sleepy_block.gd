# sleepy_block.gd
extends RigidBody2D
class_name SleepyBlock

# Interactive Physics Puzzle Sleep State
# Interfaces with low-level body state to force sleep on demand.

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    # Pattern: Optimize interactive puzzles by sleeping when movement is negligible.
    if state.get_linear_velocity().length() < 5.0 and state.get_angular_velocity() < 0.1:
        state.sleeping = true
