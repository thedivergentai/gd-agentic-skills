---
name: godot-animation-player
description: "Expert patterns for AnimationPlayer including track types (Value, Method, Audio, Bezier), root motion extraction, animation callbacks, procedural animation generation, call mode optimization, and RESET tracks. Use for timeline-based animations, cutscenes, or UI transitions. Trigger keywords: AnimationPlayer, Animation, track_insert_key, root_motion, animation_finished, RESET_track, call_mode, animation_set_next, queue, blend_times."
---

# AnimationPlayer

Expert guidance for Godot's timeline-based keyframe animation system.

## NEVER Do

- **NEVER forget RESET tracks** — Without a RESET track, animated properties don't restore to initial values when changing scenes. Create RESET animation with all default states.
- **NEVER use Animation.CALL_MODE_CONTINUOUS for function calls** — Calls method EVERY frame during keyframe. Use CALL_MODE_DISCRETE (calls once). Continuous causes spam.
- **NEVER animate resource properties directly** — Animating `material.albedo_color` creates embedded resources, bloating file size. Store material in variable, animate variable's properties.
- **NEVER use animation_finished for looping animations** — Signal doesn't fire for looped animations. Use `animation_looped` or check `current_animation` in _process().
- **NEVER hardcode animation names as strings everywhere** — Use constants or enums. Typos cause silent failures.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [audio_sync_tracks.gd](scripts/audio_sync_tracks.gd)
Sub-frame audio synchronization via Animation.TYPE_AUDIO tracks. Footstep setup with automatic blend handling for cross-fades.

### [programmatic_anim.gd](scripts/programmatic_anim.gd)
Procedural animation generation: creates Animation resources via code with keyframes, easing, and transition curves for dynamic runtime animations.

---

## Track Types Deep Dive

### Value Tracks (Property Animation)

```gdscript
# Animate ANY property: position, color, volume, custom variables
var anim := Animation.new()
anim.length = 2.0

# Position track
var pos_track := anim.add_track(Animation.TYPE_VALUE)
anim.track_set_path(pos_track, ".:position")
anim.track_insert_key(pos_track, 0.0, Vector2(0, 0))
anim.track_insert_key(pos_track, 1.0, Vector2(100, 0))
anim.track_set_interpolation_type(pos_track, Animation.INTERPOLATION_CUBIC)

# Color track (modulate)
var color_track := anim.add_track(Animation.TYPE_VALUE)
anim.track_set_path(color_track, "Sprite2D:modulate")
anim.track_insert_key(color_track, 0.0, Color.WHITE)
anim.track_insert_key(color_track, 2.0, Color.TRANSPARENT)

$AnimationPlayer.add_animation("fade_move", anim)
$AnimationPlayer.play("fade_move")
```

### Method Tracks (Function Calls)

```gdscript
# Call functions at specific timestamps
var method_track := anim.add_track(Animation.TYPE_METHOD)
anim.track_set_path(method_track, ".")  # Path to node

# Insert method calls
anim.track_insert_key(method_track, 0.5, {
    "method": "spawn_particle",
    "args": [Vector2(50, 50)]
})

anim.track_insert_key(method_track, 1.5, {
    "method": "play_sound",
    "args": ["res://sounds/explosion.ogg"]
})

# CRITICAL: Set call mode to DISCRETE
anim.track_set_call_mode(method_track, Animation.CALL_MODE_DISCRETE)

# Methods must exist on target node:
func spawn_particle(pos: Vector2) -> void:
    # Spawn particle at position
    pass

func play_sound(sound_path: String) -> void:
    $AudioStreamPlayer.stream = load(sound_path)
    $AudioStreamPlayer.play()
```

### Audio Tracks

```gdscript
# Synchronize audio with animation
var audio_track := anim.add_track(Animation.TYPE_AUDIO)
anim.track_set_path(audio_track, "AudioStreamPlayer")

# Insert audio playback
var audio_stream := load("res://sounds/footstep.ogg")
anim.audio_track_insert_key(audio_track, 0.3, audio_stream)
anim.audio_track_insert_key(audio_track, 0.6, audio_stream)  # Second footstep

# Set volume for specific key
anim.audio_track_set_key_volume(audio_track, 0, 1.0)  # Full volume
anim.audio_track_set_key_volume(audio_track, 1, 0.7)  # Quieter
```

### Bezier Tracks (Custom Curves)

```gdscript
# For smooth, custom interpolation curves
var bezier_track := anim.add_track(Animation.TYPE_BEZIER)
anim.track_set_path(bezier_track, ".:custom_value")

# Insert bezier points with handles
anim.bezier_track_insert_key(bezier_track, 0.0, 0.0)
anim.bezier_track_insert_key(bezier_track, 1.0, 100.0,
    Vector2(0.5, 0),    # In-handle
    Vector2(-0.5, 0))   # Out-handle

# Read value in _process
func _process(delta: float) -> void:
    var value := $AnimationPlayer.get_bezier_value("custom_value")
    # Use value for custom effects
```

---

## Root Motion Extraction

### Problem: Animated Movement Disconnected from Physics

```gdscript
# Character walks in animation, but position doesn't change in world
# Animation modifies Skeleton bone, not CharacterBody3D root
```

### Solution: Root Motion

```gdscript
# Scene structure:
# CharacterBody3D (root)
#   ├─ MeshInstance3D
#   │   └─ Skeleton3D
#   └─ AnimationPlayer

# AnimationPlayer setup:
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    # Enable root motion (point to root bone)
    anim_player.root_motion_track = NodePath("MeshInstance3D/Skeleton3D:root")
    anim_player.play("walk")

func _physics_process(delta: float) -> void:
    # Extract root motion
    var root_motion_pos := anim_player.get_root_motion_position()
    var root_motion_rot := anim_player.get_root_motion_rotation()
    var root_motion_scale := anim_player.get_root_motion_scale()
    
    # Apply to CharacterBody3D
    var transform := Transform3D(basis.rotated(basis.y, root_motion_rot.y), Vector3.ZERO)
    transform.origin = root_motion_pos
    global_transform *= transform
    
    # Velocity from root motion
    velocity = root_motion_pos / delta
    move_and_slide()
```

---

## Animation Sequences & Queueing

### Chaining Animations

```gdscript
# Play animations in sequence
@onready var anim: AnimationPlayer = $AnimationPlayer

func play_attack_combo() -> void:
    anim.play("attack_1")
    await anim.animation_finished
    anim.play("attack_2")
    await anim.animation_finished
    anim.play("idle")

# Or use queue:
func play_with_queue() -> void:
    anim.play("attack_1")
    anim.queue("attack_2")
    anim.queue("idle")  # Auto-plays after attack_2
```

### Blend Times

```gdscript
# Smooth transitions between animations
anim.play("walk")

# 0.5s blend from walk → run
anim.play("run", -1, 1.0, 0.5)  # custom_blend = 0.5

# Or set default blend
anim.set_default_blend_time(0.3)  # 0.3s for all transitions
anim.play("idle")
```

---

## RESET Track Pattern

### Problem: Properties Don't Reset

```gdscript
# Animate sprite position from (0,0) → (100, 0)
# Change scene, sprite stays at (100, 0)!
```

### Solution: RESET Animation

```gdscript
# Create RESET animation with default values
var reset_anim := Animation.new()
reset_anim.length = 0.01  # Very short

var track := reset_anim.add_track(Animation.TYPE_VALUE)
reset_anim.track_set_path(track, "Sprite2D:position")
reset_anim.track_insert_key(track, 0.0, Vector2(0, 0))  # Default position

track = reset_anim.add_track(Animation.TYPE_VALUE)
reset_anim.track_set_path(track, "Sprite2D:modulate")
reset_anim.track_insert_key(track, 0.0, Color.WHITE)  # Default color

anim_player.add_animation("RESET", reset_anim)

# AnimationPlayer automatically plays RESET when scene loads
# IF "Reset on Save" is enabled in AnimationPlayer settings
```

---

## Procedural Animation Generation

### Generate Animation from Code

```gdscript
# Create bounce animation programmatically
func create_bounce_animation() -> void:
    var anim := Animation.new()
    anim.length = 1.0
    anim.loop_mode = Animation.LOOP_LINEAR
    
    # Position track (Y bounce)
    var track := anim.add_track(Animation.TYPE_VALUE)
    anim.track_set_path(track, ".:position:y")
    
    # Generate sine wave keyframes
    for i in range(10):
        var time := float(i) / 9.0  # 0.0 to 1.0
        var value := sin(time * TAU) * 50.0  # Bounce height 50px
        anim.track_insert_key(track, time, value)
    
    anim.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)
    $AnimationPlayer.add_animation("bounce", anim)
    $AnimationPlayer.play("bounce")
```

---

## Advanced Patterns

### Play Animation Backwards

```gdscript
# Play animation in reverse (useful for closing doors, etc.)
anim.play("door_open", -1, -1.0)  # speed = -1.0 = reverse

# Pause and reverse
anim.pause()
anim.play("current_animation", -1, -1.0, false)  # from_end = false
```

### Animation Callbacks (Signal-Based)

```gdscript
# Emit custom signal at specific frame
func _ready() -> void:
    $AnimationPlayer.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(anim_name: String) -> void:
    match anim_name:
        "attack":
            deal_damage()
        "die":
            queue_free()
```

### Seek to Specific Time

```gdscript
# Jump to 50% through animation
anim.seek(anim.current_animation_length * 0.5)

# Scrub through animation (cutscene editor)
func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and scrubbing:
        var normalized_pos := event.position.x / get_viewport_rect().size.x
        anim.seek(anim.current_animation_length * normalized_pos)
```

---

## Performance Optimization

### Disable When Off-Screen

```gdscript
extends VisibleOnScreenNotifier2D

func _ready() -> void:
    screen_exited.connect(_on_screen_exited)
    screen_entered.connect(_on_screen_entered)

func _on_screen_exited() -> void:
    $AnimationPlayer.pause()

func _on_screen_entered() -> void:
    $AnimationPlayer.play()
```

---

## Edge Cases

### Animation Not Playing

```gdscript
# Problem: Forgot to add animation to player
# Solution: Check if animation exists
if anim.has_animation("walk"):
    anim.play("walk")
else:
    push_error("Animation 'walk' not found!")

# Better: Use constants
const ANIM_WALK = "walk"
const ANIM_IDLE = "idle"

if anim.has_animation(ANIM_WALK):
    anim.play(ANIM_WALK)
```

### Method Track Not Firing

```gdscript
# Problem: Call mode is CONTINUOUS
# Solution: Set to DISCRETE
var method_track_idx := anim.find_track(".:method_name", Animation.TYPE_METHOD)
anim.track_set_call_mode(method_track_idx, Animation.CALL_MODE_DISCRETE)
```

---

## Decision Matrix: AnimationPlayer vs Tween

| Feature | AnimationPlayer | Tween |
|---------|-----------------|-------|
| **Timeline editing** | ✅ Visual editor | ❌ Code only |
| **Multiple properties** | ✅ Many tracks | ❌ One property |
| **Reusable** | ✅ Save as resource | ❌ Create each time |
| **Dynamic runtime** | ❌ Static | ✅ Fully dynamic |
| **Method calls** | ✅ Method tracks | ❌ Use callbacks |
| **Performance** | ✅ Optimized | ❌ Slightly slower |

**Use AnimationPlayer for**: Cutscenes, character animations, complex UI
**Use Tween for**: Simple runtime effects, one-off transitions


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
