class_name CompRockTestBoilerplate
extends Node

## Expert 'Rock Test' debug utility.
## Validates if a component is truly decoupled and context-agnostic.

func run_rock_test(component: Node) -> void:
	var rock = Node.new()
	rock.name = "LiteralRock"
	add_child(rock)
	
	rock.add_child(component)
	print("Testing Component: ", component.name)
	
	# If the component throws errors because 'get_parent()' isn't a Player, it FAILS.
	# Proper components should just sit on the rock waiting for signals/calls.

## Tip: Run this test during development to catch hard-coupling early.
