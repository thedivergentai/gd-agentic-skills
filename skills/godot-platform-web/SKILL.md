---
name: godot-platform-web
description: "Expert blueprint for web/browser platforms (HTML5 export) covering WebGL/WebGPU rendering, custom loading screens, JavaScriptBridge integration, LocalStorage saves, and size optimization. Use when exporting to web or implementing browser-specific features. Keywords web, HTML5, WebGL, WebGPU, JavaScriptBridge, localStorage, canvas, browser API."
---

# Platform: Web

Browser API integration, LocalStorage persistence, and size optimization define web deployment.

## NEVER Do (Expert Web Rules)

### Persistence & Storage
- **NEVER use FileAccess for persistent saves** — Browsers sandbox the filesystem. Standard `FileAccess` to `user://` is unreliable. Always use `JavaScriptBridge` for `localStorage` or `IndexedDB`.
- **NEVER assume localStorage is permanent** — Browsers may purge local storage if space is low. Always implement a cloud-save fallback for production titles.

### Rendering & Logic
- **NEVER use the Forward+ renderer** — Forward+ requires Vulkan features that are unstable in browsers. Use the **Compatibility** (WebGL 2.0) renderer for consistent 60 FPS.
- **NEVER block the browser event loop** — Long-running sync logic will cause the browser to prompt the user to "Kill the Page." Use `await` and background tasks.
- **NEVER ignore the COOP/COEP header requirement** — Multi-threading and `SharedArrayBuffer` will fail on many hosts unless cross-origin isolation is configured server-side.

### UX & Security
- **NEVER forget to handle tab focus loss** — Audio playing in a hidden background tab is poor UX. Use `visibilitychange` to pause audio.
- **NEVER trigger Fullscreen/Mouse Lock without click** — Browsers block security-sensitive requests unless they are inside a direct user interaction event.
- **NEVER use absolute paths in HTML shells** — Use relative paths to ensure the game works when hosted in sub-directories.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [web_javascript_bridge_callback.gd](scripts/web_javascript_bridge_callback.gd)
Expert two-way JS-to-GD communication using `create_callback`.

### [web_local_storage_wrapper.gd](scripts/web_local_storage_wrapper.gd)
Robust `localStorage` handler with JSON serialization and quota error prevention.

### [web_responsive_canvas_adaptor.gd](scripts/web_responsive_canvas_adaptor.gd)
Dynamic canvas resizing to match browser window dimensions via JS.

### [web_browser_input_guard.gd](scripts/web_browser_input_guard.gd)
Preventing browser default behaviors (Right-click menu, Spacebar scroll).

### [web_resource_lazy_loader.gd](scripts/web_resource_lazy_loader.gd)
Lazy loading of remote PCKs and resources using browser-fetch logic.

### [web_clipboard_interface.gd](scripts/web_clipboard_interface.gd)
Asynchronous clipboard (Copy/Paste) integration via the `Navigator` API.

### [web_visibility_auto_pause.gd](scripts/web_visibility_auto_pause.gd)
Visibility API integration to auto-pause engine and audio on tab hide.

### [web_navigation_guard.gd](scripts/web_navigation_guard.gd)
Navigation guard using `beforeunload` to prevent closing on unsaved progress.

### [web_external_url_opener.gd](scripts/web_external_url_opener.gd)
Expert URL opening using `window.open` with `noopener` security flags.

### [web_performance_profiler.gd](scripts/web_performance_profiler.gd)
Browser performance tracking (VRAM, Draw calls) logged to JS console.

---

```html
<!-- index.html custom loading -->
<div id="loading-screen">
    <div class="progress-bar">
        <div id="progress" style="width: 0%"></div>
    </div>
    <p id="status-text">Loading...</p>
</div>

<script>
const engine = new Engine(CONFIG);
engine.startGame({
    onProgress: function(current, total) {
        const percent = Math.floor((current / total) * 100);
        document.getElementById('progress').style.width = percent + '%';
        document.getElementById('status-text').innerText = `Loading ${percent}%`;
    }
}).then(() => {
    document.getElementById('loading-screen').style.display = 'none';
});
</script>
```

## Browser Integration

```gdscript
# Check if running in browser
if OS.has_feature("web"):
    # Web-specific code
    JavaScriptBridge.eval("console.log('Running in browser')")
```

## LocalStorage Save

```gdscript
func save_to_browser() -> void:
    if not OS.has_feature("web"):
        return
    
    var data := JSON.stringify(get_save_data())
    JavaScriptBridge.eval("localStorage.setItem('savegame', '%s')" % data)

func load_from_browser() -> Dictionary:
    if not OS.has_feature("web"):
        return {}
    
    var data_str := JavaScriptBridge.eval("localStorage.getItem('savegame')")
    if data_str:
        return JSON.parse_string(data_str)
    return {}
```

## Size Optimization

```ini
# Minimize build size
[rendering]
textures/vram_compression/import_s3tc_bptc=false
textures/vram_compression/import_etc2_astc=true

# Exclude unnecessary exports
[export_preset]
exclude_filter="*.md,*.txt,docs/*"
```

## Performance

- **Target 60 FPS** on mid-range browsers
- **Limit godot-particles** - WebGL has lower limits
- **Reduce draw calls**
- **Avoid large textures**

## Best Practices

1. **Loading Screen** - Users expect feedback
2. **File Size** - Keep under 50MB
3. **Mobile Web** - Test on phones
4. **HTTPS** - Required for many APIs

## Reference
- Related: `godot-export-builds`, `godot-platform-mobile`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
