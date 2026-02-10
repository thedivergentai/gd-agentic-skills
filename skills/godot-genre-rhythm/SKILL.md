---
name: godot-genre-rhythm
description: "Expert blueprint for rhythm games including audio synchronization (BPM conductor, latency compensation with AudioServer.get_time_since_last_mix), note highways (scroll speed, timing windows), judgment systems (Perfect/Great/Good/Bad/Miss), scoring with combo multipliers, input processing (lane-based, hold note detection), and chart/beatmap loading. Based on DDR/osu!/Beat Saber research. Trigger keywords: rhythm_game, audio_sync, timing_judgment, note_highway, combo_system, BPM_conductor, latency_compensation."
---

# Genre: Rhythm

Expert blueprint for rhythm games emphasizing audio-visual synchronization and flow state.

## NEVER Do

- **NEVER skip latency compensation** — Use `AudioServer.get_time_since_last_mix()` to sync visuals with audio. Missing this causes desync.
- **NEVER use `_process` for input** — Use `_input()` for precise timing. Frame-dependent input causes missed notes.
- **NEVER forget offset calibration** — Audio hardware latency varies (10-200ms). Provide player-adjustable offset setting.
- **NEVER tight timing windows on low difficulty** — Perfect: 25ms, Great: 50ms is for experts. Beginners need 100-150ms windows.
- **NEVER decouple input from audio** — Input timing must reference MusicConductor.song_position, not frame time. Framerate drops shouldn't cause misses.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [conductor_sync.gd](scripts/conductor_sync.gd)
BPM conductor with AudioServer latency compensation. Emits beat_hit/measure_hit signals for audio-synced game logic.

### [rhythm_chart_parser.gd](scripts/rhythm_chart_parser.gd)
JSON chart loader with time-sorted notes. Provides optimized get_notes_in_range() for efficient note querying in highways.

---

## Core Loop

`Music Plays → Notes Appear → Player Inputs → Timing Judged → Score/Feedback → Combo Builds`

## Skill Chain

`godot-project-foundations`, `godot-input-handling`, `sound-manager`, `animation`, `ui-framework`

---

## Audio Synchronization

**THE most critical aspect** - notes MUST align perfectly with audio.

### Music Time System

```gdscript
class_name MusicConductor
extends Node

signal beat(beat_number: int)
signal measure(measure_number: int)

@export var bpm := 120.0
@export var music: AudioStream

var seconds_per_beat: float
var song_position: float = 0.0  # In seconds
var song_position_in_beats: float = 0.0
var last_reported_beat: int = 0

@onready var audio_player: AudioStreamPlayer

func _ready() -> void:
    seconds_per_beat = 60.0 / bpm
    audio_player.stream = music

func _process(_delta: float) -> void:
    # Get precise audio position with latency compensation
    song_position = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()
    
    # Convert to beats
    song_position_in_beats = song_position / seconds_per_beat
    
    # Emit beat signals
    var current_beat := int(song_position_in_beats)
    if current_beat > last_reported_beat:
        beat.emit(current_beat)
        if current_beat % 4 == 0:
            measure.emit(current_beat / 4)
        last_reported_beat = current_beat

func start_song() -> void:
    audio_player.play()
    song_position = 0.0
    last_reported_beat = 0

func beats_to_seconds(beats: float) -> float:
    return beats * seconds_per_beat

func seconds_to_beats(secs: float) -> float:
    return secs / seconds_per_beat
```

---

## Note System

### Note Data Structure

```gdscript
class_name NoteData
extends Resource

@export var beat_time: float  # When to hit (in beats)
@export var lane: int  # Which input lane (0-3 for 4-key, etc.)
@export var note_type: NoteType
@export var hold_duration: float = 0.0  # For hold notes (in beats)

enum NoteType { TAP, HOLD, SLIDE, FLICK }
```

### Chart/Beatmap Loading

```gdscript
class_name ChartLoader
extends Node

func load_chart(chart_path: String) -> Array[NoteData]:
    var notes: Array[NoteData] = []
    var file := FileAccess.open(chart_path, FileAccess.READ)
    
    while not file.eof_reached():
        var line := file.get_line()
        if line.is_empty() or line.begins_with("#"):
            continue
        
        var parts := line.split(",")
        var note := NoteData.new()
        note.beat_time = float(parts[0])
        note.lane = int(parts[1])
        note.note_type = NoteType.get(parts[2]) if parts.size() > 2 else NoteType.TAP
        note.hold_duration = float(parts[3]) if parts.size() > 3 else 0.0
        notes.append(note)
    
    notes.sort_custom(func(a, b): return a.beat_time < b.beat_time)
    return notes
```

---

## Note Highway / Receptor

```gdscript
class_name NoteHighway
extends Control

@export var scroll_speed := 500.0  # Pixels per second
@export var hit_position_y := 100.0  # From bottom
@export var note_scene: PackedScene
@export var look_ahead_beats := 4.0

var active_notes: Array[NoteVisual] = []
var chart: Array[NoteData]
var next_note_index: int = 0

func _process(_delta: float) -> void:
    spawn_upcoming_notes()
    update_note_positions()

func spawn_upcoming_notes() -> void:
    var look_ahead_time := MusicConductor.song_position_in_beats + look_ahead_beats
    
    while next_note_index < chart.size():
        var note_data := chart[next_note_index]
        if note_data.beat_time > look_ahead_time:
            break
        
        var note_visual := note_scene.instantiate() as NoteVisual
        note_visual.setup(note_data)
        note_visual.position.x = get_lane_x(note_data.lane)
        add_child(note_visual)
        active_notes.append(note_visual)
        next_note_index += 1

func update_note_positions() -> void:
    for note in active_notes:
        var beats_until_hit := note.data.beat_time - MusicConductor.song_position_in_beats
        var seconds_until_hit := MusicConductor.beats_to_seconds(beats_until_hit)
        
        # Note scrolls down from top
        note.position.y = (size.y - hit_position_y) - (seconds_until_hit * scroll_speed)
        
        # Remove if too far past
        if note.position.y > size.y + 100:
            if not note.was_hit:
                register_miss(note.data)
            note.queue_free()
            active_notes.erase(note)
```

---

## Timing Judgment

```gdscript
class_name JudgmentSystem
extends Node

signal note_judged(judgment: Judgment, note: NoteData)

enum Judgment { PERFECT, GREAT, GOOD, BAD, MISS }

# Timing windows in milliseconds (symmetric around hit time)
const WINDOWS := {
    Judgment.PERFECT: 25.0,
    Judgment.GREAT: 50.0,
    Judgment.GOOD: 100.0,
    Judgment.BAD: 150.0
}

func judge_input(input_time: float, note_time: float) -> Judgment:
    var difference := abs(input_time - note_time) * 1000.0  # ms
    
    if difference <= WINDOWS[Judgment.PERFECT]:
        return Judgment.PERFECT
    elif difference <= WINDOWS[Judgment.GREAT]:
        return Judgment.GREAT
    elif difference <= WINDOWS[Judgment.GOOD]:
        return Judgment.GOOD
    elif difference <= WINDOWS[Judgment.BAD]:
        return Judgment.BAD
    else:
        return Judgment.MISS

func get_timing_offset(input_time: float, note_time: float) -> float:
    # Positive = late, Negative = early
    return (input_time - note_time) * 1000.0
```

---

## Scoring System

```gdscript
class_name RhythmScoring
extends Node

signal score_changed(new_score: int)
signal combo_changed(new_combo: int)
signal combo_broken

const JUDGMENT_SCORES := {
    Judgment.PERFECT: 100,
    Judgment.GREAT: 75,
    Judgment.GOOD: 50,
    Judgment.BAD: 25,
    Judgment.MISS: 0
}

const COMBO_MULTIPLIER_THRESHOLDS := {
    10: 1.5,
    25: 2.0,
    50: 2.5,
    100: 3.0
}

var score: int = 0
var combo: int = 0
var max_combo: int = 0

func register_judgment(judgment: Judgment) -> void:
    if judgment == Judgment.MISS:
        if combo > 0:
            combo_broken.emit()
        combo = 0
    else:
        combo += 1
        max_combo = max(max_combo, combo)
    
    var base_score := JUDGMENT_SCORES[judgment]
    var multiplier := get_combo_multiplier()
    var earned := int(base_score * multiplier)
    
    score += earned
    score_changed.emit(score)
    combo_changed.emit(combo)

func get_combo_multiplier() -> float:
    var mult := 1.0
    for threshold in COMBO_MULTIPLIER_THRESHOLDS:
        if combo >= threshold:
            mult = COMBO_MULTIPLIER_THRESHOLDS[threshold]
    return mult
```

---

## Input Processing

```gdscript
class_name RhythmInput
extends Node

@export var lane_actions: Array[StringName] = [
    &"lane_0", &"lane_1", &"lane_2", &"lane_3"
]

var held_notes: Dictionary = {}  # lane: NoteData for hold notes

func _input(event: InputEvent) -> void:
    for i in lane_actions.size():
        if event.is_action_pressed(lane_actions[i]):
            process_lane_press(i)
        elif event.is_action_released(lane_actions[i]):
            process_lane_release(i)

func process_lane_press(lane: int) -> void:
    var current_time := MusicConductor.song_position
    var closest_note := find_closest_note_in_lane(lane, current_time)
    
    if closest_note:
        var note_time := MusicConductor.beats_to_seconds(closest_note.beat_time)
        var judgment := JudgmentSystem.judge_input(current_time, note_time)
        
        if judgment != Judgment.MISS:
            hit_note(closest_note, judgment)
            if closest_note.note_type == NoteType.HOLD:
                held_notes[lane] = closest_note

func process_lane_release(lane: int) -> void:
    if held_notes.has(lane):
        var hold_note := held_notes[lane]
        var hold_end_time := hold_note.beat_time + hold_note.hold_duration
        var current_beat := MusicConductor.song_position_in_beats
        
        # Check if released at correct time
        if abs(current_beat - hold_end_time) < 0.25:  # Quarter beat tolerance
            complete_hold_note(hold_note)
        else:
            drop_hold_note(hold_note)
        
        held_notes.erase(lane)
```

---

## Visual Feedback

```gdscript
func show_judgment_splash(judgment: Judgment, position: Vector2) -> void:
    var splash := judgment_sprites[judgment].instantiate()
    splash.position = position
    add_child(splash)
    
    var tween := create_tween()
    tween.tween_property(splash, "scale", Vector2(1.2, 1.2), 0.1)
    tween.tween_property(splash, "scale", Vector2(1.0, 1.0), 0.1)
    tween.tween_property(splash, "modulate:a", 0.0, 0.3)
    tween.tween_callback(splash.queue_free)

func pulse_receptor(lane: int, judgment: Judgment) -> void:
    var receptor := lane_receptors[lane]
    receptor.modulate = judgment_colors[judgment]
    
    var tween := create_tween()
    tween.tween_property(receptor, "modulate", Color.WHITE, 0.15)
```

---

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Audio desync | Use `AudioServer.get_time_since_last_mix()` latency compensation |
| Unfair judgment | Generous windows at low difficulty, offset calibration |
| Notes bunched visually | Adjust scroll speed or spawn timing |
| Hold notes janky | Separate hold body and tail rendering |
| Frame drops cause misses | Decouple input from framerate |

---

## Godot-Specific Tips

1. **Audio latency**: Calibrate with `AudioServer` and custom offset
2. **Input polling**: Use `_input` not `_process` for precise timing
3. **Shaders**: UV scrolling for note highways
4. **Particles**: Use `GPUParticles2D` for hit effects


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
