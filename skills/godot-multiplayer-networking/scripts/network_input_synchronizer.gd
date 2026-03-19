# network_input_synchronizer.gd
# Handling latency with input replication
extends MultiplayerSynchronizer

# EXPERT NOTE: Sync only the essential inputs, not the 
# calculated physics state, to save bandwidth.

@export var input_direction: Vector2

func _ready():
	# Configure what to sync in the Inspector (SceneReplicationConfig)
	pass

func _physics_process(_delta):
	if is_multiplayer_authority():
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
