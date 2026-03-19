# viewport_3d_preview.gd
# Responsive 3D-in-UI setup using SubViewportContainer [3, 11]
extends SubViewportContainer

@onready var viewport: SubViewport = $SubViewport

func _ready() -> void:
	# stretch = true: The internal viewport size follows the UI container [3]
	stretch = true
	# stretch_shrink: Renders at half resolution for performance while 
	# maintaining UI crispness.
	stretch_shrink = 2 
	
	# Ensure background transparency for HUD overlays
	viewport.transparent_bg = true
