# Expert Android Signing Environment Setup (PowerShell)
# Injects keystore credentials via env vars for secure CI builds.

$env:GODOT_ANDROID_KEYSTORE_PATH = "C:/Keys/release.keystore"
$env:GODOT_ANDROID_KEYSTORE_USER = "game_alias"
$env:GODOT_ANDROID_KEYSTORE_PASS = "secure_password" # Use CI Secrets in production

Write-Host "Android Signing Environment Prepared."

# Usage in Godot Export:
# Set 'Release User' and 'Release Password' in export preset to reference these env vars.
