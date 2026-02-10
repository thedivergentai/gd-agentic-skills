---
name: godot-quest-system
description: "Expert blueprint for quest  tracking systems (objectives, progress, rewards, branching chains) using Resource-based quests, signal-driven updates, and AutoLoad managers. Use when implementing RPG quests or mission systems. Keywords quest, objectives, Quest Resource, QuestObjective, signal-driven, branching, rewards, AutoLoad."
---

# Quest System

Resource-based data, signal-driven updates, and AutoLoad coordination define scalable quest architectures.

## Available Scripts

### [quest_manager.gd](scripts/quest_manager.gd)
Expert AutoLoad quest tracker with objective progression and reward distribution.

### [quest_graph_manager.gd](scripts/quest_graph_manager.gd)
Runtime manager for graph-based quests. Tracks objectives and node progression.

## NEVER Do in Quest Systems

- **NEVER store quest data in nodes** — Quest progress in `player.gd` variables? Loss on scene reload. Use Resource-based Quests OR AutoLoad singleton.
- **NEVER use strings for quest IDs without registry** — `update_objective("kil_bandts", ...)` typo = silent failure. Use constants OR validate IDs against registry.
- **NEVER forget to disconnect signals** — Quest completed but signal still connected? Quest completes again on next update = duplicate rewards. Disconnect in `_on_quest_completed()`.
- **NEVER poll for objective updates** — Checking `if enemy_count == 10` every frame = wasteful. Use signals: `enemy.died.connect(quest_manager.on_enemy_killed)`.
- **NEVER skip save/load for quests** — Player completes quest 5, game restarts, quest resets? Frustration. MUST persist `active_quests` + `completed_quests` arrays.
- **NEVER use `all()` for objectives without null check** — `objectives.all(func(obj): return obj.is_complete())` with null objectives? Crash. Validate array contents first.

---

```gdscript
# quest.gd
class_name Quest
extends Resource

signal progress_updated(objective_id: String, progress: int)signal completed

@export var quest_id: String
@export var quest_name: String
@export_multiline var description: String
@export var objectives: Array[QuestObjective] = []
@export var rewards: Array[QuestReward] = []
@export var required_level: int = 1

func is_complete() -> bool:
    return objectives.all(func(obj): return obj.is_complete())

func check_completion() -> void:
    if is_complete():
        completed.emit()
```

## Quest Objectives

```gdscript
# quest_objective.gd
class_name QuestObjective
extends Resource

enum Type { KILL, COLLECT, TALK, REACH }

@export var objective_id: String
@export var type: Type
@export var target: String  # Enemy name, item ID, NPC name, location
@export var required_amount: int = 1
@export var current_amount: int = 0

func progress(amount: int = 1) -> void:
    current_amount += amount
    current_amount = mini(current_amount, required_amount)

func is_complete() -> bool:
    return current_amount >= required_amount
```

## Quest Manager

```gdscript
# quest_manager.gd (AutoLoad)
extends Node

signal quest_accepted(quest: Quest)
signal quest_completed(quest: Quest)
signal objective_updated(quest: Quest, objective: QuestObjective)

var active_quests: Array[Quest] = []
var completed_quests: Array[String] = []

func accept_quest(quest: Quest) -> void:
    if quest.quest_id in completed_quests:
        return
    
    active_quests.append(quest)
    quest.completed.connect(func(): _on_quest_completed(quest))
    quest_accepted.emit(quest)

func _on_quest_completed(quest: Quest) -> void:
    active_quests.erase(quest)
    completed_quests.append(quest.quest_id)
    
    # Give rewards
    for reward in quest.rewards:
        reward.grant()
    
    quest_completed.emit(quest)

func update_objective(quest_id: String, objective_id: String, amount: int = 1) -> void:
    for quest in active_quests:
        if quest.quest_id == quest_id:
            for obj in quest.objectives:
                if obj.objective_id == objective_id:
                    obj.progress(amount)
                    objective_updated.emit(quest, obj)
                    quest.check_completion()
                    return

func get_active_quest(quest_id: String) -> Quest:
    for quest in active_quests:
        if quest.quest_id == quest_id:
            return quest
    return null
```

## Quest Triggers

```gdscript
# Example: Kill quest integration
# enemy.gd
func _on_died() -> void:
    QuestManager.update_objective("kill_bandits", "kill_bandit", 1)

# Example: Collection integration
# item_pickup.gd
func _on_collected() -> void:
    QuestManager.update_objective("gather_herbs", "collect_herb", 1)

# Example: Talk integration
# npc.gd
func interact() -> void:
    DialogueManager.start_dialogue(dialogue_id)
    QuestManager.update_objective("find_elder", "talk_to_elder", 1)
```

## Quest UI

```gdscript
# quest_ui.gd
extends Control

@onready var quest_list := $QuestList

func _ready() -> void:
    QuestManager.quest_accepted.connect(_on_quest_accepted)
    QuestManager.objective_updated.connect(_on_objective_updated)
    refresh_ui()

func refresh_ui() -> void:
    for child in quest_list.get_children():
        child.queue_free()
    
    for quest in QuestManager.active_quests:
        var quest_entry := create_quest_entry(quest)
        quest_list.add_child(quest_entry)

func create_quest_entry(quest: Quest) -> Control:
    var entry := VBoxContainer.new()
    
    var title := Label.new()
    title.text = quest.quest_name
    entry.add_child(title)
    
    for obj in quest.objectives:
        var obj_label := Label.new()
        obj_label.text = "%s: %d/%d" % [obj.target, obj.current_amount, obj.required_amount]
        entry.add_child(obj_label)
    
    return entry
```

## Best Practices

1. **Signal-Driven** - Emit events, systems listen
2. **Save Progress** - Track completed quests
3. **Validation** - Check prerequisites before accepting

## Reference
- Related: `godot-dialogue-system`, `godot-save-load-systems`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
