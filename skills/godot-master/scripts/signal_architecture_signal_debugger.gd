# skills/signal-architecture/scripts/signal_debugger.gd
@tool
extends EditorScript

## Signal Debugger Expert Pattern
## Runtime signal connection analyzer and debugger.

func _run() -> void:
	print("=== Signal Connection Analyzer ===")
	
	var root := EditorInterface.get_edited_scene_root()
	if not root:
		printerr("No scene loaded in editor")
		return
	
	_analyze_node_signals(root, 0)

func _analyze_node_signals(node: Node, depth: int) -> void:
	var indent := "  ".repeat(depth)
	var signals_list := node.get_signal_list()
	
	if signals_list.size() > 0:
		print("\n%s📡 %s (%s)" % [indent, node.name, node.get_class()])
		
		for sig_info in signals_list:
			var sig_name: String = sig_info["name"]
			var connections := node.get_signal_connection_list(sig_name)
			
			if connections.size() > 0:
				print("%s  ✓ %s → %d connection(s)" % [indent, sig_name, connections.size()])
				
				for conn_info in connections:
					var target: Object = conn_info["callable"].get_object()
					var method: String = conn_info["callable"].get_method()
					var flags: int = conn_info["flags"]
					
					var flag_names: Array[String] = []
					if flags & CONNECT_ONE_SHOT:
						flag_names.append("ONE_SHOT")
					if flags & CONNECT_REFERENCE_COUNTED:
						flag_names.append("REF_COUNTED")
					if flags & CONNECT_DEFERRED:
						flag_names.append("DEFERRED")
					
					var flag_str := " [%s]" % ",".join(flag_names) if flag_names.size() > 0 else ""
					print("%s    → %s.%s()%s" % [indent, target if target else "?", method, flag_str])
			else:
				# Unused signal
				print("%s  ○ %s (not connected)" % [indent, sig_name])
	
	for child in node.get_children():
		_analyze_node_signals(child, depth + 1)

## EXPERT NOTE:
## This shows ALL signal connections in a scene at edit time.
## For runtime debugging, use signal_spy observer pattern.
## CRITICAL: Unused signals = code smell, remove or document why not connected.
