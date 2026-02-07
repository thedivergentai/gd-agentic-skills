# skills/animation-player/scripts/animation_sequencer.gd
extends AnimationPlayer

## Animation Sequencer Expert Pattern
## Advanced animation chaining with callbacks and branching logic.

class_name AnimationSequencer

signal sequence_started(sequence_name: String)
signal sequence_completed(sequence_name: String)
signal animation_in_sequence_finished(anim_name: String, index: int)

var _current_sequence: Array[Dictionary] = []
var _sequence_index := 0
var _is_sequence_playing := false

func play_sequence(animations: Array[String], sequence_name := "") -> void:
	if animations.is_empty():
		return
	
	_current_sequence.clear()
	for anim_name in animations:
		_current_sequence.append({"animation": anim_name, "callback": Callable()})
	
	_sequence_index = 0
	_is_sequence_playing = true
	sequence_started.emit(sequence_name)
	_play_next_in_sequence()

func play_sequence_with_callbacks(sequence: Array[Dictionary]) -> void:
	# sequence = [{animation: "walk", callback: Callable}, ...]
	_current_sequence = sequence.duplicate()
	_sequence_index = 0
	_is_sequence_playing = true
	_play_next_in_sequence()

func _play_next_in_sequence() -> void:
	if _sequence_index >= _current_sequence.size():
		_is_sequence_playing = false
		sequence_completed.emit("")
		return
	
	var entry: Dictionary = _current_sequence[_sequence_index]
	var anim_name: String = entry.animation
	
	if not has_animation(anim_name):
		push_warning("Animation '%s' not found, skipping" % anim_name)
		_sequence_index += 1
		_play_next_in_sequence()
		return
	
	play(anim_name)
	
	# Execute callback if provided
	if entry.has("callback") and entry.callback.is_valid():
		entry.callback.call()
	
	# Wait for completion
	if not animation_finished.is_connected(_on_sequence_anim_finished):
		animation_finished.connect(_on_sequence_anim_finished)

func _on_sequence_anim_finished(anim_name: String) -> void:
	if not _is_sequence_playing:
		return
	
	animation_in_sequence_finished.emit(anim_name, _sequence_index)
	_sequence_index += 1
	_play_next_in_sequence()

func stop_sequence() -> void:
	_is_sequence_playing = false
	_current_sequence.clear()
	_sequence_index = 0
	stop()

## EXPERT USAGE:
## var sequencer := AnimationSequencer.new()
## 
## # Simple sequence
## sequencer.play_sequence(["attack_1", "attack_2", "idle"])
## 
## # With callbacks
## sequencer.play_sequence_with_callbacks([
##     {animation: "windup", callback: func(): print("Winding up!")},
##     {animation: "strike", callback: func(): deal_damage()},
##     {animation: "recovery", callback: Callable()}
## ])
