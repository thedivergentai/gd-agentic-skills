# adaptive_ui_anchors.gd
# Managing UI scaling across different screen factors
extends Control

# EXPERT NOTE: Anchoring is essential for educational apps 
# that must run on tablets (Landscape) and phones (Portrait).

func _ready():
	# Programmatic anchoring for dynamic UI generation
	anchor_left = 0.5
	anchor_right = 0.5
	offset_left = -200
	offset_right = 200 # Centered 400px panel
	grow_horizontal = GROW_DIRECTION_BOTH
