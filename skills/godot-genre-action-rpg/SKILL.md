---
name: godot-genre-action-rpg
description: "Comprehensive blueprint for Action RPGs including real-time combat (hitbox/hurtbox, stat-based damage), character progression (RPG stats, leveling, skill trees), loot systems (procedural item generation, affixes, rarity tiers), equipment systems (gear slots, stat modifiers), and ability systems (cooldowns, mana cost, AOE). Based on expert ARPG design from Diablo, Path of Exile, Souls-like developers. Trigger keywords: action_rpg, loot_generator, rpg_stats, skill_tree, hitbox_combat, item_affixes, equipment_slots, ability_cooldown, stat_scaling."
---

# Genre: Action RPG

Expert blueprint for action RPGs emphasizing real-time combat, character builds, loot, and progression.

## NEVER Do

- **NEVER make stats invisible to players** — Hidden stats feel like RNG. Show damage numbers, crit chance %, armor values clearly.
- **NEVER use linear damage scaling** — `damage = level * 10` makes early/late game boring. Use exponential: `damage = base * pow(1.15, level)`.
- **NEVER forget diminishing returns on defense** — Armor as `damage_reduction = armor / (armor + 100)` prevents invincibility stacking.
- **NEVER make loot drops feel samey** — Differentiate rarities with visual effects (Epic = purple glow), sound cues, and meaningful stat differences.
- **NEVER skip hit recovery/stagger** — Attacks without hitstun feel weightless. Add 0.2-0.5s stagger on hit for impact feedback.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [damage_label_manager.gd](scripts/damage_label_manager.gd)
Pooled floating damage numbers with vertical stacking logic. Pre-warms pool, handles critical hit scaling, and auto-fades via tweens.

### [telegraphed_enemy.gd](scripts/telegraphed_enemy.gd)
AoE telegraph pattern for enemy attacks. Wind-up animation with visual cues gives players dodge window, then executes damage zone.

---

## Core Loop

`Combat → Loot → Level Up → Build Power → Challenge Harder Content → Repeat`

## Skill Chain

`godot-project-foundations`, `godot-characterbody-2d`, `godot-combat-system`, `godot-rpg-stats`, `godot-inventory-system`, `godot-ability-system`, `godot-quest-system`, `godot-economy-system`, `godot-save-load-systems`

---

## Combat System

### Real-Time Combat with Stats

```gdscript
class_name CombatController
extends Node

signal damage_dealt(target: Node, amount: int, type: String)
signal enemy_killed(enemy: Node, xp_reward: int)

func calculate_damage(attacker: RPGStats, defender: RPGStats, base_damage: int) -> Dictionary:
    # Physical damage formula
    var attack_power := attacker.get_stat("strength") * 2 + base_damage
    var defense := defender.get_stat("armor")
    
    # Damage reduction formula (diminishing returns)
    var reduction := defense / (defense + 100.0)
    var final_damage := int(attack_power * (1.0 - reduction))
    
    # Critical hit check
    var crit_chance := attacker.get_stat("crit_chance") / 100.0
    var is_crit := randf() < crit_chance
    if is_crit:
        final_damage = int(final_damage * attacker.get_stat("crit_damage") / 100.0)
    
    return {
        "damage": max(1, final_damage),
        "is_crit": is_crit,
        "damage_type": "physical"
    }

func apply_damage(target: Node, damage_result: Dictionary) -> void:
    if target.has_method("take_damage"):
        target.take_damage(damage_result["damage"], damage_result["is_crit"])
        damage_dealt.emit(target, damage_result["damage"], damage_result["damage_type"])
```

### Hitbox/Hurtbox Combat

```gdscript
class_name Hitbox
extends Area2D

@export var damage: int = 10
@export var knockback_force: float = 200.0
@export var attack_owner: Node

var has_hit: Array[Node] = []  # Prevent multi-hit per swing

func _ready() -> void:
    monitoring = false  # Enable only during attack frames

func enable() -> void:
    has_hit.clear()
    monitoring = true

func disable() -> void:
    monitoring = false

func _on_area_entered(area: Area2D) -> void:
    if area is Hurtbox:
        var target := area.owner_entity
        if target != attack_owner and target not in has_hit:
            has_hit.append(target)
            var result := CombatController.calculate_damage(
                attack_owner.stats, target.stats, damage
            )
            CombatController.apply_damage(target, result)
            apply_knockback(target)

func apply_knockback(target: Node) -> void:
    var direction := (target.global_position - attack_owner.global_position).normalized()
    if target.has_method("apply_knockback"):
        target.apply_knockback(direction * knockback_force)
```

---

## RPG Stats System

### Attribute-Based Stats

```gdscript
class_name RPGStats
extends Resource

signal stat_changed(stat_name: String, new_value: float)
signal level_up(new_level: int)

# Base attributes (increased on level up)
@export var strength: int = 10
@export var dexterity: int = 10
@export var intelligence: int = 10
@export var vitality: int = 10

# Derived stats (calculated from attributes)
var derived_stats: Dictionary = {}

# Modifiers from equipment, buffs, etc.
var flat_modifiers: Dictionary = {}    # +50 health
var percent_modifiers: Dictionary = {} # +10% damage

var level: int = 1
var experience: int = 0
var skill_points: int = 0

func _init() -> void:
    recalculate_stats()

func recalculate_stats() -> void:
    derived_stats = {
        # Health: Vitality-based
        "max_health": vitality * 10 + 100,
        "health_regen": vitality * 0.5,
        
        # Mana: Intelligence-based
        "max_mana": intelligence * 8 + 50,
        "mana_regen": intelligence * 0.3,
        
        # Physical: Strength + Dexterity
        "physical_damage": strength * 2,
        "armor": strength + vitality,
        
        # Critical: Dexterity-based
        "crit_chance": 5.0 + dexterity * 0.2,
        "crit_damage": 150.0 + dexterity * 0.5,
        
        # Speed: Dexterity-based
        "attack_speed": 1.0 + dexterity * 0.01,
        "move_speed": 100.0 + dexterity * 2
    }
    
    # Apply modifiers
    for stat_name in derived_stats:
        var base := derived_stats[stat_name]
        var flat := flat_modifiers.get(stat_name, 0.0)
        var percent := percent_modifiers.get(stat_name, 0.0)
        derived_stats[stat_name] = (base + flat) * (1.0 + percent / 100.0)

func get_stat(stat_name: String) -> float:
    if stat_name in derived_stats:
        return derived_stats[stat_name]
    return get(stat_name)

func add_experience(amount: int) -> void:
    experience += amount
    while experience >= get_xp_for_next_level():
        experience -= get_xp_for_next_level()
        level += 1
        skill_points += 5
        level_up.emit(level)

func get_xp_for_next_level() -> int:
    # Exponential scaling
    return int(100 * pow(1.5, level - 1))
```

---

## Loot System

### Item Generation

```gdscript
class_name LootGenerator
extends Node

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const RARITY_WEIGHTS := {
    Rarity.COMMON: 60,
    Rarity.UNCOMMON: 25,
    Rarity.RARE: 10,
    Rarity.EPIC: 4,
    Rarity.LEGENDARY: 1
}

const RARITY_AFFIX_COUNT := {
    Rarity.COMMON: 0,
    Rarity.UNCOMMON: 1,
    Rarity.RARE: 2,
    Rarity.EPIC: 3,
    Rarity.LEGENDARY: 4
}

@export var affix_pool: Array[ItemAffix]
@export var base_items: Array[ItemBase]

func generate_item(item_level: int, magic_find: float = 0.0) -> Item:
    var rarity := roll_rarity(magic_find)
    var base := base_items.pick_random()
    
    var item := Item.new()
    item.base = base
    item.rarity = rarity
    item.item_level = item_level
    
    # Roll affixes based on rarity
    var affix_count := RARITY_AFFIX_COUNT[rarity]
    var available_affixes := affix_pool.duplicate()
    
    for i in affix_count:
        if available_affixes.is_empty():
            break
        var affix := available_affixes.pick_random()
        available_affixes.erase(affix)
        item.affixes.append(generate_affix_roll(affix, item_level))
    
    return item

func roll_rarity(magic_find: float) -> Rarity:
    var weights := RARITY_WEIGHTS.duplicate()
    # Magic find increases rare+ drops
    weights[Rarity.RARE] *= (1.0 + magic_find / 100.0)
    weights[Rarity.EPIC] *= (1.0 + magic_find / 100.0)
    weights[Rarity.LEGENDARY] *= (1.0 + magic_find / 100.0)
    
    var total := 0.0
    for w in weights.values():
        total += w
    
    var roll := randf() * total
    for rarity in weights:
        roll -= weights[rarity]
        if roll <= 0:
            return rarity
    return Rarity.COMMON

func generate_affix_roll(affix: ItemAffix, item_level: int) -> Dictionary:
    # Scale affix values with item level
    var min_roll := affix.min_value * (1.0 + item_level * 0.1)
    var max_roll := affix.max_value * (1.0 + item_level * 0.1)
    return {
        "affix": affix,
        "value": randf_range(min_roll, max_roll)
    }
```

### Equipment System

```gdscript
class_name Equipment
extends Node

signal equipment_changed(slot: String, item: Item)

enum Slot { HEAD, CHEST, HANDS, LEGS, FEET, WEAPON, OFFHAND, RING1, RING2, AMULET }

var equipped: Dictionary = {}  # Slot -> Item

func equip(item: Item) -> Item:
    var slot: Slot = item.base.slot
    var previous: Item = equipped.get(slot)
    
    # Unequip old item
    if previous:
        remove_item_stats(previous)
    
    # Equip new item
    equipped[slot] = item
    apply_item_stats(item)
    equipment_changed.emit(Slot.keys()[slot], item)
    
    return previous  # Return to inventory

func apply_item_stats(item: Item) -> void:
    var stats := owner.stats as RPGStats
    
    # Base stats
    for stat_name in item.base.base_stats:
        stats.flat_modifiers[stat_name] = stats.flat_modifiers.get(stat_name, 0) + item.base.base_stats[stat_name]
    
    # Affix stats
    for affix_data in item.affixes:
        var affix := affix_data["affix"] as ItemAffix
        var value := affix_data["value"]
        if affix.is_percent:
            stats.percent_modifiers[affix.stat] = stats.percent_modifiers.get(affix.stat, 0) + value
        else:
            stats.flat_modifiers[affix.stat] = stats.flat_modifiers.get(affix.stat, 0) + value
    
    stats.recalculate_stats()
```

---

## Ability System

### Skill Trees and Unlocks

```gdscript
class_name SkillTree
extends Resource

@export var skills: Array[Skill]
@export var connections: Dictionary  # skill_id -> Array[prerequisite_ids]

func can_unlock(skill_id: String, unlocked_skills: Array[String]) -> bool:
    if skill_id in unlocked_skills:
        return false  # Already unlocked
    
    var prereqs: Array = connections.get(skill_id, [])
    for prereq in prereqs:
        if prereq not in unlocked_skills:
            return false
    return true

func unlock_skill(skill_id: String, player: Node) -> bool:
    var skill := get_skill(skill_id)
    if not skill or player.stats.skill_points < skill.cost:
        return false
    
    player.stats.skill_points -= skill.cost
    player.unlocked_skills.append(skill_id)
    player.ability_manager.add_ability(skill.ability)
    return true
```

### Active Abilities

```gdscript
class_name ActiveAbility
extends Resource

@export var name: String
@export var cooldown: float = 5.0
@export var mana_cost: int = 20
@export var damage_multiplier: float = 2.0
@export var aoe_radius: float = 0.0
@export var effect_scene: PackedScene

var current_cooldown: float = 0.0

func can_use(caster: Node) -> bool:
    return current_cooldown <= 0 and caster.stats.current_mana >= mana_cost

func use(caster: Node, target_position: Vector2) -> void:
    if not can_use(caster):
        return
    
    caster.stats.current_mana -= mana_cost
    current_cooldown = cooldown
    
    var effect := effect_scene.instantiate()
    effect.global_position = target_position
    effect.damage = int(caster.stats.get_stat("physical_damage") * damage_multiplier)
    effect.caster = caster
    caster.get_tree().current_scene.add_child(effect)

func update_cooldown(delta: float) -> void:
    current_cooldown = max(0, current_cooldown - delta)
```

---

## Enemy Design

### Scaling Difficulty

```gdscript
class_name EnemySpawner
extends Node

@export var base_enemy_scene: PackedScene
@export var area_level: int = 1

func spawn_enemy(position: Vector2) -> Node:
    var enemy := base_enemy_scene.instantiate()
    enemy.global_position = position
    
    # Scale stats with area level
    var stats := enemy.stats as RPGStats
    var level_mult := 1.0 + (area_level - 1) * 0.15
    
    stats.vitality = int(stats.vitality * level_mult)
    stats.strength = int(stats.strength * level_mult)
    stats.recalculate_stats()
    
    # Scale rewards
    enemy.xp_reward = int(enemy.xp_reward * level_mult)
    enemy.loot_table.item_level = area_level
    
    add_child(enemy)
    return enemy
```

---

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Stats feel meaningless | Ensure each point noticeably affects gameplay |
| Loot feels same | Dramatic visual and mechanical differences between rarities |
| Combat too simple | Combo systems, positioning matters, enemy variety |
| Progression walls | Multiple viable paths, catch-up mechanics |
| Inventory management tedium | Auto-sort, quick-sell, stash tabs |

---

## Architecture Overview

```
AutoLoads:
├── PlayerStats (godot-rpg-stats)
├── InventoryManager (godot-inventory-system)
├── QuestManager (godot-quest-system)
├── LootGenerator (godot-economy-system)
└── GameManager (godot-scene-management)

Player:
├── CharacterBody2D/3D
├── RPGStats
├── Equipment
├── AbilityManager
├── Hitbox/Hurtbox
└── InputHandler

Enemies:
├── AI Controller (state machine)
├── RPGStats (scaled)
├── HealthComponent
├── LootTable
└── Hitbox/Hurtbox
```

---

## Godot-Specific Tips

1. **Resources for items**: Use `Resource` for items - easily serializable for save/load
2. **Object pooling**: Pool damage numbers, projectiles, item pickups
3. **Animation callbacks**: Use AnimationPlayer method tracks to enable/disable hitboxes
4. **Stat recalculation**: Only recalculate on equip/level, not every frame

---

## Example Games for Reference

- **Diablo / Path of Exile** - Loot-focused ARPG
- **Elden Ring / Dark Souls** - Combat-focused action RPG
- **Hades** - Roguelike ARPG hybrid
- **Grim Dawn** - Deep character builds


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
