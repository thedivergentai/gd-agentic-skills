class_name RichTextMetaDispatch
extends RichTextLabel

## Expert Meta Dispatcher for Complex Links.
## Routes [url=item:sword] or [url=quest:intro] to specific systems.

signal item_clicked(id: String)
signal quest_clicked(id: String)
signal npc_clicked(id: String)

func _ready() -> void:
	bbcode_enabled = true
	meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta_data: Variant) -> void:
	var data := str(meta_data).split(":")
	if data.size() < 2: return
	
	var type := data[0]
	var payload := data[1]
	
	match type:
		"item": item_clicked.emit(payload)
		"quest": quest_clicked.emit(payload)
		"npc": npc_clicked.emit(payload)
		_: push_warning("Unknown meta type: " + type)
