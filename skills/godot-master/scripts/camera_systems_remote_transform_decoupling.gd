# remote_transform_decoupling.gd
# Decoupling Camera from Player hierarchy using RemoteTransform2D [30]
extends Node2D

# EXPERT NOTE: Avoid parenting the Camera directly to the Player. 
# Using RemoteTransform2D prevents player rotation/scale from 
# affecting the camera while keeping position sync.

@onready var remote: RemoteTransform2D = RemoteTransform2D.new()
@export var camera: Camera2D

func _ready() -> void:
	add_child(remote)
	remote.remote_path = camera.get_path()
	
	# Configure what to sync
	remote.update_position = true
	remote.update_rotation = false # Camera stays upright
	remote.update_scale = false    # Camera stays at 1:1
