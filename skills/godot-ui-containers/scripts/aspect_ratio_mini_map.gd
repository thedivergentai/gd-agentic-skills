# aspect_ratio_mini_map.gd
# Enforcing aspect ratios for UI elements across window resizes [12]
extends AspectRatioContainer

func _ready() -> void:
	# Forces a 1:1 square for a mini-map
	ratio = 1.0
	# STRETCH_FIT: Scales the child as large as possible without clipping
	stretch_mode = AspectRatioContainer.STRETCH_FIT
	alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
