---
name: godot-genre-shooter
description: "Expert blueprint for FPS/TPS shooter games (Call of Duty, Counter-Strike, Apex Legends, Fortnite) covering weapon systems, recoil patterns, hitscan vs projectile, aim assist, multiplayer prediction, and gunplay feel. Use when building competitive shooters, battle royales, or tactical FPS games requiring responsive combat. Keywords hitscan, recoil pattern, aim assist, client prediction, weapon archetype, projectile physics, hit registration."
---

# Genre: Shooter (FPS/TPS)

Gunplay feel, responsive combat, and competitive balance define shooters.

## Available Scripts

### [advanced_weapon_controller.gd](scripts/advanced_weapon_controller.gd)
Expert pattern for recoil, bloom, and dual hitscan/projectile systems with object pooling notes.

## Core Loop

`Engage → Aim → Fire → Kill Confirm → Acquire Next`

## NEVER Do in Shooters

- **NEVER use `_process()` for hit detection** — Hitscan MUST use physics raycasts in `_physics_process()` or on-demand. Frame-rate dependent accuracy breaks competitive integrity.
- **NEVER apply recoil to the weapon model transform** — Recoil affects CAMERA rotation (view) and SPREAD (accuracy), not the gun's visual position. Players learn to control camera, not 3D models.
- **NEVER use single `AudioStreamPlayer` for gunfire** — Layered audio (shot + mechanical + tail) creates punchy feel. Single-stream guns sound flat and amateurish.
- **NEVER sync projectiles with `rpc()` per-bullet** — Bandwidth death. Use client-side prediction for visuals, server-authoritative hit validation. Compress: send firing event, not each frame's position.
- **NEVER use `Area3D` overlap for hitscan hits** — This is 10-100x slower than `PhysicsRayQueryParameters3D`. Areas are for triggers (health pickups), not instant ballistics.
- **NEVER hardcode damage values in weapon script** — Export stats to `Resource` for weapon data. Designers need iteration without code changes. Use `WeaponData.tres`.
- **NEVER allow client-authoritative hit decisions in multiplayer** — Client says "I shot you" = hacking paradise. Server validates all damage with lag compensation (rewinding).

---

## Weapon System Architecture

```gdscript
class_name Weapon
extends Node3D

@export_group("Stats")
@export var damage: int = 20
@export var fire_rate: float = 0.1  # Seconds between shots
@export var magazine_size: int = 30
@export var reload_time: float = 2.0
@export var range: float = 100.0

@export_group("Recoil")
@export var base_recoil: Vector2 = Vector2(0.5, 2.0)  # X, Y degrees
@export var recoil_recovery_speed: float = 5.0
@export var max_spread: float = 5.0

@export_group("Type")
@export var is_hitscan: bool = true
@export var projectile_scene: PackedScene

var current_ammo: int
var can_fire: bool = true
var current_recoil: Vector2 = Vector2.ZERO
var current_spread: float = 0.0

signal fired
signal reloaded
signal ammo_changed(current: int, max: int)
```

---

## Hitscan vs Projectile

### Hitscan (Instant Hit)

```gdscript
func fire_hitscan() -> void:
    if not can_fire or current_ammo <= 0:
        return
    
    current_ammo -= 1
    ammo_changed.emit(current_ammo, magazine_size)
    
    var camera := get_viewport().get_camera_3d()
    var ray_origin := camera.global_position
    var ray_direction := -camera.global_basis.z
    
    # Apply spread
    ray_direction = apply_spread(ray_direction)
    
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(
        ray_origin,
        ray_origin + ray_direction * range
    )
    query.collision_mask = collision_mask
    
    var result := space.intersect_ray(query)
    if result:
        var hit_point: Vector3 = result.position
        var hit_normal: Vector3 = result.normal
        var hit_object: Object = result.collider
        
        spawn_impact_effect(hit_point, hit_normal)
        
        if hit_object.has_method("take_damage"):
            var hit_zone := determine_hit_zone(result)
            var final_damage := calculate_damage(damage, hit_zone)
            hit_object.take_damage(final_damage, hit_zone)
    
    apply_recoil()
    start_fire_cooldown()
    fired.emit()

func determine_hit_zone(result: Dictionary) -> String:
    # Use collision shape name or bone detection for hitboxes
    if "headshot" in result.collider.name.to_lower():
        return "head"
    elif "chest" in result.collider.name.to_lower():
        return "chest"
    return "body"

func calculate_damage(base: int, zone: String) -> int:
    match zone:
        "head": return int(base * 2.5)
        "chest": return int(base * 1.0)
        _: return int(base * 0.8)
```

### Projectile (Physical Bullet)

```gdscript
class_name Projectile
extends CharacterBody3D

@export var speed := 100.0
@export var damage := 20
@export var gravity_affected := true
@export var lifetime := 5.0

var direction: Vector3
var shooter: Node3D

func _ready() -> void:
    await get_tree().create_timer(lifetime).timeout
    queue_free()

func _physics_process(delta: float) -> void:
    if gravity_affected:
        velocity.y -= 9.8 * delta
    
    velocity = direction * speed
    var collision := move_and_collide(velocity * delta)
    
    if collision:
        var collider := collision.get_collider()
        if collider != shooter and collider.has_method("take_damage"):
            collider.take_damage(damage)
        spawn_impact(collision.get_position(), collision.get_normal())
        queue_free()
```

---

## Recoil System

Three types of recoil working together:

```gdscript
class_name RecoilSystem
extends Node

var visual_recoil: Vector2 = Vector2.ZERO    # Camera kick
var pattern_offset: Vector2 = Vector2.ZERO   # Deterministic pattern
var spread_bloom: float = 0.0                # Accuracy loss

@export var recoil_pattern: Array[Vector2]   # Predefined spray pattern
var pattern_index: int = 0

func apply_recoil(weapon: Weapon) -> void:
    # 1. Visual recoil - camera kick
    visual_recoil.y += weapon.base_recoil.y * randf_range(0.8, 1.2)
    visual_recoil.x += weapon.base_recoil.x * randf_range(-1.0, 1.0)
    
    # 2. Pattern recoil - learnable spray
    if pattern_index < recoil_pattern.size():
        pattern_offset += recoil_pattern[pattern_index]
        pattern_index += 1
    
    # 3. Spread bloom - reduced accuracy
    spread_bloom = min(spread_bloom + 0.5, weapon.max_spread)

func recover_recoil(delta: float, recovery_speed: float) -> void:
    visual_recoil = visual_recoil.lerp(Vector2.ZERO, recovery_speed * delta)
    pattern_offset = pattern_offset.lerp(Vector2.ZERO, recovery_speed * delta)
    spread_bloom = lerp(spread_bloom, 0.0, recovery_speed * delta)
    
    if visual_recoil.length() < 0.01:
        pattern_index = 0  # Reset pattern

func get_spread_direction(base_direction: Vector3) -> Vector3:
    var spread_angle := deg_to_rad(spread_bloom)
    var random_offset := Vector2(
        randf_range(-spread_angle, spread_angle),
        randf_range(-spread_angle, spread_angle)
    )
    return base_direction.rotated(Vector3.UP, random_offset.x).rotated(Vector3.RIGHT, random_offset.y)
```

---

## Aim Assist (Controller Support)

```gdscript
class_name AimAssist
extends Node3D

@export var assist_range := 50.0
@export var assist_angle := 15.0  # Degrees
@export var friction_strength := 0.3  # Slowdown near targets
@export var magnetism_strength := 0.1  # Pull toward targets

func apply_aim_assist(look_input: Vector2, camera: Camera3D) -> Vector2:
    var target := find_closest_target(camera)
    if not target:
        return look_input
    
    var to_target := target.global_position - camera.global_position
    var camera_forward := -camera.global_basis.z
    var angle := rad_to_deg(camera_forward.angle_to(to_target.normalized()))
    
    if angle > assist_angle:
        return look_input
    
    # Friction - slow movement near targets
    var friction := 1.0 - (friction_strength * (1.0 - angle / assist_angle))
    look_input *= friction
    
    # Magnetism - subtle pull toward target
    var target_screen_pos := camera.unproject_position(target.global_position)
    var screen_center := get_viewport().get_visible_rect().size / 2
    var pull_direction := (target_screen_pos - screen_center).normalized()
    look_input += pull_direction * magnetism_strength * (1.0 - angle / assist_angle)
    
    return look_input

func find_closest_target(camera: Camera3D) -> Node3D:
    var closest: Node3D = null
    var closest_angle := assist_angle
    
    for target in get_tree().get_nodes_in_group("enemies"):
        var to_target := target.global_position - camera.global_position
        var angle := rad_to_deg((-camera.global_basis.z).angle_to(to_target.normalized()))
        
        if angle < closest_angle and to_target.length() < assist_range:
            if has_line_of_sight(camera.global_position, target.global_position):
                closest = target
                closest_angle = angle
    
    return closest
```

---

## Weapon Feel Polish

### Camera Effects

```gdscript
func on_weapon_fired() -> void:
    # Screen shake
    camera_shake(0.1, 0.05)
    
    # FOV punch
    camera.fov += 2.0
    await get_tree().create_timer(0.05).timeout
    camera.fov -= 2.0
    
    # Muzzle flash
    muzzle_flash.visible = true
    await get_tree().create_timer(0.02).timeout
    muzzle_flash.visible = false

func on_weapon_reloaded() -> void:
    # Lock controls during reload
    can_fire = false
    can_aim = false
    
    play_animation("reload")
    await get_tree().create_timer(reload_time).timeout
    
    current_ammo = magazine_size
    can_fire = true
    can_aim = true
```

### Audio Layering

```gdscript
@export var fire_sounds: Array[AudioStream]  # Random selection
@export var tail_sound: AudioStream           # Reverb/echo
@export var mechanical_sound: AudioStream     # Gun mechanism

func play_fire_audio() -> void:
    # Main shot
    var shot := fire_sounds.pick_random()
    fire_audio_player.stream = shot
    fire_audio_player.play()
    
    # Mechanical click
    mechanical_player.play()
    
    # Tail (delayed reverb)
    await get_tree().create_timer(0.1).timeout
    tail_player.play()
```

---

## Weapon Selection Decision Tree

**When designing weapon balance:**
- High fire rate (SMG) = Low damage per shot, rewards tracking aim
- Low fire rate (Sniper) = High damage, rewards precision
- Shotguns = Spread pattern (5-8 pellets), effective range <10m
- ARs = Jack-of-all-trades, medium everything

**Technical implementation:**
- Pistol/AR: Hitscan (instant feedback)
- Rocket/Grenade: Projectile with gravity
- S niper: Hitscan with tracer visual

## Multiplayer Client Prediction Pattern

```gdscript
# CLIENT: Instant feedback, no waiting for server
func fire_client() -> void:
    play_effects_immediate()  # Muzzle flash, recoil, audio
    local_hitscan_visual()    # Visual blood splatter only
    rpc_id(1, "server_validate_shot", camera.global_transform)

# SERVER: Authoritative damage
@rpc("any_peer")
func server_validate_shot(shooter_transform: Transform3D) -> void:
    var hit = perform_server_hitscan(shooter_transform)
    if hit and is_valid_shot(hit):
        rpc("confirm_hit", hit.victim_id, hit.damage)

# EDGE CASE: What if client's visual hit doesn't match server?
# SOLUTION: Server wins. Client shows "no reg" indicator if mismatch.
```

## Common Pitfalls & Expert Fixes

- **Weak bullet impact** → Triple-layer audio (shot+tail+mechanical) + screen shake + blood VFX + damage number
- **Guns feel identical** → Unique recoil patterns (SMG: tight vertical, AK: strong horizontal kick)
- **No skill ceiling** → Learnable spray patterns (CS:GO style), not pure RNG spread
- **Controller aim frustration** → Friction (0.3 slowdown near targets) + subtle 0.1 magnetism

---

## Godot-Specific Tips

1. **Raycasts**: Use `PhysicsRayQueryParameters3D` with proper layer masks
2. **Projectiles**: `CharacterBody3D` or `RigidBody3D` depending on physics needs
3. **Audio**: Multiple `AudioStreamPlayer3D` for layered gun sounds
4. **Animations**: `AnimationTree` for weapon state machines (idle, aim, fire, reload)


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
