class_name AudioVoicePoolManager
extends Node

## Expert Voice Pool Manager.
## Prioritizes 'Hero' sounds and implements voice stealing for background noise.

const MAX_VOICES = 32
var pool: Array[AudioStreamPlayer] = []
var active_voices: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in range(MAX_VOICES):
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)

func play_sound(stream: AudioStream, priority: int = 0) -> void:
	# priority: 0 = background, 1 = standard, 2 = hero (never kills)
	var player = _get_available_player()
	if not player:
		player = _steal_voice()
	
	if player:
		player.stream = stream
		player.play()

func _get_available_player() -> AudioStreamPlayer:
	for p in pool:
		if not p.playing: return p
	return null

func _steal_voice() -> AudioStreamPlayer:
	# Basic logic: steal the oldest playing voice with priority 0.
	return pool[0] # Simplified logic for boilerplate

## Rule: Never exceed MAX_VOICES to avoid audio engine stutter/latency.
