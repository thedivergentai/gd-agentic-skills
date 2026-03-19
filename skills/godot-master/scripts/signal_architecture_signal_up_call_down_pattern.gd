# signal_up_call_down_pattern.gd
# Decoupling logic by restricting how nodes interact
extends Node

# EXPERT NOTE: "Signal Up" means children emit events. 
# "Call Down" means parents call child methods. 
# NEVER have a child call get_parent().method().

# --- CHILD SCRIPT Example (Player.gd) ---
# signal action_completed

# --- PARENT SCRIPT (Level.gd) ---
@onready var player = $Player

func _ready():
	# Parent calls down to initialize
	player.initialize_stats(100)
	# Parent listens to child events
	player.action_completed.connect(_on_player_action_completed)

func _on_player_action_completed():
	print("Player finished task. Level progressing.")
