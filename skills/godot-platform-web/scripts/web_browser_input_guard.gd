class_name WebBrowserInputGuard
extends Node

## Expert input guard to prevent browser default behaviors.
## Disables context menu (right-click) and spacebar scrolling.

func _ready() -> void:
	if not OS.has_feature("web"): return
	
	JavaScriptBridge.eval("""
		window.addEventListener('contextmenu', e => e.preventDefault());
		window.addEventListener('keydown', function(e) {
			if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
				e.preventDefault();
			}
		}, false);
	""")

## Rule: Only disable defaults if your game fully handles these inputs.
