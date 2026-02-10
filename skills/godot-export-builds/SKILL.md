---
name: godot-export-builds
description: "Expert patterns for multi-platform exports including export templates (Windows/Linux/macOS/Android/iOS/Web), command-line exports (headless mode), platform-specific settings (codesign, notarization, Android SDK), feature flags (OS.has_feature), CI/CD pipelines (GitHub Actions), and build optimization (size reduction, debug stripping). Use for release preparation or automated deployment. Trigger keywords: export_preset, export_template, headless_export, platform_specific, feature_flag, CI_CD, build_optimization, codesign, Android_SDK."
---

# Export & Builds

Expert guidance for building and distributing Godot games across platforms.

## NEVER Do

- **NEVER export without testing on target platform first** — "Works on my machine" doesn't mean it works on Windows/Linux/Android. Test early and often.
- **NEVER use debug builds for release** — Debug builds are 5-10x larger and slower. Always export with --export-release for production.
- **NEVER hardcode file paths in exports** — Use `res://` and `user://` paths. Absolute paths (`C:/Users/...`) break on other machines.
- **NEVER skip code signing on macOS** — Unsigned macOS apps trigger Gatekeeper warnings. Users won't run your game.
- **NEVER include editor-only files in exports** — Exclude `.md`, `docs/*`, `.git` via export filters. Reduces build size by 20-50%.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [version_manager.gd](scripts/version_manager.gd)
AutoLoad for managing game version, build hash, and window titles.

### [headless_build.sh](scripts/headless_build.sh)
CI/CD headless export script. Automates version injection, godot --headless --export-release, code signing, and butler deployment.

---

## Export Templates

**Install via Editor:**
Editor → Manage Export Templates → Download

## Basic Export Setup

### Create Export Preset

1. Project → Export
2. Add preset (Windows, Linux, etc.)
3. Configure settings
4. Export Project

### Windows Export

```ini
# Export settings
# Format: .exe (single file) or .pck + .exe
# Icon: .ico file
# Include: *.import, *.tres, *.tscn
```

### Web Export

```ini
# Settings:
# Export Type: Regular or GDExtension
# Thread Support: For SharedArrayBuffer
# VRAM Compression: Optimized for size
```

## Export Presets File

```ini
# export_presets.cfg

[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
export_path="builds/windows/game.exe"

[preset.0.options]
binary_format/64_bits=true
application/icon="res://icon.ico"
```

## Command-Line Export

```powershell
# Export from command line
godot --headless --export-release "Windows Desktop" builds/game.exe

# Export debug build
godot --headless --export-debug "Windows Desktop" builds/game_debug.exe

# PCK only (for patching)
godot --headless --export-pack "Windows Desktop" builds/game.pck
```

## Platform-Specific

### Android

```ini
# Requirements:
# - Android SDK
# - OpenJDK 17
# - Debug keystore

# Editor Settings:
# Export → Android → SDK Path
# Export → Android → Keystore
```

### iOS

```ini
# Requirements:
# - macOS with Xcode
# - Apple Developer account
# - Provisioning profile

# Export creates .xcodeproj
# Build in Xcode for App Store
```

### macOS

```ini
# Settings:
# Codesign: Developer ID certificate
# Notarization: Required for distribution
# Architecture: Universal (Intel + ARM)
```

## Feature Flags

```gdscript
# Check platform at runtime
if OS.get_name() == "Windows":
    # Windows-specific code
    pass

if OS.has_feature("web"):
    # Web build
    pass

if OS.has_feature("mobile"):
    # Android or iOS
    pass
```

## Project Settings for Export

```ini
# project.godot

[application]
config/name="My Game"
config/version="1.0.0"
run/main_scene="res://scenes/main.tscn"
config/icon="res://icon.svg"

[rendering]
# Optimize for target platforms
textures/vram_compression/import_etc2_astc=true  # Mobile
```

## Build Optimization

### Reduce Build Size

```gdscript
# Remove unused imports
# Project Settings → Editor → Import Defaults

# Exclude editor-only files
# In export preset: Exclude filters
*.md
*.txt
docs/*
```

### Strip Debug Symbols

```ini
# Export preset options:
# Debugging → Debug: Off
# Binary Format → Architecture: 64-bit only
```

## CI/CD with GitHub Actions

```yaml
# .github/workflows/export.yml
name: Export Godot Game

on:
  push:
    tags: ['v*']

jobs:
  export:
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.2.1
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Export Windows
        run: |
          mkdir -p builds/windows
          godot --headless --export-release "Windows Desktop" builds/windows/game.exe
      
      - name: Upload Artifact
        uses: actions/upload-artifact@v3
        with:
          name: windows-build
          path: builds/windows/
```

## Version Management

```gdscript
# version.gd (AutoLoad)
extends Node

const VERSION := "1.0.0"
const BUILD := "2024.02.06"

func get_version_string() -> String:
    return "v" + VERSION + " (" + BUILD + ")"
```

## Best Practices

### 1. Test Export Early

```
Export to all target platforms early
Catch platform-specific issues fast
```

### 2. Use .gdignore

```
# Exclude folders from export
# Create .gdignore in folder
```

### 3. Separate Debug/Release

```
Debug: Keep logs, dev tools
Release: Strip debug, optimize size
```

## Reference
- [Godot Docs: Exporting](https://docs.godotengine.org/en/stable/tutorials/export/index.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
