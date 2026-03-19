class_name WebClipboardInterface
extends Node

## Expert browser clipboard integration via Navigator API.
## Handles asynchronous Copy and Paste operations.

func copy_text(text: String) -> void:
	if not OS.has_feature("web"): return
	
	JavaScriptBridge.eval("""
		navigator.clipboard.writeText('%s').then(() => {
			console.log('Web: Text copied to clipboard');
		});
	""" % text)

func paste_text_async(callback_obj: Object, callback_method: String) -> void:
	# Paste requires explicit user permission check in browsers
	var js_callback := JavaScriptBridge.create_callback(func(args):
		callback_obj.call(callback_method, args[0])
	)
	var window := JavaScriptBridge.get_interface("window")
	window.pasteToGodot(js_callback)

## Rule: 'navigator.clipboard' requires a secure (HTTPS) context.
