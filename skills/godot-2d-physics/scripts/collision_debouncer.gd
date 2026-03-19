# Collision Signal Debouncer
extends Node

## Expert Pattern: Prevents "signal spam" when multiple collision shapes 
## on one body enter an Area2D simultaneously.

var _active_bodies: Dictionary = {}

func handle_body_entered(body: Node2D) -> void:
	if _active_bodies.has(body):
		return
		
	_active_bodies[body] = true
	print("Physics Body genuinely entered: ", body.name)

func handle_body_exited(body: Node2D) -> void:
	# Small delay or frame-check to ensure it's not a momentary exit/re-entry
	_active_bodies.erase(body)
