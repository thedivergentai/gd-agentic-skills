---
name: godot-ability-system
description: "Expert patterns for RPG/action ability systems including cooldown strategies, combo systems, ability chaining, skill trees with prerequisites, upgrade paths, and resource management. Use when implementing unlockable abilities, character progression, or complex skill systems. Trigger keywords: PlayerAbility, AbilityManager, cooldown, SkillTree, SkillNode, prerequisites, can_use, execute, ComboSystem, ability_chain, global_cooldown, charge_system, upgrade_path."
---

# Ability System

Expert guidance for building flexible, extensible ability systems.

## NEVER Do

- **NEVER use _process() for cooldown tracking** — Use timers or manual delta tracking in _physics_process(). _process() has variable delta and causes cooldown desync in slow frames.
- **NEVER forget global cooldown (GCD)** — Without GCD, players spam instant abilities. Add a small universal cooldown (0.5-1.5s) between all ability casts.
- **NEVER hardcode ability effects in manager code** — Use the Strategy pattern. Each ability is a Resource with execute() method, not a giant switch statement.
- **NEVER allow ability use during animation lock** — Check `is_casting` or `animation_playing` before allowing new casts. Interrupting animations breaks state machines.
- **NEVER save cooldown state without time normalization** — Save "cooldown_end_time" (OS.get_unix_time() + remaining), not "remaining_time". Prevents exploits (change system clock, reload game).

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [ability_manager.gd](scripts/ability_manager.gd)
Ability orchestration with cooldown registry, can_use checks, and visual cooldown progress. Decoupled from character logic for use on players, enemies, or turrets.

### [ability_resource.gd](scripts/ability_resource.gd)
Scriptable ability resource base class with metadata, stats, and effects array. Virtual execute() method for inheritance (ProjectileAbility, BuffAbility).

---

## Architecture Patterns

### Resource-Based Abilities

```gdscript
# ability_base.gd - Base class for all abilities
class_name Ability
extends Resource

@export var ability_id: String
@export var display_name: String
@export var icon: Texture2D
@export var description: String

@export_group("Costs")
@export var mana_cost: int = 0
@export var stamina_cost: int = 0
@export var health_cost: int = 0  # Life tap abilities

@export_group("Timing")
@export var cooldown: float = 5.0
@export var cast_time: float = 0.0  # 0 = instant
@export var channel_time: float = 0.0  # Channeled abilities

@export_group("Unlocking")
@export var unlock_level: int = 1
@export var prerequisites: Array[String] = []  # Other ability IDs

## Override these
func can_cast(caster: Node) -> bool:
    return true  # Additional checks (range, target, etc.)

func execute(caster: Node, target: Node = null) -> void:
    pass  # Ability effect

func on_cast_start(caster: Node) -> void:
    pass  # Animation, effects

func on_cast_complete(caster: Node) -> void:
    execute(caster)

func on_cancel(caster: Node) -> void:
    pass  # Refund resources
```

### Concrete Ability Example

```gdscript
# fireball.gd
class_name FireballAbility
extends Ability

@export var damage: int = 50
@export var projectile_scene: PackedScene
@export var range: float = 500.0

func can_cast(caster: Node) -> bool:
    var target = caster.get_target()
    if not target:
        return false
    
    var distance := caster.global_position.distance_to(target.global_position)
    return distance <= range

func execute(caster: Node, target: Node = null) -> void:
    var projectile := projectile_scene.instantiate()
    caster.get_parent().add_child(projectile)
    projectile.global_position = caster.global_position
    projectile.target = target
    projectile.damage = damage
```

---

## Ability Manager (Centralized)

### Core Manager

```gdscript
# ability_manager.gd
class_name AbilityManager
extends Node

signal ability_cast(ability_id: String)
signal ability_ready(ability_id: String)
signal cooldown_started(ability_id: String, duration: float)

var abilities: Dictionary = {}  # ability_id → Ability
var cooldowns: Dictionary = {}  # ability_id → float (time remaining)
var is_casting: bool = false
var global_cooldown: float = 0.0  # GCD timer

@export var gcd_duration: float = 1.0  # Global cooldown

func register_ability(ability: Ability) -> void:
    abilities[ability.ability_id] = ability
    cooldowns[ability.ability_id] = 0.0

func can_use_ability(ability_id: String, caster: Node) -> bool:
    var ability := abilities.get(ability_id) as Ability
    if not ability:
        return false
    
    # Check GCD
    if global_cooldown > 0.0:
        return false
    
    # Check specific cooldown
    if cooldowns.get(ability_id, 0.0) > 0.0:
        return false
    
    # Check if already casting
    if is_casting and ability.cast_time > 0.0:
        return false
    
    # Check resources
    if not has_resources(caster, ability):
        return false
    
    # Ability-specific checks
    return ability.can_cast(caster)

func use_ability(ability_id: String, caster: Node, target: Node = null) -> bool:
    if not can_use_ability(ability_id, caster):
        return false
    
    var ability := abilities[ability_id]
    
    # Consume resources
    consume_resources(caster, ability)
    
    # Start cast
    if ability.cast_time > 0.0:
        start_cast(ability, caster, target)
    else:
        # Instant cast
        ability.execute(caster, target)
        trigger_cooldown(ability_id, ability.cooldown)
    
    ability_cast.emit(ability_id)
    return true

func start_cast(ability: Ability, caster: Node, target: Node) -> void:
    is_casting = true
    ability.on_cast_start(caster)
    
    # Create timer for cast completion
    var timer := get_tree().create_timer(ability.cast_time)
    await timer.timeout
    
    if is_casting:  # Not interrupted
        ability.on_cast_complete(caster)
        trigger_cooldown(ability.ability_id, ability.cooldown)
    
    is_casting = false

func interrupt_cast() -> void:
    if is_casting:
        is_casting = false
        # Trigger ability.on_cancel() if needed

func trigger_cooldown(ability_id: String, duration: float) -> void:
    cooldowns[ability_id] = duration
    global_cooldown = gcd_duration
    cooldown_started.emit(ability_id, duration)

func _physics_process(delta: float) -> void:
    # Tick cooldowns
    for ability_id in cooldowns.keys():
        if cooldowns[ability_id] > 0.0:
            cooldowns[ability_id] -= delta
            if cooldowns[ability_id] <= 0.0:
                ability_ready.emit(ability_id)
    
    # Tick GCD
    if global_cooldown > 0.0:
        global_cooldown -= delta

func has_resources(caster: Node, ability: Ability) -> bool:
    return (caster.mana >= ability.mana_cost and
            caster.stamina >= ability.stamina_cost and
            caster.health > ability.health_cost)

func consume_resources(caster: Node, ability: Ability) -> void:
    caster.mana -= ability.mana_cost
    caster.stamina -= ability.stamina_cost
    caster.health -= ability.health_cost
```

---

## Advanced Patterns

### Combo System

```gdscript
# combo_tracker.gd
extends Node

var combo_chain: Array[String] = []
var combo_window: float = 2.0  # Seconds to continue combo
var last_ability_time: float = 0.0

func register_ability_use(ability_id: String) -> void:
    var current_time := Time.get_ticks_msec() * 0.001
    
    # Reset if too much time passed
    if current_time - last_ability_time > combo_window:
        combo_chain.clear()
    
    combo_chain.append(ability_id)
    last_ability_time = current_time
    
    # Check for combo completion
    check_combos()

func check_combos() -> void:
    # Example: "slash" → "slash" → "spin" = "whirlwind"
    if combo_chain.size() >= 3:
        var last_three := combo_chain.slice(-3)
        if last_three == ["slash", "slash", "spin"]:
            trigger_combo_ability("whirlwind")
            combo_chain.clear()

func trigger_combo_ability(combo_id: String) -> void:
    # Execute powerful combo ability
    pass
```

### Charge-Based Abilities

```gdscript
# charge_ability.gd - Abilities with multiple charges (like League of Legends Flash)
class_name ChargeAbility
extends Ability

@export var max_charges: int = 2
@export var charge_recharge_time: float = 20.0

var current_charges: int = max_charges
var recharge_timer: float = 0.0

func can_cast(caster: Node) -> bool:
    return current_charges > 0

func execute(caster: Node, target: Node = null) -> void:
    current_charges -= 1
    
    # Start recharging if not at max
    if current_charges < max_charges and recharge_timer == 0.0:
        recharge_timer = charge_recharge_time

func tick(delta: float) -> void:
    if recharge_timer > 0.0:
        recharge_timer -= delta
        if recharge_timer <= 0.0:
            current_charges += 1
            if current_charges < max_charges:
                recharge_timer = charge_recharge_time  # Continue recharging
            else:
                recharge_timer = 0.0
```

---

## Skill Tree System

### Skill Node

```gdscript
# skill_node.gd
class_name SkillNode
extends Resource

@export var skill_id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D

@export_group("Requirements")
@export var prerequisites: Array[String] = []  # Other skill_ids
@export var character_level_required: int = 1
@export var points_required: int = 1
@export var mutually_exclusive_with: Array[String] = []  # Can't have both

@export_group("Progression")
@export var max_rank: int = 1
@export var current_rank: int = 0

@export_group("Effects")
@export var unlocks_ability: String = ""  # Ability ID to grant
@export var stat_bonuses: Dictionary = {}  # "strength": 5, "crit_chance": 0.05

func can_unlock(player_skills: Dictionary, player_level: int, available_points: int) -> bool:
    # Already maxed
    if current_rank >= max_rank:
        return false
    
    # Not enough points
    if available_points < points_required:
        return false
    
    # Level requirement
    if player_level < character_level_required:
        return false
    
    # Prerequisites
    for prereq_id in prerequisites:
        if not player_skills.has(prereq_id) or player_skills[prereq_id].current_rank == 0:
            return false
    
    # Mutual exclusivity
    for exclusive_id in mutually_exclusive_with:
        if player_skills.has(exclusive_id) and player_skills[exclusive_id].current_rank > 0:
            return false
    
    return true

func unlock() -> void:
    current_rank += 1
```

### Skill Tree Manager

```gdscript
# skill_tree.gd
class_name SkillTree
extends Node

signal skill_unlocked(skill_id: String, rank: int)
signal points_changed(new_total: int)

var skills: Dictionary = {}  # skill_id → SkillNode
var skill_points: int = 0

func add_skill(skill: SkillNode) -> void:
    skills[skill.skill_id] = skill

func can_unlock_skill(skill_id: String, player_level: int) -> bool:
    var skill := skills.get(skill_id) as SkillNode
    if not skill:
        return false
    
    return skill.can_unlock(skills, player_level, skill_points)

func unlock_skill(skill_id: String, player_level: int) -> bool:
    if not can_unlock_skill(skill_id, player_level):
        return false
    
    var skill := skills[skill_id]
    skill.unlock()
    skill_points -= skill.points_required
    
    # Apply effects
    apply_skill_effects(skill)
    
    skill_unlocked.emit(skill_id, skill.current_rank)
    points_changed.emit(skill_points)
    return true

func apply_skill_effects(skill: SkillNode) -> void:
    # Grant ability if specified
    if skill.unlocks_ability != "":
        var ability_manager := get_node("/root/AbilityManager")
        # Register new ability
    
    # Apply stat bonuses
    var player := get_tree().get_first_node_in_group("player")
    for stat_name in skill.stat_bonuses.keys():
        var bonus = skill.stat_bonuses[stat_name]
        player.set(stat_name, player.get(stat_name) + bonus)

func add_skill_points(amount: int) -> void:
    skill_points += amount
    points_changed.emit(skill_points)

func reset_tree(refund_points: bool = true) -> void:
    var total_spent := 0
    for skill in skills.values():
        total_spent += skill.current_rank * skill.points_required
        skill.current_rank = 0
    
    if refund_points:
        skill_points += total_spent
        points_changed.emit(skill_points)
```

---

## Cooldown Strategies

### Per-Ability Cooldown (Standard)

```gdscript
# Already shown in AbilityManager above
# Each ability has independent cooldown
```

### Shared Cooldown (Hearthstone-style)

```gdscript
# All abilities of type "summon" share cooldown
var summon_cooldown: float = 0.0

func use_summon_ability(ability: Ability) -> void:
    ability.execute()
    summon_cooldown = 3.0  # All summons on 3s cooldown
```

### Charge System (Already shown above)

Multiple uses, recharges over time.

---

## Edge Cases

### Cooldown Persistence

```gdscript
# save_system.gd
func save_ability_cooldowns() -> Dictionary:
    var data := {}
    var current_time := Time.get_unix_time_from_system()
    
    for ability_id in ability_manager.cooldowns.keys():
        var remaining := ability_manager.cooldowns[ability_id]
        if remaining > 0.0:
            data[ability_id] = current_time + remaining  # Absolute time
    
    return data

func load_ability_cooldowns(data: Dictionary) -> void:
    var current_time := Time.get_unix_time_from_system()
    
    for ability_id in data.keys():
        var end_time: float = data[ability_id]
        var remaining := max(0.0, end_time - current_time)
        ability_manager.cooldowns[ability_id] = remaining
```

### Animation Lock

```gdscript
# Prevent ability spam during attack animations
func _on_animation_player_animation_started(anim_name: String) -> void:
    if anim_name.begins_with("attack_"):
        ability_manager.is_casting = true

func _on_animation_player_animation_finished(anim_name: String) -> void:
    if anim_name.begins_with("attack_"):
        ability_manager.is_casting = false
```


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
