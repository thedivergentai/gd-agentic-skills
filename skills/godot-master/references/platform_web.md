> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Platform: Web**. Accessed via Godot Master.

# Platform: Web

Expert blueprint for browser-based distribution. Addresses JavaScript/GDScript bridging, `localStorage` persistence, size optimization, and Web-specific threading limitations.

## Available Scripts

### [web_bridge_sync.gd](../scripts/platform_web_web_bridge_sync.gd)
Expert component for bridging the gap between Godot and the Browser environment. Utilizes `JavaScriptBridge` to handle browser-specific persistence (localStorage), custom analytics triggers, and window-level UI interactions.


## NEVER Do

- **NEVER use standard `FileAccess` for saving data on Web** — The browser sandbox strictly prevents direct disk write access. Attempting to save to `user://` works in some contexts but for maximum reliability, you MUST use `JavaScriptBridge` to write to the browser's **localStorage**.
- **NEVER use the default Godot loading screen for production** — A generic grey "Downloading" bar with a 30MB WASM file will cause users to leave. You MUST customize the `index.html` template to provide a branded, informative progress bar.
- **NEVER rely on multi-threading for the web export** — While Godot 4 supports threading on Web via `SharedArrayBuffer` (SAB), it requires specific COOP/COEP headers on your server. To ensure maximum compatibility across Itch.io and diverse hosts, avoid using the `Thread` class in web builds.
- **NEVER forget that HTTPS is required for critical APIs** — Browser security prevents access to Gamepad, Clipboard, and Audio APIs on non-secure `http://` sites (except for `localhost`). Always serve your web build over **HTTPS**.
- **NEVER exceed 50-70MB for the initial load** — Long download times are the primary reason for high "bounce rates" on web games. Compress textures aggressively using ETC2/ASTC and strip unused assets from your export filter.
- **NEVER hardcode your window or viewport size** — Players' browser windows change size constantly. Use responsive UI anchors and listen to `get_window().size_changed` to reflow elements on the fly.

---

## JavaScriptBridge Communication
Communicate with the surrounding webpage:
- `var result = JavaScriptBridge.eval("window.innerWidth")`
- Create callback objects for JavaScript to call GDScript: `JavaScriptBridge.create_callback(_on_js_call)`.

## Data Persistence (localStorage)
Since `user://` is ephemeral or unreliable on some browsers:
1. Stringify your data to JSON.
2. Call `JavaScriptBridge.eval("localStorage.setItem('my_game_save', '" + json_str + "')")`.
3. Retrieve data using `JavaScriptBridge.eval("localStorage.getItem('my_game_save')")`.

## Performance Benchmarking
Web builds run significantly slower than native exports due to the WASM translation layer.
- Minimize draw calls.
- Use **Vulkan Compatibility** (OpenGL) renderer for the widest device support.
- Profile using the browser's developer tools (Performance tab) to identify bottlenecks.

## Customizing index.html
Export with a custom HTML template to:
- Style the `<canvas>` element.
- Add "Fullscreen" or "Mute" buttons outside the Godot viewport.
- Provide a smooth transition between the loading bar and the game's start screen.

## Reference
- [Godot Docs: Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Godot Docs: JavaScriptBridge](https://docs.godotengine.org/en/stable/classes/class_javascriptbridge.html)
