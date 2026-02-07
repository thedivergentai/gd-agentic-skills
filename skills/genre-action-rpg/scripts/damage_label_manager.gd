# skills/genre-action-rpg/scripts/damage_label_manager.gd
extends Node2D

## Damage Label Manager
## High-performance pooling system for floating damage numbers.

class_name DamageLabelManager

@export var label_scene: PackedScene
@export var pool_size: int = 50
@export var float_speed: float = 50.0
@export var fade_duration: float = 0.5
@export var crit_color: Color = Color.ORANGE
@export var normal_color: Color = Color.WHITE

var _pool: Array[Node2D] = []
var _active_labels: Array[Node2D] = []

func _ready() -> void:
	if not label_scene: return
	
	for i in pool_size:
		var lbl = label_scene.instantiate()
		lbl.visible = false
		lbl.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(lbl)
		_pool.append(lbl)

func spawn_label(pos: Vector2, amount: int, is_crit: bool = false) -> void:
    var lbl = _get_label()
    if not lbl: return # Pool exhausted
    
    lbl.global_position = pos
    lbl.visible = true
    lbl.process_mode = Node.PROCESS_MODE_INHERIT
    lbl.modulate = Color(1, 1, 1, 1) # Reset alpha
    lbl.scale = Vector2.ONE
    
    # Assumes scene has a Label node named "Value"
    var val_node = lbl.get_node_or_null("Value")
    if val_node:
        val_node.text = str(amount)
        val_node.modulate = crit_color if is_crit else normal_color
        if is_crit:
            lbl.scale = Vector2(1.5, 1.5)
            
    # Animate
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(lbl, "position:y", lbl.position.y - 50, fade_duration).set_trans(Tween.TRANS_OUT).set_ease(Tween.EASE_OUT)
    tween.tween_property(lbl, "modulate:a", 0.0, fade_duration).set_delay(fade_duration * 0.5)
    tween.chain().tween_callback(_return_to_pool.bind(lbl))

func _get_label() -> Node2D:
    if _pool.is_empty():
        # Optional: Expand pool dynamically or steal oldest active
        return null
    return _pool.pop_back()

func _return_to_pool(lbl: Node2D) -> void:
    lbl.visible = false
    lbl.process_mode = Node.PROCESS_MODE_DISABLED
    _pool.append(lbl)

## EXPERT USAGE:
## Add to Main Scene (CanvasLayer). 
## Call `DamageLabelManager.spawn_label(enemy.global_position, 100)`
