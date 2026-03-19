# quest_ui_tracker.gd
# Dynamic list of active objectives
extends VBoxContainer

# EXPERT NOTE: The UI should be purely reactive, 
# populating itself based on QuestManager signals.

func _ready():
	QuestManager.quest_accepted.connect(_add_quest_track)
	QuestManager.quest_completed.connect(_remove_quest_track)
	QuestManager.quest_objective_updated.connect(_update_quest_track)

func _add_quest_track(quest: Quest):
	var label = Label.new()
	label.name = quest.id
	add_child(label)
	_update_quest_track(quest)

func _update_quest_track(quest: Quest):
	var label = get_node_or_null(quest.id)
	if label:
		label.text = "%s: %d/%d" % [quest.title, quest.current_count, quest.objective_count]

func _remove_quest_track(quest: Quest):
	var label = get_node_or_null(quest.id)
	if label:
		label.queue_free()
