# text_reveal_effect.gd
# Custom RichTextEffect for engaging content reveals
@tool
extends RichTextEffect
class_name RichTextWobble

# EXPERT NOTE: Custom effects allow for 'game-ifying' 
# educational text reading for younger users.

var bbcode = "wobble"

func _process_custom_fx(char_fx):
	var speed = char_fx.env.get("speed", 5.0)
	var freq = char_fx.env.get("freq", 2.0)
	char_fx.offset.y += sin(char_fx.elapsed_time * speed + char_fx.relative_index * freq) * 2.0
	return true
