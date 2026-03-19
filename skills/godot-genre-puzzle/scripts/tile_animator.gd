# tile_animator.gd
extends Node
class_name TileAnimator

# Safe Tween Callbacks for Move Validation
# Uses First-Class Callables to securely chain animation logic.

func animate_tile_removal(node: Node2D, target_dict: Dictionary) -> void:
    var tween := get_tree().create_tween()
    tween.tween_property(node, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
    
    # Pattern: Use Callable.create for methods of built-in types.
    tween.tween_callback(Callable.create(target_dict, "clear"))
    tween.tween_callback(node.queue_free)
