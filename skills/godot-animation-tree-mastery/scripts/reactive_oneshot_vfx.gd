# reactive_oneshot_vfx.gd
# Using AnimationNodeOneShot for high-priority reactive animations
extends AnimationTree

# Use OneShot nodes for non-looping animations that should override the 
# current state (recoil, blinks, hit reactions).

func trigger_recoil() -> void:
	# OneShot nodes have a 'request' parameter
	# AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE = 1
	set("parameters/Recoil/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func cancel_oneshot(node_name: String) -> void:
	# AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT = 2
	set("parameters/" + node_name + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
