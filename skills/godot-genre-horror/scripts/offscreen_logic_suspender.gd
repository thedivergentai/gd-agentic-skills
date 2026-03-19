# offscreen_logic_suspender.gd
extends Node

# Suspending Off-Screen AI (CPU Optimization)
# Used in conjunction with VisibleOnScreenNotifier3D to save cycles.
func _on_screen_exited() -> void:
    # Disabling physics processing reclaims CPU cycles when the monster isn't visible.
    # CRITICAL: Ensure visual-only effects (sound cues) handle this state carefully.
    set_physics_process(false)

func _on_screen_entered() -> void:
    # Resume immediately when entering player frustum.
    set_physics_process(true)
