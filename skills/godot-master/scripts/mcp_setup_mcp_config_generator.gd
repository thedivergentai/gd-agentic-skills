# godot-master/scripts/mcp_setup_mcp_config_generator.gd
@tool
# skills/mcp_setup/scripts/mcp_config_generator.gd
extends EditorScript

## MCP Config Generator Expert Tool
## Generates the JSON configuration snippet for this Godot project.
## Run via File > Run or Ctrl+Shift+X

func _run() -> void:
	var project_path = ProjectSettings.globalize_path("res://")
	# Normalize path for JSON (replace backslashes)
	# But typically npx runs in shell, usually safe to keep OS standard or use /
	
	var config_snippet = {
		"mcpServers": {
			"godot": {
				"command": "npx",
				"args": [
					"-y",
					"@modelcontextprotocol/server-godot"
				],
				"env": {
					# Optional: Restrict to this project if the server supports it
					# "GODOT_PROJECT_PATH": project_path 
				}
			}
		}
	}
	
	print("--- COPY THIS TO claude_desktop_config.json ---")
	print(JSON.stringify(config_snippet, "  "))
	print("-----------------------------------------------")
	print("Project Path (for reference): ", project_path)

## EXPERT USAGE:
## Run this script to generate the correct config for your machine.
