---
name: godot-mcp-setup
description: "[PREREQUISITE] Install and configure Godot MCP server for programmatic scene manipulation via Model Context Protocol. Use when user explicitly requests MCP-based scene building or automation. NOT for manual Godot workflows. Keywords MCP, Model Context Protocol, scene automation, npx, claude_desktop_config."
---

# Godot MCP Setup

Enables AI agents to install and configure the Godot MCP (Model Context Protocol) server for programmatic scene management.

## When to Use This Skill

**Use ONLY when:**
- User explicitly requests MCP-based scene building
- User wants programmatic scene creation/modification
- User asks about scene automation tools

**DO NOT suggest unless:**
- User expresses interest in MCP functionality
- Alternative manual methods insufficient

## Available Scripts

### [mcp_config_generator.gd](scripts/mcp_config_generator.gd)
Tool script to generate the Claude Desktop config JSON for Godot MCP.

## NEVER Do in MCP Setup

- **NEVER suggest MCP for simple scene edits** — MCP is for automation/batch operations. Single node addition? Use manual editor. MCP overhead (config + restart) wastes time.
- **NEVER skip JSON syntax validation** — Invalid JSON in `claude_desktop_config.json` = silent MCP failure. ALWAYS validate with `ConvertFrom-Json` before saving.
- **NEVER forget to remind user to restart Claude Desktop** — MCP changes require full app restart, NOT just new conversation. This is #1 user mistake.
- **NEVER use global npm install without user permission** — `npm install -g` modifies system. ALWAYS prefer `npx` (on-demand) unless user specifically wants global.
- **NEVER assume Node.js is installed** — Check `node --version` BEFORE attempting npx. Missing Node = cryptic "command not found" errors.

---

## Installation Workflow

### Step 1: Check if MCP is Already Installed

**For PowerShell (Windows):**
```powershell
# Check if the Godot MCP server is configured
$mcpConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
if (Test-Path $mcpConfigPath) {
    $config = Get-Content $mcpConfigPath | ConvertFrom-Json
    if ($config.mcpServers.godot) {
        Write-Host "Godot MCP server is already configured."
    }
}
```

### Step 2: Install Godot MCP Server

**Installation Command (npx):**
```powershell
# Install globally
npm install -g @modelcontextprotocol/server-godot

# OR use npx for on-demand execution
npx @modelcontextprotocol/server-godot
```

### Step 3: Configure Claude Desktop

The MCP server must be registered in Claude Desktop's configuration file.

**Configuration File Location:**
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

**Example Configuration:**
```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-godot"]
    }
  }
}
```

### Step 4: Restart Claude Desktop

After configuration, the user must restart Claude Desktop for MCP changes to take effect.

## Verification

After installation, verify the MCP tools are available by checking if `mcp_godot_*` tools are accessible.

## Common Issues

**Issue**: MCP server not appearing after restart
- **Solution**: Verify the JSON syntax in `claude_desktop_config.json`
- **Solution**: Check that Node.js and npm are installed

**Issue**: Permission errors during installation
- **Solution**: Run PowerShell as Administrator on Windows

## Reference
- Godot MCP Server: [GitHub Repository](https://github.com/modelcontextprotocol/servers/tree/main/src/godot)
- MCP Protocol: [Official Documentation](https://modelcontextprotocol.io/)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
