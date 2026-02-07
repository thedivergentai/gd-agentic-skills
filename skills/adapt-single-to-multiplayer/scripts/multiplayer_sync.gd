# skills/adapt-single-to-multiplayer/scripts/multiplayer_sync.gd
extends MultiplayerSynchronizer

## Multiplayer Sync Expert Pattern
## Optimized synchronization with interpolation and bandwidth management.

class_name ExpertMultiplayerSync

@export var interpolation_alpha: float = 0.5

# We assume the parent is the CharacterBody or Node3D to sync
@onready var parent: Node = get_parent()

# Buffer for interpolation
var _target_position: Vector3
var _target_rotation: Vector3
var _last_packet_time: float

func _ready() -> void:
	# Configure sync properties via code or editor
	# Usually: position, rotation, velocity (optional)
	
	# Only interpolate for non-authority (dumb clients)
	set_process(not is_multiplayer_authority())
	
	if not is_multiplayer_authority():
		_target_position = parent.position
		if parent is Node3D:
			_target_rotation = parent.rotation
		# Don't override physics on remote peers if using simple sync
		parent.set_physics_process(false)

func _process(delta: float) -> void:
	if parent is Node3D:
		parent.position = parent.position.lerp(_target_position, interpolation_alpha)
		parent.rotation = parent.rotation.lerp(_target_rotation, interpolation_alpha)
	elif parent is Node2D:
		parent.position = parent.position.lerp(_target_position, interpolation_alpha)
		parent.rotation = lerp_angle(parent.rotation, _target_rotation.z, interpolation_alpha)

# Note: The MultiplayerSynchronizer node automatically updates properties.
# However, to use interpolation, we often sync to a specific variable (e.g. sync_pos)
# instead of 'position' directly, then lerp 'position' to 'sync_pos' in process.
# This script demonstrates the pattern where we intercept the data.

# To make this work without extra variables, we can use signals if replication config supports it,
# OR we rely on a specific 'puppet_position' variable in the parent that is synced.

# Recommended Pattern:
# 1. Sync 'puppet_position' and 'puppet_rotation' (watch variables).
# 2. Parent script:
#    var puppet_position: Vector3
#    func _process(delta):
#       if not is_authority:
#           position = position.lerp(puppet_position, 0.5)

## EXPERT USAGE:
## Attach to MultiplayerSynchronizer. Set replication config to sync 
## `puppet_position` on the parent, not directly `position`, to enable smoothing.
