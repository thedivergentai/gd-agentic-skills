> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Rhythm**. Accessed via Godot Master.

# Genre: Rhythm

Expert blueprint for high-precision rhythm games. Focuses on perfect audio-visual synchronization using `AudioServer` latency compensation, beat-mapping (chart) parsing, and timing-based judgment systems.

## Available Scripts

### [conductor_sync.gd](../scripts/godot-genre-rhythm_conductor_sync.gd)
The heartbeat of the rhythm game. A high-precision BPM conductor that compensates for audio hardware latency using `AudioServer.get_time_since_last_mix()`. Emits signals for every beat and measure.

### [rhythm_chart_parser.gd](../scripts/godot-genre-rhythm_rhythm_chart_parser.gd)
Professional JSON-based beatmap parser. Loads song data, sorts notes by their musical time (beats), and provides optimized range-querying for the "Note Highway" rendering system.


## NEVER Do

- **NEVER rely on `Time.get_ticks_msec()` for audio timing** — Standard system timers drift away from the actual audio playback. ALWAYS use `AudioStreamPlayer.get_playback_position()` combined with `AudioServer.get_time_since_last_mix()` for sub-frame accuracy.
- **NEVER use `_process()` or `_physics_process()` to capture inputs** — Standard polling is too slow and jittery for professional rhythm games. Use the `_input(event)` function to capture the exact timestamp of a button press.
- **NEVER forget "Latency Compensation" settings** — Every player's hardware setup (speakers vs. Bluetooth headphones) has different delay. You MUST provide a manual "Audio Offset" calibration menu in your settings.
- **NEVER use frame-based movement for the Note Highway** — If the framerate drops, your notes will desync. Note positions must be calculated dynamically based on the **Current Song Time** in every frame: `y = (chart_time - current_time) * scroll_speed`.
- **NEVER use tight timing windows (Perfect < 25ms) on all difficulties** — While 25ms is standard for expert players, it is frustrating for beginners. Use wider windows (100ms+) for lower difficulties.
- **NEVER use `AudioStreamPlayer` without `set_stream_paused(false)`** — When pausing the game, ensure the conductor is also paused, otherwise the visual notes will keep scrolling while the music stops.

---

## The BPM Conductor Pattern
The conductor translates **Seconds** into **Beats**:
```gdscript
var seconds_per_beat = 60.0 / bpm
var song_position_in_beats = current_song_seconds / seconds_per_beat
```
This is essential for syncing animations (e.g., character bops) to the music.

## The Note Highway (Receptors)
Nodes should scroll from a spawn point to a "Receptor" line.
- **Top-Down**: Notes spawn at Y=0 and move to Y=ScreenHeight.
- **Note Visuals**: Use `CanvasItem` shaders to handle "Note Glow" or "Hold Trails" efficiently without creating thousands of nodes.

## Judgment Systems (Perfect/Great/Miss)
Compare the `event_time` (when the player clicked) against the `note_time` (when the note was scheduled).
- 0ms - 30ms: **PERFECT**
- 30ms - 60ms: **GREAT**
- 60ms - 100ms: **GOOD**
- 100ms+: **MISS** (or if the note scrolls past the receptor).

## Combo and Scoring
- Maintain a `combo_counter` that resets on any **MISS**.
- Use a **Multiplier** that scales with your combo (e.g., 2x at 50 combo, 4x at 100 combo).
- Visual Feedback: Flash the combo number and show a "Judgment Splash" (Perfect!) at the receptor.

## Advanced: Hybrid Rhythm Games
- **Rhythm Combat**: Trigger attacks or parries only when they align with the BPM conductor's beat signal.
- **Dynamic Music**: Use `AudioStreamInteractive` (Godot 4.3+) to transition between track layers based on player performance (Combo).

## Reference
- [Godot Docs: Syncing with the Audio Clock](https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio_clock.html)
- [osu! Wiki: Scoring and Judgment](https://osu.ppy.sh/wiki/en/Gameplay/Judgement)
