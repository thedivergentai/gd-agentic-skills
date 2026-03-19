# skills/platform-vr/scripts/vr_physics_hand.gd
extends XRController3D

## VR Physics Hand Expert Pattern
## Physics-based hand interaction using Jolt/Godot Physics with velocity tracking.

class_name VRPhysicsHand

# Configuration
@export var pickup_layer: int = 1
@export var throw_velocity_multiplier: float = 1.3

# Nodes
@onready var _grab_area: Area3D = $GrabArea # Should be child
@onready var _hand_mesh: MeshInstance3D = $HandMesh

# State
var _held_object: RigidBody3D = null
var _previous_global_pos: Vector3
var _velocity: Vector3

func _ready() -> void:
	# Connect signals for standard OpenXR interaction
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)

func _physics_process(delta: float) -> void:
	# Calculate instantaneous velocity for throwing
	var current_pos = global_position
	if delta > 0:
		_velocity = (current_pos - _previous_global_pos) / delta
	_previous_global_pos = current_pos
	
	# If holding object, snap it to hand (Kinematic Grabbing)
	# Or apply force (Physics Grabbing) - Simple kinematic snap shown here
	if _held_object:
		# Keep object at hand transform
		_held_object.global_transform = global_transform

func _on_button_pressed(name: String) -> void:
	if name == "grip_click": # Standard grip button
		_try_grab()

func _on_button_released(name: String) -> void:
	if name == "grip_click":
		_drop()

func _try_grab() -> void:
	if _held_object: return
	
	# Find nearest grabbable
	var bodies = _grab_area.get_overlapping_bodies()
	var nearest: RigidBody3D = null
	var min_dist = INF
	
	for body in bodies:
		if body is RigidBody3D and body.collision_layer & pickup_layer:
			var dist = global_position.distance_to(body.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = body
	
	if nearest:
		_held_object = nearest
		_held_object.freeze = true # Disable physics while holding
		# Feedback
		trigger_haptic_pulse("haptic_grasp", 100.0, 0.1, 0.1, 0)

func _drop() -> void:
	if not _held_object: return
	
	_held_object.freeze = false
	# Apply throw velocity
	_held_object.linear_velocity = _velocity * throw_velocity_multiplier
	_held_object.angular_velocity = Vector3.ZERO # Optional spin
	
	_held_object = null

## EXPERT USAGE:
## Attach this script to LeftHand/RightHand nodes.
## Ensure child 'GrabArea' exists with collision shape.
