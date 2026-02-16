# godot-master/scripts/ui_rich_text_rich_text_animator.gd
extends RichTextLabel

## RichTextLabel Animator Expert Pattern
## Typewriter effect with custom BBCode event handling and pauses.

class_name RichTextAnimator

signal message_finished
signal character_displayed(char_index: int)
signal custom_tag_encountered(tag: String)

@export var speed_chars_per_sec := 50.0
@export var punctuation_pause := 0.4

var _target_visible_ratio := 0.0
var _current_text := ""
var _is_typing := false

func show_text(bbcode_text: String) -> void:
	text = bbcode_text
	visible_ratio = 0.0
	_target_visible_ratio = 1.0
	_is_typing = true
	
	# Start tweening
	var tween := create_tween()
	var total_chars := get_total_character_count()
	var duration := total_chars / speed_chars_per_sec
	
	# Create a method tween to handle granular logic (pauses)
	tween.tween_method(_update_visible_chars, 0.0, 1.0, duration)
	tween.finished.connect(_on_finished)

func _update_visible_chars(ratio: float) -> void:
	visible_ratio = ratio
	
	var char_count = get_total_character_count()
	var current_index = int(ratio * char_count)
	
	character_displayed.emit(current_index)
	
	# Handle pauses for punctuation (This is a simplified example)
	# For robust pauses, you would pre-scan the text for custom tags like [pause=1.0]

func _on_finished() -> void:
	_is_typing = false
	visible_ratio = 1.0
	message_finished.emit()

func install_custom_effect(effect: RichTextEffect) -> void:
	if not custom_effects.has(effect):
		custom_effects.append(effect)

## EXPERT USAGE:
## @onready var label = $RichTextAnimator
## label.show_text("Hello [wave]World[/wave]!")
## await label.message_finished
