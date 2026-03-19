# Expert Headless Export Pipeline (PowerShell)
# Automates multi-platform Godot exports for CI/CD.

$GODOT_BIN = "godot" # Path to godot headless/editor binary
$BUILD_DIR = "./builds"

# Ensure build directory exists
if (!(Test-Path $BUILD_DIR)) { New-Item -ItemType Directory -Path $BUILD_DIR }

# Platform Targets
$PRESETS = @("Windows Desktop", "Linux/X11", "Web")

foreach ($PRESET in $PRESETS) {
    $OUT_DIR = "$BUILD_DIR/$($PRESET -replace ' ', '_')"
    if (!(Test-Path $OUT_DIR)) { New-Item -ItemType Directory -Path $OUT_DIR }
    
    Write-Host "Exporting: $PRESET..."
    & $GODOT_BIN --headless --export-release $PRESET "$OUT_DIR/game"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Export failed for $PRESET"
        exit $LASTEXITCODE
    }
}

Write-Host "Full Build Pipeline Completed Successfully."
