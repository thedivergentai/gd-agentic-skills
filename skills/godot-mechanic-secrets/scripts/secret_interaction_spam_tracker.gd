class_name SecretInteractionSpamTracker
extends Node

## Expert Interaction Spam Tracker.
## Triggers events based on repetitive clicks or actions (e.g. NPC dialogue secrets).

signal secret_spam_triggered

@export var required_interactions: int = 50
@export var reset_on_exit: bool = true

var interaction_count: int = 0

func interact() -> void:
	interaction_count += 1
	if interaction_count >= required_interactions:
		secret_spam_triggered.emit()
		interaction_count = 0 # Optional reset

func reset() -> void:
	if reset_on_exit:
		interaction_count = 0

## Tip: Use 'Interaction Spam' for Easter Eggs that reward player persistence/curiosity.
