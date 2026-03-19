# follower_component.gd
# Decoupled tracking logic using NodePath injection
class_name FollowerComponent extends Node

# EXPERT NOTE: Using NodePath allows the component to be wired in 
# the inspector by the parent, keeping it context-aware but decoupled.

@export var target_path: NodePath
var target: Node2D

func _ready() -> void:
	if not target_path.is_empty():
		target = get_node(target_path)

func _process(delta: float) -> void:
	if is_instance_valid(target):
		owner.global_position = owner.global_position.lerp(target.global_position, 5.0 * delta)
