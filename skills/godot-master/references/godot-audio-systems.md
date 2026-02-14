> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Audio Systems**. Accessed via Godot Master.

# Audio Systems

Expert guidance for Godot's audio engine and mixing architecture. Covers pooling for performance, positional/spatial audio, music transitions, and dynamic sound effects.

## Available Scripts

### [audio_manager.gd](../scripts/godot-audio-systems_audio_manager.gd)
A high-performance singleton for global sound management. Implements **Audio Pooling** (pre-allocating `AudioStreamPlayer` nodes) to prevent memory allocation spikes and garbage collection stutters during intense SFX sequences.

### [audio_bus_manager.gd](../scripts/godot-audio-systems_audio_bus_manager.gd)
A professional utility for managing the `AudioServer` buses. Handles linear-to-decibel conversions, dynamic creation of effects (Reverb, EQ, Compression) at runtime, and master/music/SFX volume synchronization.

### [audio_visualizer.gd](../scripts/godot-audio-systems_audio_visualizer.gd)
A real-time Fast Fourier Transform (FFT) analyzer. Captures the frequency spectrum of an audio bus to drive visual effects, such as music-reactive shaders, lighting pulses, or UI animations.


## NEVER Do

- **NEVER instance players every frame** — Generating a new `AudioStreamPlayer` node for every bullet hit or footstep will quickly bloat the scene tree and cause major performance stutters. ALWAYS use **Audio Pooling**.
- **NEVER use linear values for `volume_db`** — The `AudioServer` expects values in decibels (-80 to 24). Setting a volume to `0.5` linear will result in a near-silent sound. Use `linear_to_db(0.5)` for correct scaling.
- **NEVER use `autoplay = true` for multi-scene music** — If every level scene has an autoplaying music player, tracks will overlap or cut each other off during transitions. Use a persistent **MusicManager AutoLoad**.
- **NEVER leave `AudioStreamPlayer3D` on default attenuation** — The default attenuation model is often set to "None" (Global). This makes 3D sounds audible regardless of distance. ALWAYS set to **Inverse Distance** or **Logarithmic**.
- **NEVER restart a sound without checking `playing`** — Calling `.play()` on an already-active player will snap the sound back to the beginning, causing an audible "pop." Check `if not player.playing` before triggering.
- **NEVER use `AudioStreamPlayer` for spatial cues** — The base player is non-positional. For 2D panning, use `AudioStreamPlayer2D`; for 3D depth and doppler, use `AudioStreamPlayer3D`.

---

## Positional vs. Spatial Audio
1. **AudioStreamPlayer**: Global. Used for UI, Music, and Voiceovers.
2. **AudioStreamPlayer2D**: Panning and distance-based volume in a 2D plane.
3. **AudioStreamPlayer3D**: Fully spatialized with 3D falloff, Doppler tracking, and Reverb Bus sends.

## Managing the Audio Bus Hierarchy
Professional layout:
- **Master**: Overall gain.
- **Music**: Ducked by dialogue.
- **SFX**: Categorized by priority (Combat, Ambience).
- **Dialogue**: Highest priority, routes directly to Master.

## Music Transitions (Crossfade)
To transition tracks without a "pop":
1. Keep two `AudioStreamPlayer` nodes.
2. Tween the current player's `volume_db` from `0` down to `-80`.
3. Simultaneously tween the new player's `volume_db` from `-80` up to `0`.

## Audio Reactivity (Visualizer)
- Add an `AudioEffectSpectrumAnalyzer` to a bus.
- In `_process()`, call `get_magnitude_for_frequency_range()` on the effect.
- Map the resulting energy (linear) to a shader parameter or a light's `omni_range`.

## Performance: Distance-Based Culling
For open-world games:
- If an `AudioStreamPlayer3D` is further than its `max_distance * 1.5`, call `stop()` and disable its visibility to stop the physics engine from processing the spatial calculation.

## Reference
- [Godot Docs: Audio Streams](https://docs.godotengine.org/en/stable/tutorials/audio/audio_streams.html)
- [Godot Docs: Audio Buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html)
