> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Godot MCP Setup**. Accessed via Godot Master.

# Godot MCP Setup

Expert guide for installing and configuring the Godot Model Context Protocol (MCP) server. This setup allows agentic AI to programmatically manipulate Godot scenes, providing a bridge between language models and the Godot editor.

## Available Scripts

### [mcp_config_generator.gd](../scripts/godot-mcp-setup_mcp_config_generator.gd)
A Godot tool script to automate the creation of the `claude_desktop_config.json` file. It detects the user's operating system, locates the Claude config directory, and inserts the necessary Godot MCP server entry correctly formatted for JSON.

### [mcp_diagnostic_tool.gd](../scripts/godot-mcp-setup_mcp_diagnostic_tool.gd)
A troubleshooting utility for MCP connections. Verified the presence of `node.js`, checks for syntax errors in the configuration file, and pings the local MCP server to ensure it is responsive to agentic commands.


## NEVER Do

- **NEVER suggest MCP for trivial scene edits** — The MCP toolchain is an automation layer. For simple tasks like moving a single sprite or renaming a node, the manual Godot Editor is significantly faster. Only use MCP for **batch operations**, **procedural scaffolding**, or **AI-driven scene generation**.
- **NEVER skip JSON syntax validation** — The `claude_desktop_config.json` file is hypersensitive to trailing commas and incorrect quotes. A single syntax error will cause ALL MCP servers to silently fail. ALWAYS validate the JSON before saving.
- **NEVER forget to request a Full App Restart** — Modifying the MCP configuration does **not** update live sessions. The user MUST fully close and restart the Claude Desktop app (ensure it is not just minimized to the system tray).
- **NEVER assume `node.js` is installed** — The Godot MCP server runs on Node. If `node --version` fails, the installation will crash with cryptic errors. Always verify the environment before suggesting an `npx` command.
- **NEVER use Global NPM installs unnecessarily** — Modifying the global system state with `-g` can cause permission conflicts. Prefer using `npx` to run the server on-demand as it handles versioning and dependencies more cleanly for the user.
- **NEVER run MCP on an unsaved project** — The MCP server interacts with `.tscn` files on disk. If the user hasn't saved their current Godot project, changes made via MCP may be overwritten or fail to apply.

---

## Installation Pipeline
1. **Env Check**: Verify `node` and `npm` availability.
2. **Installation**: Use `npx @modelcontextprotocol/server-godot` for the most reliable path.
3. **Configuration**: Locating `%APPDATA%\Claude\claude_desktop_config.json` (Windows) or the equivalent on macOS/Linux.
4. **Registration**: Adding the "godot" server block to the `mcpServers` object.
5. **Cold Reboot**: Restarting the hosting application.

## Core MCP Functionality
Once set up, the following capabilities become available to the agent:
- `create_scene`: Initializes a new `.tscn` boiler plate.
- `add_node`: Injects nodes into a saved hierarchy.
- `edit_property`: Modifies Inspector values (Names, Transforms, Colors).
- `attach_script`: Links `.gd` files to nodes.

## Troubleshooting Common Failures
- **Tools not showing**: Re-check JSON syntax; ensure the `command` is exactly `"npx"` and the `args` array is correct.
- **Permission Denied**: Run the terminal (PowerShell/Terminal) as an Administrator/Sudo when performing the initial npx fetch.
- **"Godot not found"**: Ensure the Godot executable is in the system PATH if using advanced MCP features that require project launching.

## Reference
- [Godot MCP GitHub Repository](https://github.com/modelcontextprotocol/servers/tree/main/src/godot)
- [Official MCP Specification](https://modelcontextprotocol.io/)
