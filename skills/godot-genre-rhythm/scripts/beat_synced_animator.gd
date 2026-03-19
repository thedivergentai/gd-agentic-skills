# beat_synced_animator.gd
extends Node
class_name BeatSyncedAnimator

# Tweening Tied to Conductor Pulses
# Synchronizes visual bounces/scales with the conductor's beat.

func pulse_node(target: CanvasItem) -> void:
    var tween = target.create_tween()
    # Pattern: Use TRANS_ELASTIC or TRANS_BACK for rhythmic bounce feel.
    target.scale = Vector2(1.2, 1.2)
    tween.tween_property(target, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
