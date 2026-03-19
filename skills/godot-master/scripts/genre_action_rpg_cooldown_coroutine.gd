# cooldown_coroutine.gd
# Lightweight skill cooldowns without Node overhead
extends Node

# EXPERT NOTE: Timers as Nodes are heavy. Coroutines (await) 
# are lightweight and ephemeral.

var can_cast: bool = true

func fire_skill():
	if not can_cast: return
	
	_execute_logic()
	_start_cooldown(2.5)

func _start_cooldown(duration: float):
	can_cast = false
	await get_tree().create_timer(duration).timeout
	can_cast = true

func _execute_logic(): pass
