# rhythm_ui_feedback.gd
extends Control
class_name RhythmUIFeedback

# Visual Response for Hit Quality
# Spawns transient labels indicating Early/Late/Perfect status.

@export var feedback_colors: Dictionary = {
    "PERFECT": Color.GOLD,
    "GOOD": Color.CYAN,
    "OK": Color.GREEN,
    "MISS": Color.RED
}

func show_feedback(result_name: String) -> void:
    var label = Label.new()
    label.text = result_name
    label.modulate = feedback_colors.get(result_name, Color.WHITE)
    add_child(label)
    
    var tween = create_tween()
    # Pattern: Fade out and move up simultaneously.
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", label.position.y - 50, 0.4)
    tween.tween_property(label, "modulate:a", 0.0, 0.4)
    tween.chain().tween_callback(label.queue_free)
