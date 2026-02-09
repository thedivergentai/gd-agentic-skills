# skills/quest-system/scripts/quest_graph_manager.gd
extends Node

## Quest Graph Manager Expert Pattern
## Runtime manager for traversing quest graphs and tracking state.

class_name QuestGraphManager

signal quest_started(quest_id: String)
signal objective_completed(quest_id: String, objective_id: String)
signal quest_completed(quest_id: String)

var active_quests: Dictionary = {} # { quest_id: QuestState }
var completed_quests: Array[String] = []

func start_quest(quest_resource: QuestGraph) -> void:
	if is_quest_active(quest_resource.quest_id) or is_quest_completed(quest_resource.quest_id):
		return
	
	var state = QuestState.new()
	state.resource = quest_resource
	state.current_nodes = quest_resource.get_start_nodes()
	active_quests[quest_resource.quest_id] = state
	
	quest_started.emit(quest_resource.quest_id)
	_check_auto_complete_objectives(state)

func complete_objective(quest_id: String, objective_id: String) -> void:
	var state = active_quests.get(quest_id)
	if not state:
		return
	
	if state.complete_objective(objective_id):
		objective_completed.emit(quest_id, objective_id)
		_advance_quest(state)

func _advance_quest(state: QuestState) -> void:
	var next_nodes = state.resource.get_next_nodes(state.current_nodes)
	state.current_nodes = next_nodes
	
	if state.is_complete():
		_finish_quest(state.resource.quest_id)

func _finish_quest(quest_id: String) -> void:
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	quest_completed.emit(quest_id)

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

# Helper Class
class QuestState:
	var resource: QuestGraph
	var current_nodes: Array[String] = []
	var completed_objectives: Array[String] = []
	
	func complete_objective(obj_id: String) -> bool:
		if obj_id in completed_objectives: return false
		completed_objectives.append(obj_id)
		return true

	func is_complete() -> bool:
		# Logic to check if end node is reached
		return false # simplified

## EXPERT USAGE:
## QuestManager.start_quest(load("res://quests/main_quest.tres"))
## QuestManager.complete_objective("main_quest", "kill_rats")
