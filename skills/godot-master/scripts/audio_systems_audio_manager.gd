# godot-master/scripts/audio_systems_audio_manager.gd
extends Node

## AudioManager Singleton Expert Pattern
## Centralized system for sound pooling and bus management.

const MAX_POOL_SIZE = 32
var _pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
    # 1. Initialize Sound Pool
    for i in range(MAX_POOL_SIZE):
        var player = AudioStreamPlayer.new()
        add_child(player)
        _pool.append(player)

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
    # 2. Find Available Player
    var player = _find_available_player()
    if player:
        player.stream = stream
        player.bus = bus
        player.play()

func crossfade_music(to_stream: AudioStream, duration: float = 1.0) -> void:
    # 3. Dynamic Music Crossfading logic
    pass

func _find_available_player() -> AudioStreamPlayer:
    for player in _pool:
        if not player.playing:
            return player
    return null

## NEVER LIST:
## - NEVER play positional 3D audio on a node that dies.
## - Use 'AudioStreamPlayer3D' but parent it to the world root, 
##   setting its 'global_position' manually.
