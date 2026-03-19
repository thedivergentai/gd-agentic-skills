# status_effect_component.gd
# Managing temporary modifiers via composition
class_name StatusEffectComponent extends Node

# EXPERT NOTE: Stacking status effects as children allows for 
# easy management of durations and overlapping logic.

func apply_effect(effect_scene: PackedScene):
	var effect = effect_scene.instantiate()
	add_child(effect)
	# Effect script handles its own timer and removal
