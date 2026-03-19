# Floating Point Precision Fix (Z-fighting)
extends Camera3D

## Flickering textures (Z-fighting) occur when surfaces are too close.
## Compressing the Viewport precision range fixes this for distant terrain.

func optimize_depth_precision() -> void:
	# Architecture Tip: Increase Near as much as usable, 
	# and decrease Far as much as possible.
	near = 0.5  # Default 0.05 is too small for large scenes
	far = 500.0 # Default 4000 is way too high for standard indoor/limited outdoor
	
	# This compresses the depth buffer range and grants 
	# significantly more precision per unit of distance.
