---
name: godot-audio-systems
description: "Expert patterns for Godot audio including AudioStreamPlayer variants (2D positional, 3D spatial), AudioBus mixing architecture, dynamic effects (reverb, EQ,compression), audio pooling for performance, music transitions (crossfade, bpm-sync), and procedural audio generation. Use for music systems, sound effects, spatial audio, or audio-reactive gameplay. Trigger keywords: AudioStreamPlayer, AudioStreamPlayer2D, AudioStreamPlayer3D, AudioBus, AudioServer, AudioEffect, music_crossfade, audio_pool, positional_audio, reverb, bus_volume."
---

# Audio Systems

Expert guidance for Godot's audio engine and mixing architecture.

## NEVER Do (Expert Audio Rules)

### Mixing & Buses
- **NEVER set bus volume with linear values** — `set_bus_volume_db()` is logarithmic. Use `linear_to_db()` for sliders OR everything will sound too loud until the last 5%.
- **NEVER skip 'Bus Routing'** — Playing music on the 'SFX' bus makes volume menus useless. Strictly route every player to its dedicated sub-bus (Music, SFX, UI, Voice).
- **NEVER use 'Master' for gameplay sounds** — Dedicate Master to final limiting. Route all gameplay to sub-groups so you can mute/duck categories.

### Positional & Spatial
- **NEVER use 3D players without an Attenuation Model** — Default is NONE. If you don't set it to `Inverse Distance`, a whisper on the other side of the map will be global volume.
- **NEVER play 3D sounds exactly on top of the listener** — Causes "Panning Jitter" where the sound snaps between Left/Right speakers. Offset by `0.1` units.
- **NEVER forget Doppler for high-speed objects** — A car flying by without `DOPPLER_TRACKING_PHYSICS_STEP` feels flat and static.

### Performance & Polish
- **NEVER spam same-frame sounds** — Playing 50 explosions at once causes constructive interference (clipping/distortion). Use a `Limiter` (`audio_voice_limiter_manager.gd`).
- **NEVER instantiate nodes for one-shots** — Creating a node, playing a 0.5s clap, and `queue_free()`ing causes frame-time spikes. Use a Pool.
- **NEVER skip Crossfades/Transitions** — Abrupt music cuts break immersion. Always use a 0.5s-1.0s `Tween` to bridge tracks.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [audio_voice_pool_manager.gd](scripts/audio_voice_pool_manager.gd)
Expert high-performance voice pooler with priority-based 'voice stealing' logic.

### [audio_occlusion_raycast.gd](scripts/audio_occlusion_raycast.gd)
Professional Raycast-based audio occlusion for dynamic muffling behind walls.

### [audio_adaptive_music_player.gd](scripts/audio_adaptive_music_player.gd)
BPM-synced horizontal re-sequencer for seamless musical transitions.

### [audio_reactive_visualizer_component.gd](scripts/audio_reactive_visualizer_component.gd)
Expert FFT spectrum analysis component for driving logic-to-data visuals.

### [audio_bus_ducker_logic.gd](scripts/audio_bus_ducker_logic.gd)
Professional sidechain-style bus ducking (Dialogue-over-Music).

### [audio_procedural_generator_synth.gd](scripts/audio_procedural_generator_synth.gd)
Expert real-time synthesizer for procedural hums, engines, and signals.

### [audio_environmental_reverb_zone.gd](scripts/audio_environmental_reverb_zone.gd)
Dynamic reverb/bus effect management via Area3D trigger zones.

### [audio_voice_limiter_manager.gd](scripts/audio_voice_limiter_manager.gd)
Concurrency manager that prevents 'Ear Bleed' by capping identical SFX instances.

### [audio_linear_volume_interpolator.gd](scripts/audio_linear_volume_interpolator.gd)
Expert helper for smooth, musically-accurate UI volume slider mapping.

### [audio_footstep_surface_selector.gd](scripts/audio_footstep_surface_selector.gd)
Physics-driven surface detection and sound-bank selector for footsteps.

---

## AudioStreamPlayer Variants

### AudioStreamPlayer (Global/UI)

```gdscript
# No spatial positioning, same volume everywhere
# Use for: Music, UI sounds, voiceovers

@onready var music := AudioStreamPlayer.new()

func _ready() -> void:
    music.stream = load("res://audio/music_main.ogg")
    music.volume_db = -10  # Quieter
    music.autoplay = false
    music.bus = "Music"  # Route to Music bus
    add_child(music)
    music.play()
```

### AudioStreamPlayer2D (Positional)

```gdscript
# 2D panning based on distance from camera
# Use for: 2D games, top-down audio cues

extends Area2D

@onready var footstep := AudioStreamPlayer2D.new()

func _ready() -> void:
    footstep.stream = load("res://audio/footstep.ogg")
    footstep.max_distance = 500  # Audible range (pixels)
    footstep.attenuation = 2.0  # Falloff curve (higher = faster fadeout)
    add_child(footstep)

func play_footstep() -> void:
    if not footstep.playing:
        footstep.play()
```

### AudioStreamPlayer3D (Spatial)

```gdscript
# 3D spatial audio with doppler, reverb send
# Use for: 3D games, realistic sound positioning

extends Node3D

@onready var explosion := AudioStreamPlayer3D.new()

func _ready() -> void:
    explosion.stream = load("res://audio/explosion.ogg")
    explosion.unit_size = 10.0  # Size of sound source
    explosion.max_distance = 100.0  # Range
    explosion.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
    explosion.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
    add_child(explosion)
    
    explosion.play()
```

---

## AudioBus Architecture

### Bus Setup (Project Settings)

```
Master (always exists)
  ├─ Music
  │   └─ Effects: Compressor, EQ
  ├─ SFX
  │   └─ Effects: Reverb (for environment)
  └─ Ambient
      └─ Effects: LowPassFilter (muffled ambience)
```

### Volume Control (Decibels)

```gdscript
# ❌ BAD: Linear volume (doesn't work)
AudioServer.set_bus_volume_db(music_bus_idx, 0.5)  # WRONG!

# ✅ GOOD: Use decibels
var music_bus := AudioServer.get_bus_index("Music")
AudioServer.set_bus_volume_db(music_bus, -10)  # -10 dB (quieter)

# Convert linear (0.0-1.0) to dB:
var linear_volume := 0.5  # 50%
var db := linear_to_db(linear_volume)  # ~-6 dB
AudioServer.set_bus_volume_db(music_bus, db)

# Convert dB to linear:
var current_db := AudioServer.get_bus_volume_db(music_bus)
var linear := db_to_linear(current_db)
print("Current volume: %d%%" % int(linear * 100))
```

### Mute Bus

```gdscript
func toggle_mute(bus_name: String) -> void:
    var bus_idx := AudioServer.get_bus_index(bus_name)
    var is_muted := AudioServer.is_bus_mute(bus_idx)
    AudioServer.set_bus_mute(bus_idx, not is_muted)
```

---

## Audio Pooling (Performance)

### Problem: Creating Players Every Frame

```gdscript
# ❌ BAD: Creates 60 new nodes/second at 60 FPS
func play_footstep() -> void:
    var player := AudioStreamPlayer.new()
    add_child(player)
    player.stream = load("res://audio/footstep.ogg")
    player.finished.connect(player.queue_free)
    player.play()
    # Result: 3600 nodes created in 1 minute!
```

### Solution: Audio Pool

```gdscript
# audio_pool.gd (AutoLoad)
extends Node

const POOL_SIZE = 10
var pool: Array[AudioStreamPlayer] = []
var pool_index := 0

func _ready() -> void:
    # Pre-create players
    for i in range(POOL_SIZE):
        var player := AudioStreamPlayer.new()
        player.bus = "SFX"
        add_child(player)
        pool.append(player)

func play_sound(stream: AudioStream, volume_db := 0.0) -> void:
    var player := pool[pool_index]
    pool_index = (pool_index + 1) % POOL_SIZE  # Round-robin
    
    # Stop previous sound if still playing
    if player.playing:
        player.stop()
    
    player.stream = stream
    player.volume_db = volume_db
    player.play()

# Usage:
AudioPool.play_sound(load("res://audio/coin.ogg"), -5.0)
```

---

## Music Transitions

### Crossfade Between Tracks

```gdscript
# music_manager.gd (AutoLoad)
extends Node

@onready var track_a := AudioStreamPlayer.new()
@onready var track_b := AudioStreamPlayer.new()

var current_track: AudioStreamPlayer
var fade_duration := 2.0

func _ready() -> void:
    track_a.bus = "Music"
    track_b.bus = "Music"
    add_child(track_a)
    add_child(track_b)
    current_track = track_a

func crossfade_to(new_stream: AudioStream) -> void:
    var next_track := track_b if current_track == track_a else track_a
    
    # Start new track at 0 dB
    next_track.stream = new_stream
    next_track.volume_db = -80  # Silent
    next_track.play()
    
    # Fade out current, fade in next
    var tween := create_tween().set_parallel(true)
    tween.tween_property(current_track, "volume_db", -80, fade_duration)
    tween.tween_property(next_track, "volume_db", 0, fade_duration)
    
    await tween.finished
    
    # Stop old track
    current_track.stop()
    current_track = next_track
```

### BPM-Synced Transitions

```gdscript
# Transition on beat boundary
var bpm := 120.0  # Beats per minute
var beat_duration := 60.0 / bpm  # 0.5s per beat

func queue_transition_on_beat(new_stream: AudioStream) -> void:
    # Wait for next beat
    var current_time := current_track.get_playback_position()
    var time_to_next_beat := beat_duration - fmod(current_time, beat_duration)
    
    await get_tree().create_timer(time_to_next_beat).timeout
    crossfade_to(new_stream)
```

---

## Dynamic Audio Effects

### Add Effect at Runtime

```gdscript
# Add reverb to SFX bus
var sfx_bus := AudioServer.get_bus_index("SFX")
var reverb := AudioEffectReverb.new()
reverb.room_size = 0.8  # Large room
reverb.damping = 0.5
reverb.wet = 0.3  # 30% effect, 70% dry
AudioServer.add_bus_effect(sfx_bus, reverb)
```

### Underwater Effect

```gdscript
func set_underwater(enabled: bool) -> void:
    var sfx_bus := AudioServer.get_bus_index("SFX")
    
    if enabled:
        # Add low-pass filter (muffled sound)
        var lowpass := AudioEffectLowPassFilter.new()
        lowpass.cutoff_hz = 500  # Cut frequencies above 500 Hz
        AudioServer.add_bus_effect(sfx_bus, lowpass)
    else:
        # Remove all effects
        for i in range(AudioServer.get_bus_effect_count(sfx_bus)):
            AudioServer.remove_bus_effect(sfx_bus, 0)
```

---

## Procedural Audio

### Synthesize Beep

```gdscript
# Generate simple sine wave
func create_beep(frequency: float, duration: float) -> AudioStreamGenerator:
    var stream := AudioStreamGenerator.new()
    stream.mix_rate = 44100  # Sample rate
    
    var playback := stream.instantiate_playback()
    
    var increment := frequency / stream.mix_rate
    var phase := 0.0
    
    for i in range(int(stream.mix_rate * duration)):
        var sample := sin(phase * TAU)
        playback.push_frame(Vector2(sample, sample))  # Stereo
        phase += increment
        phase = fmod(phase, 1.0)
    
    return stream

# Usage:
var beep_stream := create_beep(440.0, 0.1)  # 440 Hz (A4), 0.1s
$AudioStreamPlayer.stream = beep_stream
$AudioStreamPlayer.play()
```

---

## Advanced Patterns

### Audio Ducking (Lower Music During Dialogue)

```gdscript
# auto_duck.gd (on Dialogue AudioStreamPlayer)
extends AudioStreamPlayer

func _ready() -> void:
    playing.connect(_on_playing)
    finished.connect(_on_finished)

func _on_playing() -> void:
    # Duck music to -15 dB
    var music_bus := AudioServer.get_bus_index("Music")
    var tween := create_tween()
    tween.tween_method(set_music_volume, 0.0, -15.0, 0.5)

func _on_finished() -> void:
    # Restore music to 0 dB
    var tween := create_tween()
    tween.tween_method(set_music_volume, -15.0, 0.0, 0.5)

func set_music_volume(db: float) -> void:
    var music_bus := AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(music_bus, db)
```

### Randomize Pitch for Variation

```gdscript
# Prevent identical sounds (footsteps, gunshots)
func play_varied_sound(stream: AudioStream) -> void:
    $AudioStreamPlayer.stream = stream
    $AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.1)  # ±10% pitch
    $AudioStreamPlayer.play()
```

### Layered Music (Adaptive)

```gdscript
# Intensity-based music layers (start quiet, add layers as intensity increases)
# Example: Peaceful exploration → Combat

@onready var layer_drums := $Music/Drums
@onready var layer_bass := $Music/Bass
@onready var layer_melody := $Music/Melody

var intensity := 0.0  # 0.0 = calm, 1.0 = intense

func _ready() -> void:
    # Start all layers in sync
    layer_drums.play()
    layer_bass.play()
    layer_melody.play()
    
    # Mute high-intensity layers
    layer_bass.volume_db = -80
    layer_melody.volume_db = -80

func set_music_intensity(new_intensity: float) -> void:
    intensity = clamp(new_intensity, 0.0, 1.0)
    
    # Fade in layers based on intensity
    var tween := create_tween().set_parallel(true)
    
    # Layer 1 (drums): always audible
    tween.tween_property(layer_drums, "volume_db", 0, 1.0)
    
    # Layer 2 (bass): fade in at 33% intensity
    var bass_db := -80 if intensity < 0.33 else lerp(-80.0, 0.0, (intensity - 0.33) / 0.67)
    tween.tween_property(layer_bass, "volume_db", bass_db, 1.0)
    
    # Layer 3 (melody): fade in at 66% intensity
    var melody_db := -80 if intensity < 0.66 else lerp(-80.0, 0.0, (intensity - 0.66) / 0.34)
    tween.tween_property(layer_melody, "volume_db", melody_db, 1.0)

# Usage (combat system):
func _on_enemy_spotted() -> void:
    MusicManager.set_music_intensity(1.0)  # Full intensity

func _on_all_enemies_defeated() -> void:
    MusicManager.set_music_intensity(0.0)  # Back to calm
```

---

## Performance Optimization

### Disable Far Audio

```gdscript
# Don't play sounds the player can't hear
extends AudioStreamPlayer3D

func _process(delta: float) -> void:
    var listener := get_viewport().get_camera_3d()
    if not listener:
        return
    
    var distance := global_position.distance_to(listener.global_position)
    
    if distance > max_distance * 1.5:  # 1.5x max range
        if playing:
            stop()
```

---

## Edge Cases

### Audio Doesn't Play

```gdscript
# Check:
# 1. Is stream assigned?
if not $AudioStreamPlayer.stream:
    push_error("No audio stream assigned!")

# 2. Is bus muted?
var bus_idx := AudioServer.get_bus_index($AudioStreamPlayer.bus)
if AudioServer.is_bus_mute(bus_idx):
    print("Bus is muted!")

# 3. Is volume too low?
if $AudioStreamPlayer.volume_db < -60:
    print("Volume too quiet (< -60 dB)")
```

---

## Decision Matrix: Which AudioStreamPlayer?

| Feature | AudioStreamPlayer | AudioStreamPlayer2D | AudioStreamPlayer3D |
|---------|------------------|---------------------|---------------------|
| **Spatial** | ❌ Global | ✅ 2D panning | ✅ 3D positioning |
| **Doppler** | ❌ | ❌ | ✅ |
| **Attenuation** | ❌ | ✅ Distance-based | ✅ 3D falloff |
| **Reverb send** | ❌ | ❌ | ✅ |
| **Use for** | Music, UI | 2D games | 3D games |
| **Performance** | Fastest | Medium | Slowest |


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
