# Expert One-Frame Glitch Sync Fix
extends Node2D

## When playing an animation and changing a property (like flip_h) in the same frame,
## play() is queued and doesn't apply until the next frame, causing a glitch.
## Use advance(0) to force an immediate application.

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func change_animation_and_flip(anim_name: String, should_flip: bool) -> void:
	sprite.flip_h = should_flip
	anim_player.play(anim_name)
	
	# CRITICAL: Forces the AnimationPlayer to apply the first frame of the NEW animation
	# using the NEW flip_h state IMMEDIATELY. Eliminates the 1-frame "ghosting" pose.
	anim_player.advance(0)

func force_sync_method_tracks() -> void:
	# advance(0) also triggers method tracks at the very start of the animation
	# ensuring SFX or logic triggers don't wait for the next engine tick.
	anim_player.play("attack")
	anim_player.advance(0)
