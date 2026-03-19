# debugger_tab_plugin.gd
# Injecting custom visual tabs into the bottom Debugger panel
@tool
extends EditorDebuggerPlugin

# EXPERT NOTE: This must be registered via an EditorPlugin 
# to take effect in the Godot Editor UI.

func _setup_session(session_id: int):
	var panel := VBoxContainer.new()
	panel.name = "MyTools"
	
	var label := Label.new()
	label.text = "Custom Debug Info"
	panel.add_child(label)
	
	var session := get_session(session_id)
	session.add_session_tab(panel)
