class_name HapticManager
extends Node

## Expert Mobile Haptic Feedback Manager
## Godot supports Android vibration out of the box. 
## iOS requires specific native plugins (like iOSHaptics), but we abstract the concept here.

enum HapticType {
    LIGHT_TICK,
    MEDIUM_BUMP,
    HEAVY_CRASH,
    SUCCESS_BUZZ
}

static func trigger(type: HapticType) -> void:
    if not OS.has_feature("mobile"):
        return
        
    var duration_ms: int = 0
    match type:
        HapticType.LIGHT_TICK:
            duration_ms = 15
        HapticType.MEDIUM_BUMP:
            duration_ms = 40
        HapticType.HEAVY_CRASH:
            duration_ms = 100
        HapticType.SUCCESS_BUZZ:
            duration_ms = 250
            
    # Native Android Vibration
    if OS.get_name() == "Android":
        Input.vibrate_handheld(duration_ms)
        
    # Example iOS Plugin Hook (assuming a plugin named "iOSHaptics" is installed)
    elif OS.get_name() == "iOS":
        if Engine.has_singleton("iOSHaptics"):
            var ios_haptics = Engine.get_singleton("iOSHaptics")
            # Usually plugins map to UI selection, impact, or notification haptics
            ios_haptics.impact(int(type))
