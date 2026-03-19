# dynamic_tab_manager.gd
# Expert management of TabContainer with runtime spawning and closing [13]
extends TabContainer

func add_session_tab(content: Control, title: String, icon: Texture2D) -> void:
	add_child(content)
	var idx := get_tab_idx_from_control(content)
	
	# Override default node-name titles with semantic names
	set_tab_title(idx, title)
	set_tab_icon(idx, icon)
	
	# Focus the new tab
	current_tab = idx

func close_focused_tab() -> void:
	var control := get_current_tab_control()
	if control:
		# TabContainer automatically removes the tab when the child is freed
		control.queue_free()
