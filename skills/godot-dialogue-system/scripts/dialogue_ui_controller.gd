# dialogue_ui_controller.gd
# Visual rendering of conversation lines
extends Control

@onready var text_label = $TextLabel
@onready var options_container = $OptionsContainer

func _ready():
	DialogueManager.line_started.connect(_on_line_started)

func _on_line_started(node: DialogueNode):
	text_label.text = node.text
	_clear_options()
	for i in range(node.options.size()):
		var btn = Button.new()
		btn.text = node.options[i].text
		btn.pressed.connect(DialogueManager.select_option.bind(i))
		options_container.add_child(btn)

func _clear_options():
	for child in options_container.get_children():
		child.queue_free()
