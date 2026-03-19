# performance_anchor_layout.gd
# Optimization: Replacing heavy nested containers with Anchor Layouts [16]
extends Control

# EXPERT NOTE: 10 levels of nested Containers (Margin > VBox > HBox) 
# cause massive recount/layout spikes. Use Anchors for static padding.

func setup_responsive_padding(padding: float = 20.0) -> void:
	# Full rect anchor
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Manual offsets act as responsive margins without the overhead 
	# of a MarginContainer node.
	offset_left = padding
	offset_top = padding
	offset_right = -padding
	offset_bottom = -padding
