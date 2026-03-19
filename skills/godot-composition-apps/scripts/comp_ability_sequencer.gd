class_name CompAbilitySequencer
extends Node

## Expert Ability Orchestrator.
## Manages child 'Ability' nodes and their activation sequence.

func cast_ability(ability_name: String) -> void:
	var ability = get_node_or_null(ability_name)
	if ability and ability.has_method("execute"):
		ability.execute()

## Rule: Adding new skills is as simple as adding a new child node with a script.
