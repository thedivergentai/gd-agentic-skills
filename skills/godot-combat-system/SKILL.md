---
name: godot-combat-system
description: "Expert patterns for combat systems including hitbox/hurtbox architecture, damage calculation (DamageData class), health components, combat state machines, combo systems, ability cooldowns, and damage popups. Use for action games, RPGs, or fighting games. Trigger keywords: Hitbox, Hurtbox, DamageData, HealthComponent, combat_state, combo_system, ability_cooldown, invincibility_frames, damage_popup."
---

# Combat System

Expert guidance for building flexible, component-based combat systems.

## NEVER Do

- **NEVER use direct damage references (`target.health -= 10`)** — Bypasses armor, resistance, events. Use DamageData + HealthComponent pattern.
- **NEVER forget invincibility frames** — Without i-frames, multi-hit attacks deal damage every frame. Add 0.5-1s invincibility after hit.
- **NEVER keep hitboxes active permanently** — Enable/disable hitboxes with animation tracks. Permanent hitboxes cause unintended damage.
- **NEVER use groups for hitbox filtering** — Use collision layers. Groups don't respect physics layers and cause friendly fire.
- **NEVER emit damage_received without DamageData** — Raw int/float damage loses context (source, type, knockback). Always use DamageData class.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [hitbox_hurtbox.gd](scripts/hitbox_hurtbox.gd)
Component-based hitbox with hit-stop and knockback. Uses Engine.time_scale with ignore_time_scale timer for proper hit-stop freeze frame.

---

## Damage System

```gdscript
# damage_data.gd
class_name DamageData
extends RefCounted

var amount: float
var source: Node
var damage_type: String = "physical"
var knockback: Vector2 = Vector2.ZERO
var is_critical: bool = false

func _init(dmg: float, src: Node = null) -> void:
    amount = dmg
    source = src
```

## Hurtbox/Hitbox Pattern

```gdscript
# hurtbox.gd
extends Area2D
class_name Hurtbox

signal damage_received(data: DamageData)

@export var health_component: Node

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area is Hitbox:
        var damage := area.get_damage()
        damage_received.emit(damage)
        
        if health_component:
            health_component.take_damage(damage)
```

```gdscript
# hitbox.gd
extends Area2D
class_name Hitbox

@export var damage: float = 10.0
@export var damage_type: String = "physical"
@export var knockback_force: float = 100.0
@export var owner_node: Node

func get_damage() -> DamageData:
    var data := DamageData.new(damage, owner_node)
    data.damage_type = damage_type
    
    # Calculate knockback direction
    if owner_node:
        var direction := (global_position - owner_node.global_position).normalized()
        data.knockback = direction * knockback_force
    
    return data
```

## Health Component

```gdscript
# health_component.gd
extends Node
class_name HealthComponent

signal health_changed(old_health: float, new_health: float)
signal died
signal healed(amount: float)

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var invincible: bool = false

func take_damage(data: DamageData) -> void:
    if invincible:
        return
    
    var old_health := current_health
    current_health -= data.amount
    current_health = clampf(current_health, 0, max_health)
    
    health_changed.emit(old_health, current_health)
    
    if current_health <= 0:
        died.emit()

func heal(amount: float) -> void:
    var old_health := current_health
    current_health += amount
    current_health = minf(current_health, max_health)
    
    healed.emit(amount)
    health_changed.emit(old_health, current_health)

func is_dead() -> bool:
    return current_health <= 0
```

## Combat State Machine

```gdscript
# combat_state.gd
extends Node
class_name CombatState

enum State { IDLE, ATTACKING, BLOCKING, DODGING, STUNNED }

var current_state: State = State.IDLE
var can_act: bool = true

func enter_attack_state() -> bool:
    if not can_act:
        return false
    
    current_state = State.ATTACKING
    can_act = false
    return true

func enter_block_state() -> void:
    current_state = State.BLOCKING

func enter_dodge_state() -> bool:
    if not can_act:
        return false
    
    current_state = State.DODGING
    can_act = false
    return true

func exit_state() -> void:
    current_state = State.IDLE
    can_act = true
```

## Combo System

```gdscript
# combo_system.gd
extends Node
class_name ComboSystem

signal combo_executed(combo_name: String)

@export var combo_window: float = 0.5
var combo_buffer: Array[String] = []
var last_input_time: float = 0.0

func register_input(action: String) -> void:
    var current_time := Time.get_ticks_msec() / 1000.0
    
    if current_time - last_input_time > combo_window:
        combo_buffer.clear()
    
    combo_buffer.append(action)
    last_input_time = current_time
    
    check_combos()

func check_combos() -> void:
    # Light → Light → Heavy = Special Attack
    if combo_buffer.size() >= 3:
        var last_three := combo_buffer.slice(-3)
        if last_three == ["light", "light", "heavy"]:
            execute_combo("special_attack")
            combo_buffer.clear()

func execute_combo(combo_name: String) -> void:
    combo_executed.emit(combo_name)
```

## Ability System

```gdscript
# ability.gd
class_name Ability
extends Resource

@export var ability_name: String
@export var cooldown: float = 1.0
@export var damage: float = 25.0
@export var range: float = 100.0
@export var animation: String

var is_on_cooldown: bool = false

func can_use() -> bool:
    return not is_on_cooldown

func use(caster: Node) -> void:
    if not can_use():
        return
    
    is_on_cooldown = true
    
    # Execute ability logic
    _execute(caster)
    
    # Start cooldown
    await caster.get_tree().create_timer(cooldown).timeout
    is_on_cooldown = false

func _execute(caster: Node) -> void:
    # Override in derived abilities
    pass
```

## Damage Popups

```gdscript
# damage_popup.gd
extends Label

func show_damage(amount: float, is_crit: bool = false) -> void:
    text = str(int(amount))
    
    if is_crit:
        modulate = Color.RED
        scale = Vector2(1.5, 1.5)
    
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position:y", position.y - 50, 1.0)
    tween.tween_property(self, "modulate:a", 0.0, 1.0)
    tween.finished.connect(queue_free)
```

## Critical Hits

```gdscript
func calculate_damage(base_damage: float, crit_chance: float = 0.1) -> DamageData:
    var data := DamageData.new(base_damage)
    
    if randf() < crit_chance:
        data.is_critical = true
        data.amount *= 2.0
    
    return data
```

## Best Practices

1. **Separate Concerns** - Health ≠ Combat ≠ Movement
2. **Use Signals** - Decouple systems
3. **Area2D for Hitboxes** - Built-in collision detection
4. **Invincibility Frames** - Prevent spam damage

## Reference
- Related: `godot-2d-physics`, `godot-animation-player`, `godot-characterbody-2d`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
