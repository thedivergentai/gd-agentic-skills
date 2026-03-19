# timed_quest_challenge.gd
# Adding temporal constraints to quest logic
class_name TimedQuest extends Quest

@export var time_limit: float = 60.0

func start_timer():
	get_tree().create_timer(time_limit).timeout.connect(_on_fail)

func _on_fail():
	if status == Status.ACTIVE:
		status = Status.FAILED
		QuestManager.notify_quest_failed(id)
