# quest_persistence_loader.gd
# Saving and loading quest progress
extends Node

# EXPERT NOTE: Save quest IDs and their current progress count 
# to a dictionary for easy JSON or ConfigFile serialization.

func get_save_data() -> Dictionary:
	var data = {}
	for id in QuestManager.active_quests:
		var q = QuestManager.active_quests[id]
		data[id] = q.current_count
	return data

func load_save_data(data: Dictionary):
	# Assumes you have a central 'QuestDatabase' to load base resources
	for id in data:
		var q_res = QuestDatabase.get_quest(id)
		if q_res:
			QuestManager.accept_quest(q_res)
			QuestManager.update_objective(id, data[id])
