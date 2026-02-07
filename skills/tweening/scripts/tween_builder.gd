# skills/tweening/scripts/tween_builder.gd
extends Node

## Tween Builder Expert Pattern
## Fluent API for complex tween chains with parallel and sequential operations.

class_name TweenBuilder

static func create_sequential() -> Tween:
	var tween := Engine.get_main_loop().create_tween()
	tween.set_parallel(false)
	return tween

static func create_parallel() -> Tween:
	var tween := Engine.get_main_loop().create_tween()  
	tween.set_parallel(true)
	return tween

static func fade_out(node: CanvasItem, duration := 0.5) -> Tween:
	var tween := create_sequential()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	return tween

static func fade_in(node: CanvasItem, duration := 0.5) -> Tween:
	var tween := create_sequential()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween

static func bounce_scale(node: Node, duration := 0.3, scale_multiplier := 1.2) -> Tween:
	var original_scale = node.scale if node.has("scale") else Vector2.ONE
	var tween := create_sequential()
	tween.tween_property(node, "scale", original_scale * scale_multiplier, duration * 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.5)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	return tween

static func shake(node: Node2D, duration := 0.3, intensity := 5.0) -> Tween:
	var original_pos := node.position
	var tween := create_sequential()
	
	var shake_count := int(duration / 0.05)
	for i in shake_count:
		var offset := Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(node, "position", original_pos + offset, 0.05)
	
	tween.tween_property(node, "position", original_pos, 0.05)
	return tween

static func chain_with_callback(tweens: Array[Tween], callbacks: Array[Callable]) -> void:
	if tweens.size() != callbacks.size():
		push_error("Tween and callback arrays must match in size")
		return
	
	for i in tweens.size():
		if i < callbacks.size() and callbacks[i].is_valid():
			tweens[i].finished.connect(callbacks[i])

## EXPERT USAGE:
## # Simple fade
## TweenBuilder.fade_out($Sprite)
## 
## # Button press feedback
## TweenBuilder.bounce_scale($Button, 0.2, 1.1)
## 
## # Complex chain
## var t1 := TweenBuilder.fade_in($Panel)
## var t2 := TweenBuilder.bounce_scale($Panel/Title)
## t1.finished.connect(func(): t2.play())
