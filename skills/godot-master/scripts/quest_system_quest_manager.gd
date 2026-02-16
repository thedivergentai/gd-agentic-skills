# godot-master/scripts/quest_system_quest_manager.gd
extends Node

## Quest System Expert Pattern
## Implements DAG-based dependencies and signal-based objective tracking.

signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal objective_updated(quest_id: String, objective_id: String, progress: int)

@export var quest_database: Dictionary = {} # ID: QuestResource
var active_quests: Dictionary = {} # ID: ProgressState
var completed_quests: Array[String] = []

func start_quest(quest_id: String) -> bool:
    # 1. Quest Dependency Graphs (DAG)
    # Expert logic: Check prerequisites before starting.
    var quest_res = quest_database.get(quest_id)
    if not quest_res: return false
    
    for prereq in quest_res.prerequisites:
        if prereq not in completed_quests:
            print("Quest Blocked: Prerequisite '", prereq, "' not met.")
            return false
            
    active_quests[quest_id] = {"objectives": {}}
    quest_started.emit(quest_id)
    return true

func update_objective(quest_id: String, objective_id: String, amount: int) -> void:
    # 2. Objective State Sync
    # Professional pattern: Central manager handles tracking, not the actor.
    if quest_id not in active_quests: return
    
    var quest_state = active_quests[quest_id]
    quest_state.objectives[objective_id] = quest_state.objectives.get(objective_id, 0) + amount
    
    objective_updated.emit(quest_id, objective_id, quest_state.objectives[objective_id])
    
    if _check_quest_completion(quest_id):
        _complete_quest(quest_id)

func _check_quest_completion(quest_id: String) -> bool:
    # Logic to verify all objectives in QuestResource are met...
    return true

func _complete_quest(quest_id: String) -> void:
    active_quests.erase(quest_id)
    completed_quests.append(quest_id)
    
    # 3. Reward Distribution Logic
    # Decoupled Reward Provider system.
    _distribute_rewards(quest_database[quest_id].rewards)
    quest_completed.emit(quest_id)

func _distribute_rewards(rewards: Array) -> void:
    for reward in rewards:
        # reward.apply(player) pattern
        pass

## EXPERT NOTE:
## For 'Save-Game Compatibility', NEVER serialize the QuestResource itself. 
## Save a Dictionary of { 'completed': ['q1', 'q2'], 'active': {'q3': {'obj1': 5}} }.
## Use signals to update UI waypoints dynamically when 'objective_updated' is emitted.
## NEVER hardcode quest logic inside enemy scripts. Use the 'Signal Bus' pattern: 
## enemy.died.connect(QuestManager._on_enemy_died).
