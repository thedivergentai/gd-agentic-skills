---
name: godot-genre-stealth
description: "Expert blueprint for stealth games (Splinter Cell, Hitman, Dishonored, Thief) covering AI detection systems, vision cones, sound propagation, alert states, light/shadow mechanics, and systemic design. Use when building stealth-action, tactical infiltration, or immersive sim games requiring enemy awareness systems. Keywords vision cone, detection, alert state, sound propagation, light level, systemic AI, gradual detection."
---

# Genre: Stealth

Player choice, systemic AI, and clear communication define stealth games.

## Available Scripts

### [stealth_ai_controller.gd](scripts/stealth_ai_controller.gd)
Expert AI controller with graduated detection, sound response, and alert state management.

## Core Loop

`Observe → Plan → Execute → Adapt → Complete`

## NEVER Do in Stealth Games

- **NEVER use instant binary detection** — Gradual 0-100% detection with visual feedback (filling meter). Binary "seen/not seen" removes player agency and feels unfair.
- **NEVER make guards see through walls** — Raycast-based vision with collision masks. `has_line_of_sight()` must check geometry. Wallhacks destroy stealth integrity.
- **NEVER use simple distance checks for sound** — Sound propagates along `NavigationServer3D` paths, NOT straight-line distance. Through-wall hearing breaks immersion.
-**NEVER make combat as viable as stealth** — If guns are easier than sneaking, players ignore stealth. Combat should be risky (outnumbered, limited ammo, loud alerts).
- **NEVER hide detection reasons from player** — Show WHY detected (light level high, made noise, in vision cone). "Gotcha" deaths frustrate, don't teach.
- **NEVER use single sample point for player visibility** — Sample multiple body parts (head, torso, feet). Hiding behind low cover should hide torso but expose head.
- **NEVER forget peripheral vision** — Humans have ~180° peripheral (less effective) + 60° focused vision. Single cone = unrealistic. Use composite shapes (Splinter Cell method).

---

## Design Principles

From industry experts (Splinter Cell, Dishonored, Hitman developers):

1. **Player Choice**: Multiple valid approaches to every scenario
2. **Systemic Design**: Rules-based AI that players can learn and exploit
3. **Clear Communication**: Player always understands game state and threats
4. **Fair Detection**: No "gotcha" moments - threats visible before dangerous

---

## AI Detection System

### Vision Cone Implementation

Based on Splinter Cell Blacklist GDC talk - realistic vision uses **composite shapes**:

```gdscript
class_name EnemyVision
extends Node3D

@export var forward_vision_range := 20.0    # Main vision cone
@export var peripheral_range := 10.0        # Side vision
@export var forward_fov := 60.0             # Degrees
@export var peripheral_fov := 120.0          # Degrees
@export var detection_speed := 1.0          # How fast detection builds

var detection_level := 0.0  # 0-100
var target: Node3D = null

func _physics_process(delta: float) -> void:
    var player := get_player_if_visible()
    if player:
        # Detection rate varies by:
        # - Distance (closer = faster)
        # - Lighting on player
        # - Player movement (moving = more visible)
        # - In peripheral vs direct vision
        var rate := calculate_detection_rate(player)
        detection_level = min(100, detection_level + rate * delta)
    else:
        detection_level = max(0, detection_level - detection_speed * 0.5 * delta)

func get_player_if_visible() -> Player:
    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return null
    
    var to_player := player.global_position - global_position
    var distance := to_player.length()
    var angle := rad_to_deg(global_basis.z.angle_to(-to_player.normalized()))
    
    # Check forward cone
    if angle < forward_fov / 2.0 and distance < forward_vision_range:
        if has_line_of_sight(player):
            return player
    
    # Check peripheral (less effective)
    elif angle < peripheral_fov / 2.0 and distance < peripheral_range:
        if has_line_of_sight(player):
            return player
    
    return null

func calculate_detection_rate(player: Player) -> float:
    var distance := global_position.distance_to(player.global_position)
    var distance_factor := 1.0 - (distance / forward_vision_range)
    
    var light_factor := player.get_light_level()  # 0.0 = dark, 1.0 = lit
    var movement_factor := 1.0 if player.velocity.length() > 0.5 else 0.3
    
    return detection_speed * distance_factor * light_factor * movement_factor * 50.0
```

### Sound Detection System

Based on Thief/Hitman implementation - sounds propagate along navigation paths:

```gdscript
class_name SoundPropagation
extends Node

# Sound travels through connected navigation points, not through walls
func propagate_sound(origin: Vector3, loudness: float, sound_type: String) -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        var path := NavigationServer3D.map_get_path(
            get_world_3d().navigation_map,
            origin,
            enemy.global_position,
            true
        )
        
        if path.is_empty():
            continue  # No path = sound blocked
        
        var path_distance := calculate_path_length(path)
        var heard_loudness := loudness - (path_distance * 0.5)  # Falloff
        
        if heard_loudness > enemy.hearing_threshold:
            enemy.hear_sound(origin, sound_type, heard_loudness)

func calculate_path_length(path: PackedVector3Array) -> float:
    var length := 0.0
    for i in range(1, path.size()):
        length += path[i].distance_to(path[i - 1])
    return length
```

### Player Light Level

```gdscript
class_name LightDetector
extends Node3D

@export var sample_points: Array[Marker3D]  # Multiple points on player body

func get_light_level() -> float:
    var total := 0.0
    var space := get_world_3d().direct_space_state
    
    for point in sample_points:
        for light in get_tree().get_nodes_in_group("lights"):
            var dir := light.global_position - point.global_position
            var query := PhysicsRayQueryParameters3D.create(
                point.global_position,
                light.global_position
            )
            var result := space.intersect_ray(query)
            
            if result.is_empty():  # Not blocked
                total += light.light_energy / dir.length_squared()
    
    return clamp(total / sample_points.size(), 0.0, 1.0)
```

---

## AI Alert States

Three-phase system (industry standard):

```gdscript
enum AlertState { IDLE, SUSPICIOUS, ALERTED, COMBAT }

class_name EnemyAI
extends CharacterBody3D

var alert_state := AlertState.IDLE
var suspicion_point: Vector3
var search_timer := 0.0

signal alert_state_changed(new_state: AlertState)

func transition_to(new_state: AlertState) -> void:
    alert_state = new_state
    alert_state_changed.emit(new_state)
    
    match new_state:
        AlertState.SUSPICIOUS:
            play_animation("suspicious")
            speak_dialogue("what_was_that")
        AlertState.ALERTED:
            speak_dialogue("who_goes_there")
            # Other guards in range hear and become suspicious
            alert_nearby_guards()
        AlertState.COMBAT:
            speak_dialogue("intruder")
            trigger_alarm()
```

### Visual Feedback (Critical!)

```gdscript
class_name AlertIndicator
extends Node3D

@export var idle_icon: Texture2D
@export var suspicious_icon: Texture2D  # "?" 
@export var alerted_icon: Texture2D     # "!"
@export var detection_meter: ProgressBar  # Shows filling detection

func update_indicator(state: AlertState, detection: float) -> void:
    detection_meter.value = detection
    
    match state:
        AlertState.IDLE:
            icon.texture = idle_icon
            detection_meter.visible = false
        AlertState.SUSPICIOUS:
            icon.texture = suspicious_icon
            detection_meter.visible = true
        AlertState.ALERTED:
            icon.texture = alerted_icon
            detection_meter.visible = false
```

---

## Player Abilities

Five categories of stealth tools (per Mark Brown's analysis):

### 1. Movement Alteration

```gdscript
# Crouch, crawl, run (noisy vs quiet)
func calculate_noise_level() -> float:
    if is_crouching:
        return 0.2
    elif is_running:
        return 1.0
    else:
        return 0.5
```

### 2. Information Gathering

```gdscript
# Peek, scout, mark enemies
func activate_detective_vision() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.show_outline()
        enemy.show_vision_cone()
```

### 3. AI Manipulation

```gdscript
# Throw distractions
func throw_distraction(target_position: Vector3) -> void:
    var rock := distraction_scene.instantiate()
    rock.global_position = target_position
    add_child(rock)
    SoundPropagation.propagate_sound(target_position, 30.0, "impact")
```

### 4. Space Control

```gdscript
# Shoot out lights, create hiding spots
func shoot_light(light: Light3D) -> void:
    light.visible = false
    # Update light level for area
```

### 5. Enemy Elimination

```gdscript
func perform_takedown(enemy: EnemyAI, lethal: bool) -> void:
    if enemy.alert_state == AlertState.COMBAT:
        return  # Can't stealth kill alert enemy
    
    if lethal:
        enemy.die()
    else:
        enemy.knockout()
    
    # Body becomes interactable
    spawn_body(enemy)
```

---

## Level Design

### Outpost Design (Open Areas)

```
                      [Safe perimeter for observation]
                               |
           [Sparse guards at edges - isolatable]
                               |
                [Dense center with objective]
                               |
              [Multiple entry points/routes]
```

### Limited Encounter Design (Corridors)

- Enemies visible 8+ meters before engagement
- Multiple paths through
- Cover objects and hiding spots
- Emergency escape routes

---

## UI Communication

Based on Thief's "light gem" innovation:

```gdscript
class_name StealthHUD
extends Control

@onready var visibility_meter: TextureProgressBar
@onready var sound_meter: TextureProgressBar
@onready var minimap: Control

func _process(_delta: float) -> void:
    visibility_meter.value = player.get_light_level() * 100
    sound_meter.value = player.current_noise_level * 100
```

---

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Instant detection | Use gradual detection with clear feedback |
| Guards see through walls | Raycast-based vision with proper collision |
| Unfair patrol patterns | Make patterns learnable, with tells |
| Two games (stealth + combat) | Either commit to stealth or make combat risky |
| Unclear detection | Always show WHY player was detected |

---

## Godot-Specific Tips

1. **Raycasts for vision**: Use `PhysicsRayQueryParameters3D` with collision masks
2. **NavigationAgent3D**: For patrol routes and pathfinding
3. **Area3D**: For sound propagation zones and trigger areas
4. **AnimationTree**: Blend between alert state animations


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
