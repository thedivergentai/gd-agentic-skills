# active_animation_culler.gd
# High-performance: Disabling AnimationPlayers when not visible [317]
extends VisibleOnScreenNotifier3D

@onready var anim_player: AnimationPlayer = get_node("../AnimationPlayer")

func _ready() -> void:
	screen_entered.connect(_on_visible)
	screen_exited.connect(_on_invisible)

func _on_visible() -> void:
	# Resume processing
	anim_player.active = true
	# Optional: speed up to catch up to global sync time if needed
	# anim_player.advance(delta_since_exit)

func _on_invisible() -> void:
	# Disabling 'active' stops all track processing saving CPU/GPU
	# significantly more than 'pause()'.
	anim_player.active = false
