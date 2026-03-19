class_name OfflineSaveSync
extends Node

## Expert Mobile Save Data Manager
## Mobile OSs will aggressively terminate background apps. 
## You CANNOT rely on "save on exit" signals like `NOTIFICATION_WM_CLOSE_REQUEST` on iOS/Android.
## You must save immediately during `NOTIFICATION_APPLICATION_PAUSED` or proactively during gameplay.

const SAVE_PATH = "user://mobile_save.dat"
var game_data: Dictionary = {}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _load_game_data()

func _notification(what: int) -> void:
    match what:
        # App is being swiped away or put to sleep. SAVE NOW.
        NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
            _force_save_to_disk()

## Instead of saving to disk every time a coin is picked up (which causes stutter/battery drain),
## we update a memory Dictionary and only write to disk when backgrounded.
func update_data(key: String, value: Variant) -> void:
    game_data[key] = value

func _force_save_to_disk() -> void:
    var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, "secure_mobile_key_123!")
    if file:
        file.store_var(game_data)
        file.close()
        print("OfflineSave: Successfully saved during app pause.")
    else:
        push_error("OfflineSave: Failed to open save file during pause!")

func _load_game_data() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, "secure_mobile_key_123!")
        if file:
            game_data = file.get_var()
            file.close()
