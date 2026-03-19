class_name WebExternalURLOpener
extends Node

## Expert utility to open external URLs from a web export.
## Ensures 'noopener' and 'noreferrer' are used for security.

func open_url(url: String, new_tab: bool = true) -> void:
	if not OS.has_feature("web"):
		OS.shell_open(url)
		return
	
	var target := "_blank" if new_tab else "_self"
	JavaScriptBridge.eval("window.open('%s', '%s', 'noopener,noreferrer');" % [url, target])

## Rule: Most browsers block window.open unless triggered by a click/keypress.
