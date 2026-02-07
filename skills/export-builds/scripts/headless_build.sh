#!/bin/bash

# skills/export-builds/code/headless_build.sh
# Expert Headless Export Pattern for Godot 4.x
# Usage: ./headless_build.sh <platform> <version>

PLATFORM=$1 # "Windows Desktop", "Linux/X11", "macOS", "Web"
VERSION=$2
EXPORT_DIR="builds/$VERSION"

mkdir -p "$EXPORT_DIR"

echo "Starting Headless Export for $PLATFORM (Version: $VERSION)..."

# 1. Automate Versioning
# Injects the version number into project.godot before building.
sed -i "s/config\/version=.*/config\/version=\"$VERSION\"/" project.godot

# 2. Run Headless Export
# --headless: Runs without opening the editor window.
# --export-release: Builds optimized release binary.
godot --headless --export-release "$PLATFORM" "$EXPORT_DIR/game_binary"

# 3. Handle Secrets (Post-Build)
# Example: Sign the Windows binary with a certificate stored in ENV.
if [ "$PLATFORM" == "Windows Desktop" ]; then
    echo "Signing Windows Binary..."
    # signtool sign /f "$WINDOWS_CERT_PATH" /p "$WINDOWS_CERT_PASS" "$EXPORT_DIR/game_binary.exe"
fi

# 4. Deploy (e.g., to itch.io via butler)
# butler push "$EXPORT_DIR" user/game:$PLATFORM --version $VERSION

echo "Build Complete: $EXPORT_DIR"
