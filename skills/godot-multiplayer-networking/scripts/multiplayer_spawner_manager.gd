# multiplayer_spawner_manager.gd
# Syncing node spawning across the network
extends MultiplayerSpawner

# EXPERT NOTE: Use MultiplayerSpawner to automatically 
# instance nodes across all peers when added to parent.

func _ready():
	# Set spawn_path to a shared parent (e.g. /root/Main/Players)
	spawn_function = _custom_spawn

func _custom_spawn(data: Dictionary) -> Node:
	var player = preload("res://player.tscn").instantiate()
	player.player_id = data["id"]
	player.set_name(str(data["id"]))
	return player
