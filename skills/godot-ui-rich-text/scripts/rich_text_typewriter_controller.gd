class_name RichTextTypewriterController
extends RichTextLabel

## Expert Dialogue Typewriter with Event Tags.
## Parses [pause=0.5] and [speed=2.0] in-line.

signal event_triggered(cmd: String, val: Variant)
signal message_completed

var _events: Dictionary = {}
var _default_speed: float = 0.05
var _current_speed: float = 0.05
var _is_active: bool = false

func play_text(raw_bbcode: String) -> void:
	_events.clear()
	_current_speed = _default_speed
	
	var regex := RegEx.new()
	# Matches [pause=X] or [speed=X]
	regex.compile("\\[(pause|speed|event)=([^\\]]+)\\]")
	
	var clean_text := raw_bbcode
	var offset := 0
	
	for m in regex.search_all(raw_bbcode):
		var full_match = m.get_string()
		var cmd = m.get_string(1)
		var val = m.get_string(2)
		
		# Map character index to event
		var idx = m.get_start() - offset
		_events[idx] = {"cmd": cmd, "val": val}
		
		clean_text = clean_text.replace(full_match, "")
		offset += full_match.length()
	
	self.text = clean_text
	self.visible_characters = 0
	_is_active = true
	_tick()

func _tick() -> void:
	if not _is_active or visible_characters >= get_total_character_count():
		_is_active = false
		message_completed.emit()
		return
	
	visible_characters += 1
	var delay := _current_speed
	
	if _events.has(visible_characters):
		var ev = _events[visible_characters]
		match ev.cmd:
			"pause": delay = ev.val.to_float()
			"speed": _current_speed = ev.val.to_float(); delay = _current_speed
			"event": event_triggered.emit("event", ev.val)
	
	get_tree().create_timer(delay).timeout.connect(_tick)

func skip() -> void:
	visible_characters = -1 # Show all
	_is_active = false
	message_completed.emit()
