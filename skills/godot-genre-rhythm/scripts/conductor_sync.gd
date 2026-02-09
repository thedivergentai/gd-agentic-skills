# skills/genre-rhythm/code/conductor_sync.gd
extends Node

## Music Conductor Expert Pattern
## Uses AudioServer latency-compensated time for beat synchronization.

signal beat_hit(position: int)
signal measure_hit(position: int)

@export var bpm: float = 120.0
@export var measures_per_bar: int = 4
@export var music_player: AudioStreamPlayer

var _sec_per_beat: float
var _song_position: float = 0.0
var _song_position_in_beats: float = 0.0
var _last_reported_beat: int = 0
var _beats_before_start: int = 0

func _ready() -> void:
    _sec_per_beat = 60.0 / bpm

func _process(_delta: float) -> void:
    if not music_player.playing: return
    
    # 1. Latency Compensation
    # Professional rhythm systems use the AudioServer clock, NOT delta.
    var playback_pos = music_player.get_playback_position()
    var latency = AudioServer.get_output_latency()
    
    _song_position = playback_pos + latency
    _song_position_in_beats = _song_position / _sec_per_beat
    
    _report_beat()

func _report_beat() -> void:
    var current_beat = int(floor(_song_position_in_beats))
    
    if current_beat > _last_reported_beat:
        _last_reported_beat = current_beat
        beat_hit.emit(current_beat)
        
        if current_beat % measures_per_bar == 0:
            measure_hit.emit(current_beat / measures_per_bar)

func start_song() -> void:
    _last_reported_beat = 0
    music_player.play()

## EXPERT NOTE:
## For multi-track stems, use AudioStreamPlayer.sync_to() if available.
## NEVER rely on '_process' delta for high-speed rhythm logic; the AudioServer 
## time is the only source of truth that stays in sync with samples.
