extends Control

# Crisp Projected 2D UI for 3D Objects
# Instead of rendering a blurry text element in the 3D world, project its 3D coordinate onto the 2D Canvas screen space.

# The 3D target we want our 2D health bar to hover over
@export var target_3d: Node3D
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
    if not camera or not is_instance_valid(target_3d):
        return
        
    # Prevent the UI from showing if the object is behind the camera
    if camera.is_position_behind(target_3d.global_position):
        hide()
    else:
        show()
        # Translate the 3D world position to 2D screen coordinates
        var screen_pos: Vector2 = camera.unproject_position(target_3d.global_position)
        # Position the Control node on the 2D canvas
        global_position = screen_pos
