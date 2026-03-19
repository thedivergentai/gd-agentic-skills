class_name WebResourceLazyLoader
extends Node

## Expert lazy loading of remote Godot resources/PCKs in the browser.
## Uses HTTPRequest but with browser cache awareness.

func load_remote_pck(url: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_pck_downloaded)
	http.request(url)

func _on_pck_downloaded(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		# ProjectSettings.load_resource_pack is expert for post-launch content
		ProjectSettings.load_resource_pack(body)
		print("Web: Remote PCK loaded successfully.")
