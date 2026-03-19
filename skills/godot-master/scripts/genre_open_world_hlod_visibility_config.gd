# hlod_visibility_config.gd
extends Node
class_name HLODVisibilityConfig

# VisibilityRange (HLOD) Configuration
# Swaps high-poly geometry for low-poly impostors across distance boundaries.

@export var high_detail_node: GeometryInstance3D
@export var low_detail_node: GeometryInstance3D
@export var transition_dist: float = 150.0

func _ready() -> void:
    if not high_detail_node or not low_detail_node: return
    
    # High-detail mesh fades out at transition.
    high_detail_node.visibility_range_end = transition_dist
    high_detail_node.visibility_range_end_margin = 10.0
    high_detail_node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
    
    # Low-detail impostor fades in at transition.
    low_detail_node.visibility_range_begin = transition_dist
    low_detail_node.visibility_range_begin_margin = 10.0
    low_detail_node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DEPENDENCIES
