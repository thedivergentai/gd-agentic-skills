---
name: godot-platform-web
description: "Expert blueprint for web/browser platforms (HTML5 export) covering WebGL/WebGPU rendering, custom loading screens, JavaScriptBridge integration, LocalStorage saves, and size optimization. Use when exporting to web or implementing browser-specific features. Keywords web, HTML5, WebGL, WebGPU, JavaScriptBridge, localStorage, canvas, browser API."
---

# Platform: Web

Browser API integration, LocalStorage persistence, and size optimization define web deployment.

## Available Scripts

### [web_bridge_sync.gd](scripts/web_bridge_sync.gd)
Expert JavaScriptBridge helpers for browser API integration (persistence, analytics).

## NEVER Do in Web Development

- **NEVER use FileAccess for saves** — `FileAccess.open("user://save.dat")` on web? Browser sandbox blocks filesystem. Use JavaScriptBridge + localStorage.
- **NEVER forget loading screen** — 20MB wasm download with default load screen = user closes tab. MUST customize index.html with progress bar + brand assets.
- **NEVER  use threads** — `Thread.new()` on web? Not supported. Use `await` for async OR split work across frames with `await get_tree().process_frame`.
- **NEVER ignore HTTPS requirement** — Geolocation, microphone, webcam APIs REQUIRE HTTPS. Local `http://` = APIs blocked. Use `localhost` OR HTTPS.
- **NEVER exceed 50MB build size** — 100MB WebAssembly = user rage-quits during load. Compress textures (ETC2/ASTC), exclude unused assets.
- **NEVER hardcode window size** — `get_viewport().size = Vector2(1920, 1080)` on web? Breaks mobile browsers. Use `get_window().size_changed` + responsive UI.

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
