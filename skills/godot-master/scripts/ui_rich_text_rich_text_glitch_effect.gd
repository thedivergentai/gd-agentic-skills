@tool
class_name RichTextGlitchEffect
extends RichTextEffect

## Expert Glitch/Horror Text Effect.
## Syntax: [glitch_fx level=2.0]Scary Text[/glitch_fx]

var bbcode := "glitch_fx"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var intensity: float = char_fx.env.get("level", 2.0)
	
	# High-frequency jitter
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(char_fx.relative_index + int(char_fx.elapsed_time * 15.0))
	
	char_fx.offset = Vector2(
		rng.randf_range(-intensity, intensity),
		rng.randf_range(-intensity, intensity)
	)
	
	# Random flickering
	if rng.randf() > 0.8:
		char_fx.color.a *= 0.3
		
	return true
