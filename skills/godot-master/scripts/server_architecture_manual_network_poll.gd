# manual_network_poll.gd
# Running networking on a separate thread via manual polling
extends Node

# EXPERT NOTE: Disabling SceneTree.multiplayer_poll allows 
# you to control exactly when network packets are processed.

func _ready():
	# Stop the engine from automatically polling networking
	get_tree().multiplayer_poll = false

func _physics_process(_delta):
	# Manual pumping of the network stack, usually inside a Mutex lock
	if multiplayer.has_multiplayer_peer():
		multiplayer.poll()
