# quest_manager_singleton.gd
# Centralized quest state and event handling
extends Node

# EXPERT NOTE: The QuestManager should be an Autoload to track 
# progress across scene changes.

signal quest_accepted(quest: Quest)
signal quest_objective_updated(quest: Quest)
signal quest_completed(quest: Quest)

var active_quests: Dictionary = {} # ID -> Quest

func accept_quest(quest: Quest):
	if not active_quests.has(quest.id):
		quest.status = Quest.Status.ACTIVE
		active_quests[quest.id] = quest
		quest_accepted.emit(quest)

func update_objective(quest_id: String, amount: int = 1):
	if active_quests.has(quest_id):
		var q = active_quests[quest_id]
		q.current_count += amount
		quest_objective_updated.emit(q)
		
		if q.current_count >= q.objective_count:
			_complete_quest(q)

func _complete_quest(quest: Quest):
	quest.status = Quest.Status.COMPLETED
	active_quests.erase(quest.id)
	quest_completed.emit(quest)
	
	if quest.next_quest:
		accept_quest(quest.next_quest)
