# manual_animation_advancer.gd
# Syncing animations strictly to physics/rollback frames
extends AnimationMixer

# EXPERT NOTE: For determinism, stop child AnimationPlayers 
# and manually call advance() inside _physics_process().

func _ready():
	callback_mode_process = ANIMATION_CALLBACK_MODE_PROCESS_MANUAL

func step_animation(delta: float):
	# Advancing by fixed delta to ensure frame-sync with logic
	advance(delta)
