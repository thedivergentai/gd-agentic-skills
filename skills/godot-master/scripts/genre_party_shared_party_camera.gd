# shared_party_camera.gd
extends Camera2D
class_name SharedPartyCamera

# Shared-Screen Dynamic Camera (2D)
# Manages zoom and positioning based on the bounding box of all players.

@export var min_zoom := 0.5
@export var max_zoom := 2.0
@export var margin := Vector2(100, 100)

func _process(_delta: float) -> void:
    var players := get_tree().get_nodes_in_group(&"players")
    if players.is_empty(): return
    
    # Calculate bounding box for all players.
    var bounds := Rect2(players[0].global_position, Vector2.ZERO)
    for p in players:
        bounds = bounds.expand(p.global_position)
        
    # Center camera on the party.
    global_position = bounds.get_center()
    
    # Update zoom to fit everyone.
    var screen_size := get_viewport_rect().size
    var target_size := bounds.size + margin * 2.0
    var zoom_f := minf(screen_size.x / target_size.x, screen_size.y / target_size.y)
    
    zoom = Vector2.ONE * clampf(zoom_f, min_zoom, max_zoom)
