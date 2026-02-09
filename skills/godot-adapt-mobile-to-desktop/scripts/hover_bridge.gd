# skills/adapt-mobile-to-desktop/scripts/hover_bridge.gd
extends Node

## Hover Bridge Expert Pattern
## Re-enables desktop hover interactions for shared codebases.
## Mobile usually ignores mouse_entered/exited; this bridges the gap.

class_name HoverBridge

signal hover_state_changed(node: Control, is_hovering: bool)

@export var hover_scale: float = 1.1
@export var hover_color: Color = Color(1.2, 1.2, 1.2) # Brighten
@export var animate: bool = true

var _original_scales: Dictionary = {}
var _original_modulates: Dictionary = {}

func _ready() -> void:
    if not (OS.has_feature("pc") or OS.has_feature("web_pc")):
        set_process(false)
        return
        
    # Auto-connect to all hoverable buttons in group
    for node in get_tree().get_nodes_in_group("hoverable"):
        connect_node(node)
        
    get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
    if node.is_in_group("hoverable"):
        connect_node(node)

func connect_node(node: Control) -> void:
    if node.mouse_entered.is_connected(_on_mouse_entered.bind(node)):
        return
        
    node.mouse_entered.connect(_on_mouse_entered.bind(node))
    node.mouse_exited.connect(_on_mouse_exited.bind(node))
    
    # Store originals
    _original_scales[node.get_instance_id()] = node.scale
    _original_modulates[node.get_instance_id()] = node.modulate

func _on_mouse_entered(node: Control) -> void:
    hover_state_changed.emit(node, true)
    
    if animate:
        var tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(node, "scale", _original_scales[node.get_instance_id()] * hover_scale, 0.1)
        tween.tween_property(node, "modulate", hover_color, 0.1)

func _on_mouse_exited(node: Control) -> void:
    hover_state_changed.emit(node, false)
    
    if animate:
        var tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(node, "scale", _original_scales[node.get_instance_id()], 0.1)
        tween.tween_property(node, "modulate", _original_modulates[node.get_instance_id()], 0.1)

## EXPERT USAGE:
## Add "hoverable" group to your UI buttons. AutoLoad this script.
## Instantly gives Desktop feel to Mobile-first UI.
