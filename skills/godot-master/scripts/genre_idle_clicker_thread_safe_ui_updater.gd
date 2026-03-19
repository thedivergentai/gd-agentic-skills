# thread_safe_ui_updater.gd
extends Node

# Thread-Safe UI Update Pattern
# Safely propagates data from background simulations to main-thread UI nodes.
@onready var currency_label: Label = Label.new()

func update_display_deferred(new_value_string: String) -> void:
    # NEVER set .text directly from a thread. 
    # call_deferred ensures the update happens on the next frame in the main thread.
    currency_label.call_deferred("set_text", "Balance: " + new_value_string)
