# animated_container_shuffle.gd
# Shuffling items inside a container via code-driven sibling reordering
extends VBoxContainer

func shuffle_children() -> void:
	var children = get_children()
	children.shuffle()
	
	for i in range(children.size()):
		# move_child triggers the Container's sort notification
		move_child(children[i], i)
	
	# Optional: Trigger a slight scale bounce for feedback
	for child in get_children():
		var tween = create_tween()
		tween.tween_property(child, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(child, "scale", Vector2.ONE, 0.1)
