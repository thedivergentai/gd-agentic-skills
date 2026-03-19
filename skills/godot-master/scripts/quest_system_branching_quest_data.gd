# branching_quest_data.gd
# Handling multi-outcome quest lines
class_name BranchingQuest extends Quest

# EXPERT NOTE: Allow quests to have multiple "Next" paths 
# based on player choices or hidden stats.

@export var positive_outcome_quest: Quest
@export var negative_outcome_quest: Quest

func resolve_branch(is_positive: bool):
	if is_positive:
		QuestManager.accept_quest(positive_outcome_quest)
	else:
		QuestManager.accept_quest(negative_outcome_quest)
