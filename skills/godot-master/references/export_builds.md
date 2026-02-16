> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Export & Builds**. Accessed via Godot Master.

# Export & Builds

Expert blueprint for multi-platform distribution, command-line builds, and CI/CD automation.

## Available Scripts

### [version_manager.gd](../scripts/export_builds_version_manager.gd)
AutoLoad for centralized management of game semantic versioning, build timestamps, and runtime window titles based on build profiles.

### [headless_build.sh](../scripts/export_builds_headless_build.sh)
Bash script for automating headless exports. Handles template downloading, version injection, and output packaging for Windows, Linux, and macOS.


## NEVER Do

- **NEVER export without a target platform smoke test** — An app that works in the editor may fail on a different OS due to case-sensitivity or missing dependencies. Test early builds on every target device.
- **NEVER use Debug builds for final production** — Debug exports are unoptimized, significantly larger, and slower. Always use `--export-release` for public distribution.
- **NEVER hardcode absolute OS paths** — `C:/Users/...` will break on everyone else's computer. Stick strictly to `res://` for game assets and `user://` for player data.
- **NEVER skip macOS code signing** — Gatekeeper will block your app on macOS unless it is signed and notarized, leading to a "damaged file" error for users.
- **NEVER include internal documentation or source assets in the export** — Use the "Exclude Filters" in your export preset (e.g., `*.md, .git/*, *.blend`) to keep build sizes lean.

---

## Command-Line Exporting
For automation and CI/CD, use the headless mode:
`godot --headless --export-release "Windows Desktop" builds/game.exe`

## Feature Tags
Use `OS.has_feature()` to execute platform-specific code at runtime:
- `if OS.has_feature("mobile"):` — Trigger touch UI.
- `if OS.has_feature("web"):` — Adjust physics delta or hide "Quit" button.

## Export Presets (`export_presets.cfg`)
This file stores your platform configurations. Ensure it is committed to version control so build scripts can refer to named presets like `"Linux Desktop"` or `"Android Production"`.

## Android Requirements
To export for Android, you must install:
1. **Android SDK & NDK**
2. **OpenJDK 17+**
3. Create a **Debug keystore** for testing and a **Release keystore** for Play Store deployment.

## CI/CD Pipeline (GitHub Actions)
Automate your build process:
1. Trigger on `git push tag`.
2. Spin up a Docker container with the Godot binary.
3. run the export command.
4. Upload the resulting binaries as GitHub Artifacts or Release assets.

## Reference
- [Godot Docs: Exporting Projects](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)
- [Godot Docs: Feature Tags](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html)
