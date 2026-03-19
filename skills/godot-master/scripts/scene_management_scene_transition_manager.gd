# scene_transition_manager.gd
# Smooth transitions between scenes using Tweens/Shaders
extends CanvasLayer

@onready var color_rect := $ColorRect

func transition_to(scene_path: String):
	# Fade to black
	var tween = create_tween()
	await tween.tween_property(color_rect, "color:a", 1.0, 0.5).finished
	
	get_tree().change_scene_to_file(scene_path)
	
	# Fade back in
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 0.5)
