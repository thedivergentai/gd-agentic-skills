---
name: godot-quest-system
description: "Expert blueprint for quest  tracking systems (objectives, progress, rewards, branching chains) using Resource-based quests, signal-driven updates, and AutoLoad managers. Use when implementing RPG quests or mission systems. Keywords quest, objectives, Quest Resource, QuestObjective, signal-driven, branching, rewards, AutoLoad."
---

# Quest System

Resource-based data, signal-driven updates, and AutoLoad coordination define scalable quest architectures.

## Available Scripts

### [quest_resource.gd](scripts/quest_resource.gd)
Data-driven quest definition using Resources for modular objectives and branching rewards.

### [quest_manager_singleton.gd](scripts/quest_manager_singleton.gd)
Centralized AutoLoad orchestrator for tracking active quests and broadcasting status updates.

### [kill_objective_trigger.gd](scripts/kill_objective_trigger.gd)
Decoupled trigger logic that bridges game events (enemies dying) to the Quest System.

### [quest_ui_tracker.gd](scripts/quest_ui_tracker.gd)
Reactive VBox UI that dynamically adds and removes objective labels based on manager signals.

### [branching_quest_data.gd](scripts/branching_quest_data.gd)
Extended quest logic for handling multiple outcomes and player-driven narrative paths.

### [ quest_giver_dialogue_hook.gd](scripts/quest_giver_dialogue_hook.gd)
Hook for integrating NPCs with the quest system, allowing for conditional dialogue branches.

### [quest_persistence_loader.gd](scripts/quest_persistence_loader.gd)
Expert patterns for serializing quest IDs and progress counts for persistent save states.

### [timed_quest_challenge.gd](scripts/timed_quest_challenge.gd)
Template for time-limited challenges with automatic failure conditions and UI signals.

### [hidden_objective_logic.gd](scripts/hidden_objective_logic.gd)
Background objective tracker for secret achievements or non-visible quest progress.

### [localized_quest_description.gd](scripts/localized_quest_description.gd)
Strategy for supporting multi-language quest text using `tr()` keys instead of hardcoded strings.

## NEVER Do in Quest Systems

- **NEVER store active quest data directly in the Player node** — If the player dies or the scene reloads, quest progress is lost. Use an AutoLoad or a persistent Data Resource [20].
- **NEVER use hardcoded string IDs for objectives without validation** — Typos in `update_objective("kill_slimes")` will fail silently. Use StringNames or a central ID registry [21].
- **NEVER forget to disconnect completion signals** — If a quest signal isn't cleared after completion, it might trigger multiple times, awarding double rewards [22].
- **NEVER poll for mission completion in `_process()`** — Checking objectives 60 times a second is wasteful. Use a signal-driven approach (e.g. `on_enemy_died`) [23].
- **NEVER skip save/load logic for quests** — Resetting a 10-hour quest line because of a game restart is a player-ending bug. Always persist quest states [24].
- **NEVER use `all()` on objective arrays without null/type checks** — Attempting to check completion on a null objective entry will crash the entire system [25].
- **NEVER hardcode quest logic inside enemy or item scripts** — Use a generic `EventBus` or `QuestTrigger` node to bridge the encounter to the QuestManager.
- **NEVER allow multiple instances of the same Quest Resource to be active** — Ensure you're tracking unique Quest IDs to prevent accidental duplication of missions.
- **NEVER use complex UI logic to calculate progress** — The UI should only display what the `Quest` resource provides. Keep formulas in the `QuestManager`.
- **NEVER award rewards directly inside the quest script** — Delegate reward distribution to the `InventoryManager` or `EconomyManager` via signals for decoupling.

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
