extends Node
class_name KeybindingRemapper

## Expert PC Input Remapping
## Mobile uses hardcoded on-screen button positions. PC requires full WASD/Key rebinding.

const SAVE_PATH = "user://keybinds.ini"

func _ready() -> void:
    _load_keybindings()

func rebind_action(action_name: String, new_event: InputEventKey) -> void:
    # 1. Clear old events for this action
    InputMap.action_erase_events(action_name)
    
    # 2. Assign the new key
    InputMap.action_add_event(action_name, new_event)
    
    # 3. Save to disk so bindings persist between sessions
    _save_keybindings()
    print("Rebound '", action_name, "' to keycode: ", new_event.keycode)

func _save_keybindings() -> void:
    var config = ConfigFile.new()
    for action in InputMap.get_actions():
        # Ignore built-in UI actions unless you want to rebind UI navigation
        if action.begins_with("ui_"): continue 
        
        var events = InputMap.action_get_events(action)
        if events.size() > 0 and events[0] is InputEventKey:
            config.set_value("Keybindings", action, events[0].keycode)
            
    config.save(SAVE_PATH)

func _load_keybindings() -> void:
    var config = ConfigFile.new()
    if config.load(SAVE_PATH) == OK:
        for action in config.get_section_keys("Keybindings"):
            var keycode = config.get_value("Keybindings", action)
            var event = InputEventKey.new()
            event.keycode = keycode
            
            InputMap.action_erase_events(action)
            InputMap.action_add_event(action, event)
