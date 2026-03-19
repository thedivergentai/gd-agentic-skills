# romance_patterns.gd
extends Node

# 1. Type-Safe Affection Dictionary
# EXPERT NOTE: Use StringNames for fast lookups in narrative state tracking.
var affection_stats: Dictionary[StringName, int] = {
    &"CharacterA": 0,
    &"CharacterB": 0
}

# 2. Custom RichTextEffect for Emotive Text
# EXPERT NOTE: Create dynamic text animations (like shaking) via BBCode effects.
@tool
class_name ShakeEffect extends RichTextEffect
var bbcode := "shake"
func _process_custom_fx(char_fx: CharFXTransform) -> bool:
    char_fx.transform = char_fx.transform.translated(Vector2(randf_range(-1, 1), 0))
    return true

# 3. Context-Aware Localization
# EXPERT NOTE: Resolves ambiguities (e.g., "Close" the door vs "Close" in distance).
func print_dialogue(label: Label, key: String, context: StringName) -> void:
    label.text = tr(key, context)

# 4. Connecting Meta Clicks for Hyperlinked Choices
# EXPERT NOTE: Captures clicks on [url] tags inside the RichTextLabel for interactive logs.
func setup_meta_links(rtl: RichTextLabel) -> void:
    rtl.meta_clicked.connect(func(meta): OS.shell_open(str(meta)))

# 5. Typewriter Effect via Tweens
# EXPERT NOTE: Cleaner than using _process timers; allows easy speed control.
func play_typewriter(label: RichTextLabel, duration: float) -> void:
    label.visible_ratio = 0.0
    var tween := create_tween()
    tween.tween_property(label, "visible_ratio", 1.0, duration)

# 6. Serializing Preferences via ConfigFile
# EXPERT NOTE: Ideal for global settings like "Skip Read Text" or "Auto Play".
func save_romance_settings(path: String, skip_read: bool) -> void:
    var config := ConfigFile.new()
    config.set_value("Dialogue", "skip_read", skip_read)
    config.save(path)

# 7. Unbinding Signals for Generic Advance
# EXPERT NOTE: Drops the default boolean argument emitted by buttons for clean callbacks.
func connect_advance_btn(btn: Button, callback: Callable) -> void:
    btn.pressed.connect(callback.unbind(1))

# 8. Handling Pluralization Safely
# EXPERT NOTE: Properly translates "1 rose" vs "2 roses" based on locale rules.
func get_gift_text(amount: int) -> String:
    return atr_n("You received %s rose.", "You received %s roses.", amount) % amount

# 9. Dynamic Choice Button Injection
# EXPERT NOTE: Instances buttons for branching choices based on narrative state.
func populate_choices(container: Control, choices: Array[StringName], callback: Callable) -> void:
    for choice in choices:
        var btn := Button.new()
        btn.text = tr(choice)
        btn.pressed.connect(callback.bind(choice))
        container.add_child(btn)

# 10. Hiding UI for CG Views (Cinematic)
# EXPERT NOTE: Use alpha modulation to smoothly transition between UI and CG art.
func toggle_ui_visibility(canvas: CanvasLayer, is_visible: bool) -> void:
    var tween := create_tween()
    tween.tween_property(canvas, "modulate:a", 1.0 if is_visible else 0.0, 0.5)
