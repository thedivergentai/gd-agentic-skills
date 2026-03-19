# safe_type_casting.gd
# Using 'as' for crash-proof object identification
extends Area2D

# EXPERT NOTE: Avoid 'is' followed by a hard cast. Use 'as' and 
# check for null to prevent runtime crashes on mismatch.

func _on_body_entered(body: Node2D) -> void:
	# Safe cast: returns null if body is not the class/script
	var player := body as CharacterBody2D
	
	if player and player.has_method("apply_damage"):
		player.call("apply_damage", 10)
	else:
		# Not a player, ignore safely
		pass
