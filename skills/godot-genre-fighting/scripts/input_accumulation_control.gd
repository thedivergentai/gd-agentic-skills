# input_accumulation_control.gd
# Disabling OS input merging for raw frame-perfect polling
extends Node

# EXPERT NOTE: Input accumulation merges events to the framerate. 
# Disabling it is vital for frame-perfect Fighting game inputs.

func _ready():
	# Ensuring every button press is parsed exactly as it arrived
	Input.use_accumulated_input = false

func _physics_process(_delta):
	# Optional: flush if you need absolute immediate state
	# Input.flush_buffered_events()
	pass
