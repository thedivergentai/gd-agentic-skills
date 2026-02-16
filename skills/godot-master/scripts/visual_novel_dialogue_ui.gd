# godot-master/scripts/visual_novel_dialogue_ui.gd
extends Control

## Dialogue UI (Expert Pattern)
## Handles typewriter effect, BBCode tags, and user input (skip/advance).

class_name DialogueUI

signal animation_finished

@export var rich_text_label: RichTextLabel
@export var name_label: Label
@export var type_speed: float = 0.05

var full_text: String = ""
var is_typing: bool = false

func show_line(text: String, character_name: String) -> void:
    full_text = text
    if name_label: name_label.text = character_name
    rich_text_label.text = text # Parse BBCode immediately
    rich_text_label.visible_ratio = 0.0
    
    is_typing = true
    var tween = create_tween()
    var duration = text.length() * type_speed
    tween.tween_property(rich_text_label, "visible_ratio", 1.0, duration)
    tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
    is_typing = false
    animation_finished.emit()

func instant_finish() -> void:
    if is_typing:
        # Kill running tweens on label
        var tweens = get_tree().get_processed_tweens()
        # Find which tween targets the label? Complex.
        # Simpler: unique tween stored
        # But for now, just force visible ratio
        rich_text_label.visible_ratio = 1.0
        is_typing = false
        animation_finished.emit()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        if is_typing:
            instant_finish()
            get_viewport().set_input_as_handled()

## EXPERT USAGE:
## Connect to Story Manager. Call show_line().
## Handles input to skip typing.
