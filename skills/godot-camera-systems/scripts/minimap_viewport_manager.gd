# minimap_viewport_manager.gd
# Setting up 2D/3D Mini-maps using SubViewports [156]
extends SubViewportContainer

# EXPERT NOTE: SubViewports are expensive. Use a low render_target_update_mode 
# for UI elements that don't need 60FPS updates (like world maps).

@onready var minimap_cam: Camera2D = $SubViewport/Camera2D
@export var player: Node2D

func _ready() -> void:
	# Optimization: Only update the minimap if the player moves significantly
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE

func _process(_delta: float) -> void:
	if player:
		# Mini-map follows player but ignores rotation
		minimap_cam.global_position = player.global_position
