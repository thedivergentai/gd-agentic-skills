# one_shot_deferred_connections.gd
# Specialized connection flags for physics and cleanup
extends Node

# EXPERT NOTE: 
# CONNECT_ONE_SHOT: Disconnects automatically after firing.
# CONNECT_DEFERRED: Runs at the end of the frame (safe for physics changes).

func _ready():
	# Executes once, then cleans up. Deferred ensures physics space is unlocked.
	$DeathTrigger.body_entered.connect(_on_death, CONNECT_ONE_SHOT | CONNECT_DEFERRED)

func _on_death(_body):
	get_tree().reload_current_scene()
