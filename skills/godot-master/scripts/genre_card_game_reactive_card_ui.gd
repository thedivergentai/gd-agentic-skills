# reactive_card_ui.gd
# Automatically updating UI nodes via Resource listeners
extends Control

@export var data: CardData

@onready var label = $NameLabel

func _ready():
	# EXPERT: React to data changes from ANY system
	data.changed.connect(_update_ui)
	_update_ui()

func _update_ui():
	label.text = data.card_name
	print("UI Refreshed for ", data.card_name)
