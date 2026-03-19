# custom_radial_container.gd
# Custom Container logic implementing a radial/circle layout [18]
extends Container

@export var radius: float = 120.0

func _notification(what: int) -> void:
	# Intercept the layout sort signal
	if what == NOTIFICATION_SORT_CHILDREN:
		_do_radial_sort()

func _do_radial_sort() -> void:
	var children := get_children()
	if children.is_empty(): return
	
	var center := size / 2.0
	var step := TAU / children.size()
	
	for i in range(children.size()):
		var child = children[i] as Control
		if not child or not child.visible: continue
		
		# Calculate polar position
		var angle = i * step
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		
		# Center child on point
		var min_size = child.get_combined_minimum_size()
		var rect = Rect2(pos - (min_size / 2.0), min_size)
		
		# CRITICAL: Always use fit_child_in_rect to enforce layout [18]
		fit_child_in_rect(child, rect)
