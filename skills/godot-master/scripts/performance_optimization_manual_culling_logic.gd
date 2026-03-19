# manual_culling_logic.gd
# Disabling off-screen logic manually
extends VisibleOnScreenNotifier2D

# EXPERT NOTE: VisibilityNotifiers are the most efficient 
# way to cull heavy _process or _physics_process logic 
# when nodes are not visible to the camera.

func _ready():
	screen_entered.connect(_on_screen_entered)
	screen_exited.connect(_on_screen_exited)

func _on_screen_entered():
	set_process(true)
	set_physics_process(true)

func _on_screen_exited():
	set_process(false)
	set_physics_process(false)
