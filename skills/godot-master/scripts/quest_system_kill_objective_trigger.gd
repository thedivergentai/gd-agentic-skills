# kill_objective_trigger.gd
# Decoupled quest trigger via signals
extends Node

# EXPERT NOTE: Use a generic trigger script that listens to game events 
# (like an EventBus) to avoid hardcoding quest logic into enemies.

@export var target_enemy_id: String = ""
@export var quest_id: String = ""

func _ready():
	# Assumes a GlobalEventBus exits
	if get_tree().root.has_node("GlobalBus"):
		var bus = get_node("/root/GlobalBus")
		bus.enemy_defeated.connect(_on_enemy_defeated)

func _on_enemy_defeated(enemy_id: String, _points: int):
	if enemy_id == target_enemy_id:
		QuestManager.update_objective(quest_id)
