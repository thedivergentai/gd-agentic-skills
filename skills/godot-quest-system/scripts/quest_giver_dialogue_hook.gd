# quest_giver_dialogue_hook.gd
# Interfacing quests with a dialogue system
extends Node

# EXPERT NOTE: The NPC logic should check the QuestManager state 
# to decide which dialogue branch to play.

@export var quest_to_give: Quest

func interact():
	var q_status = QuestManager.get_quest_status(quest_to_give.id)
	
	match q_status:
		Quest.Status.AVAILABLE:
			_show_offer_dialogue()
		Quest.Status.ACTIVE:
			_show_reminder_dialogue()
		Quest.Status.COMPLETED:
			_show_thanks_dialogue()

func _show_offer_dialogue():
	# If player accepts in UI:
	QuestManager.accept_quest(quest_to_give)
