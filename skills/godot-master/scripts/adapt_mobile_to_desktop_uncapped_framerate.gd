extends Node
class_name UncappedFramerateController

## Expert Desktop Framerate Unlocker
## Mobile naturally caps at 60fps to save battery. PC gamers with 144Hz, 240Hz monitors
## demand uncapped framerates and toggleable V-Sync.

func apply_video_settings(use_vsync: bool, max_fps: int = 0) -> void:
    if use_vsync:
        # V-Sync ties the frame rate to monitor refresh rate (prevents tearing)
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
        Engine.max_fps = 0 # 0 means "unlocked", let V-Sync handle it
    else:
        # Mailbox mode is "fast v-sync" (renders unlimited frames but only displays the newest to prevent tearing)
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
        
        # If the user sets a hard cap (e.g. 144), enforce it here. 
        # A value of 0 entirely unlocks the engine, which can cause 1000+ FPS in menus and melt GPUs.
        Engine.max_fps = max_fps if max_fps > 0 else 0
        
    print("Framerate adjusted. VSync: ", use_vsync, " Max FPS: ", Engine.max_fps)
