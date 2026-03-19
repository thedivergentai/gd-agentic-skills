# responsive_tag_cloud.gd
# Wrapping item lists using HFlowContainer [8, 15]
extends HFlowContainer

func populate_tags(tags: Array[String]) -> void:
	# Clear existing
	for child in get_children(): child.queue_free()
	
	# HFlowContainer automatically wraps items to next line 
	# based on available width.
	last_wrap_alignment = FlowContainer.LAST_WRAP_ALIGNMENT_BEGIN
	
	for tag_text in tags:
		var lbl = Label.new()
		lbl.text = "#" + tag_text
		add_child(lbl)
