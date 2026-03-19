class_name WebNavigationGuard
extends Node

## Expert navigation guard for web games with unsaved state.
## Triggers a browser confirmation dialog if the user tries to close the tab.

func set_unsaved_changes(has_changes: bool) -> void:
	if not OS.has_feature("web"): return
	
	if has_changes:
		JavaScriptBridge.eval("""
			window.onbeforeunload = function() {
				return "You have unsaved changes. Are you sure you want to leave?";
			};
		""")
	else:
		JavaScriptBridge.eval("window.onbeforeunload = null;")

## Rule: Only enable this during active gameplay or editing sessions.
