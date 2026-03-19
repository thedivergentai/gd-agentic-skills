class_name NativeShareInvoker
extends Node

## Expert OS-level sharing for Mobile.
## Proxies to native share sheets for text and images.

func share_text(text: String, title: String = "Share My Score") -> void:
	if OS.has_feature("android") or OS.has_feature("ios"):
		# Requires a native plugin (e.g., 'GodotShare')
		# This boilerplate shows the typical API call
		if Engine.has_singleton("GodotShare"):
			Engine.get_singleton("GodotShare").shareText(title, "Checkout my score!", text)
	else:
		print("Mobile: Native share only available on mobile devices.")
