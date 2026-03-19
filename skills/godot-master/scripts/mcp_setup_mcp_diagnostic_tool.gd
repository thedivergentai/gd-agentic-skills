# skills/godot-mcp-setup/code/mcp_diagnostic_tool.gd
@tool
extends EditorScript

## MCP Diagnostic Tool Expert Pattern
## Verifies environment variables and connection status.

func _run() -> void:
    print("--- MCP Diagnostic Start ---")
    
    # 1. Verification of Environment
    var mcp_key = OS.get_environment("MCP_ACCESS_KEY")
    if mcp_key == "":
        printerr("[FAIL] MCP_ACCESS_KEY not found in Environment Variables.")
    else:
        print("[PASS] Access Key found (Length: ", mcp_key.length(), ")")
        
    # 2. Command Permissions Check
    # Verify if we can execute high-privileged PowerShell commands
    var output = []
    var exit_code = OS.execute("powershell.exe", ["-Command", "Get-ExecutionPolicy"], output)
    
    if exit_code == 0:
        print("[PASS] PowerShell execution successful. Policy: ", output[0].strip_edges())
    else:
        printerr("[FAIL] Could not verify PowerShell permissions.")

    # 3. JSON Configuration Verification
    var config_path = "res://mcp_config.json"
    if FileAccess.file_exists(config_path):
        var file = FileAccess.open(config_path, FileAccess.READ)
        var json = JSON.parse_string(file.get_as_text())
        if json and json.has("servers"):
            print("[PASS] mcp_config.json is valid.")
        else:
            printerr("[FAIL] mcp_config.json is malformed.")
    else:
        print("[NOTE] No local mcp_config.json found (using default global).")

    print("--- Diagnostic Complete ---")

## EXPERT NOTE:
## NEVER store MCP secret keys in the 'ProjectSettings'. Use 'Environment 
## Variables' to keep keys out of version control (Git).
## Use 'Action History Tracking': In an expert setup, wrap all MCP-driven 
## EditorScript executions in a logger that saves to 'res://.mcp/history.log'.
