# godot-master/scripts/ui_rich_text_custom_bbcode_effect.gd
extends RichTextEffect
class_name RichTextRainbow

## UI RichText Expert Pattern
## Implements Custom RichTextEffect and Metadata Handling.

# 1. Custom BBCode Tags
# Tag usage: [rainbow freq=1.0 sat=0.8 val=0.8]Text[/rainbow]
var bbcode = "rainbow"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# Expert logic: Manipulate character properties over time.
	var freq = char_fx.env.get("freq", 1.0)
	var sat = char_fx.env.get("sat", 0.8)
	var val = char_fx.env.get("val", 0.8)
	
	var hue = fmod(char_fx.elapsed_time * freq + char_fx.range_index * 0.1, 1.0)
	char_fx.color = Color.from_hsv(hue, sat, val)
	
	return true

# 2. Programmatic Tag Injection (Keyword Highlighting)
func highlight_keywords(text: String, keywords: Array[String], color_hex: String) -> String:
	# Professional protocol: Use regex to wrap keywords in BBCode tags.
	var result = text
	for word in keywords:
		var regex = RegEx.new()
		regex.compile("\\b" + word + "\\b")
		result = regex.sub(result, "[color=#" + color_hex + "][b]" + word + "[/b][/color]", true)
	return result

# 3. Meta-Intent Handling
func _on_meta_clicked(meta: Variant) -> void:
	# Professional protocol: Handle interactive text links (e.g. Quest items).
	if meta is String:
		print("Player clicked on a RichText link: ", meta)
		# Signal the GameController or DialogueSystem
		# DialogueEventBus.text_link_activated.emit(meta)

## EXPERT NOTE:
## Use 'Animated Typewriter Effects': Combine 'visible_ratio' with 
## custom 'char_fx' to create ghostly fades or jittery typewriter 
## motion for horror or sci-fi dialogue.
## For 'ui-rich-text', implement a 'Dynamic Color Bus': Use BBCode 
## colors that reference a global Theme variable via a lookup script 
## to allow for "Night Mode" text color swaps.
## NEVER build complex UI layouts using only RichTextLabel; 
## use it ONLY for body text and use Containers for buttons 
## and iconography to ensure responsive layouts.
## Use 'bbcode_enabled = true' and 'install_effect()' to register 
## your custom effects at runtime.
