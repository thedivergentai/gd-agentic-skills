@tool
class_name RichTextRainbowEffect
extends RichTextEffect

## Expert Rainbow Text Effect.
## Syntax: [rainbow_fx freq=5.0 sat=0.8 val=0.8]Text[/rainbow_fx]

var bbcode := "rainbow_fx"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("freq", 5.0)
	var sat: float = char_fx.env.get("sat", 0.8)
	var val: float = char_fx.env.get("val", 0.8)
	
	# Calculate hue based on time and character index
	var hue: float = wrapf(char_fx.elapsed_time * freq + (char_fx.relative_index * 0.1), 0.0, 1.0)
	char_fx.color = Color.from_hsv(hue, sat, val, char_fx.color.a)
	
	return true
