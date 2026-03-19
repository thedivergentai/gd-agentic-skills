class_name AudioProceduralGeneratorSynth
extends Node

## Expert real-time procedural audio synthesizer.
## Pushes raw frames to an 'AudioStreamGeneratorPlayback'.

var playback: AudioStreamGeneratorPlayback
var sample_rate: float

func _ready() -> void:
	var generator = $AudioStreamPlayer.stream as AudioStreamGenerator
	sample_rate = generator.mix_rate
	playback = $AudioStreamPlayer.get_stream_playback()

func fill_buffer(frequency: float = 440.0) -> void:
	var phase = 0.0
	var increment = frequency / sample_rate
	var frames_to_fill = playback.get_frames_available()
	
	for i in range(frames_to_fill):
		var sample = sin(phase * TAU)
		playback.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)

## Rule: Always check 'get_frames_available()' before pushing to avoid buffer underrun.
