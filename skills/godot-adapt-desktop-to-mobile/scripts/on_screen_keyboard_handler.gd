extends Control
class_name OnScreenKeyboardHandler

## Expert Virtual Keyboard Management
## When a LineEdit or TextEdit is focused on mobile, the OS pops up a virtual keyboard
## that covers the bottom 30-50% of the screen. We must push the UI UP to keep the input visible.

@export var layout_container: Control # The main UI root to shift

func _ready() -> void:
    # Connect to the OS virtual keyboard signals
    DisplayServer.virtual_keyboard_update.connect(_on_virtual_keyboard_changed)

func _on_virtual_keyboard_changed(keyboard_height: float) -> void:
    if not OS.has_feature("mobile"): return
    
    if keyboard_height > 0:
        # Keyboard opened.
        # Push the UI up by the height of the keyboard
        var tween = create_tween()
        tween.tween_property(layout_container, "position:y", -keyboard_height, 0.2).set_trans(Tween.TRANS_SINE)
    else:
        # Keyboard closed. Return UI to normal.
        var tween = create_tween()
        tween.tween_property(layout_container, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

## Automatically close the keyboard if the user taps outside the LineEdit
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        var focus_owner = get_viewport().gui_get_focus_owner()
        if focus_owner and (focus_owner is LineEdit or focus_owner is TextEdit):
            # If they didn't touch the text box, release focus and hide keyboard
            var local_event = focus_owner.make_input_local(event)
            if not focus_owner.get_rect().has_point(local_event.position):
                focus_owner.release_focus()
                DisplayServer.virtual_keyboard_hide()
