# interactive_rich_text.gd
# Handling hyperlink clicks in educational content
extends RichTextLabel

# EXPERT NOTE: RichTextLabel meta_clicked signal allows for 
# interactive glossaries or pop-up definitions within text.

func _on_meta_clicked(meta):
	# meta can be a URL or a custom string tag
	if str(meta).begins_with("glossary:"):
		_show_definition(str(meta).split(":")[1])

func _show_definition(_term):
	# Display popup logic here
	pass
