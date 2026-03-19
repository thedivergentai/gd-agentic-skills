# interaction_component.gd
# Handling contextual logic via Callable injection
class_name InteractionComponent extends Area2D

# EXPERT NOTE: Instead of a massive 'match' statement, the parent 
# injects the specific interaction logic into this component.

var interaction_logic: Callable

func interact() -> void:
	if interaction_logic.is_valid():
		interaction_logic.call()
	else:
		push_warning("InteractionComponent on %s has no logic defined!" % owner.name)
