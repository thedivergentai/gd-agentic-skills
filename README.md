# 🤖 gd-agentic-skills: The Agentic Godot 4 Mastery Library

> **"A skill forgotten is a power lost." — The Code Architect**

**Brought to you by [Divergent AI](https://github.com/thedivergentai)**.

**Godot Agentic Skills** is a high-density, **Agent-First** knowledge library for Godot 4.5+. It is designed to act as an external "Long-Term Memory" (LTM) for AI Coding Agents, providing structured, deterministic patterns for game engineering.

If you enjoy this project or find it useful for your agents, **please give it a star! 🌟**

---

## 📦 Installation

This library is optimized for the [skills.sh](https://skills.sh) protocol. To add these skills to your agent's capabilities:

```bash
# Install via skills.sh
npx skills add divergent-ai/gd-agentic-skills
```

---

## 🏛️ Repository Mandate: Agentic Software Engineering

This repository is optimized for **Recursive Machine Discovery**. Every skill is atomic, dependency-mapped, and structured for instant ingestion by LLMs.

### 🧩 Why This Repo is Unique
1.  **Deterministic Patterns**: Unlike generic AI responses, these skills follow strictly defined Godot 4 best practices (LOD, Floating Origin, Signal Decoupling).
2.  **Machine-Readable Index**: The `skills_index.json` acts as a high-speed lookup table for dependency management.
3.  **Genre Compositions**: Over 26 dedicated genre blueprints that orchestrate multiple core systems into a cohesive game loop.

---

## 📊 The Library at a Glance

| Metric | Status |
| :--- | :--- |
| **Total Mastery Skills** | 82 |
| **Genre Blueprints** | 26 (Comprehensive) |
| **Pillar Categories** | 15 |
| **Engine Target** | Godot 4.5+ (GDExtension & .NET compatible) |
| **Protocol** | Agentic Discovery Engine (ADE) |

---

## 🏗️ Technical Architecture

### 1. Project Foundations
*   **Architecture**: `autoload-architecture`, `signal-architecture`, `resource-data-patterns`.
*   **Persistence**: `save-load-systems`, `inventory-system`.

### 2. World Building & Simulation
*   **2D Mastery**: `characterbody-2d`, `tilemap-mastery`, `2d-physics`.
*   **3D Mastery**: `3d-world-building`, `3d-lighting`, `3d-materials`.
*   **VFX/GFX**: `particles`, `shaders-basics`, `tweening`.

### 3. Combat, AI & Gameplay
*   **Systems**: `combat-system`, `ability-system`, `quest-system`, `rpg-stats`.
*   **AI**: `navigation-pathfinding`, `steering-behaviors`, `state-machine-advanced`.
*   **Networking**: `multiplayer-networking`, `server-architecture`.

---

## 🎮 The 26 Genre Master-classes

**Godot Agentic Skills** provides the "Standard Model" for every major game genre.

| Segment | Blueprints |
| :--- | :--- |
| **Action & Platforming** | `genre-platformer`, `genre-fighting`, `genre-shooter`, `genre-metroidvania` |
| **Strategy & Tactics** | `genre-rts`, `genre-tower-defense`, `genre-moba`, `genre-turn-system` |
| **Social & Survival** | `genre-survival`, `genre-battle-royale`, `genre-open-world`, `genre-horror` |
| **Emergent & Simulation** | `genre-sandbox`, `genre-simulation`, `genre-idle-clicker`, `genre-racing` |
| **Logic & Narrative** | `genre-puzzle`, `genre-visual-novel`, `genre-card-game`, `genre-educational` |

---

## 🤖 Protocol: How Agents Interface with Godot Agentic Skills

To ensure maximum quality, agents must follow the **Discovery-Ingestion-Application (DIA)** loop.

### 1. Discovery (`grep` / `index`)
Agents must first query `skills_index.json` to find the skill that matches the user's intent. 
*Example: User wants "smooth character movement". Agent finds `characterbody-2d` and `tweening`.*

### 2. Ingestion (`view_file`)
**CRITICAL**: Agents must NOT implement from their general training data alone. They MUST `view_file` the `SKILL.md` to catch specific Godot 4 nuances (e.g., `AudioServer.get_time_since_last_mix()` for rhythm sync).

### 3. Application (`implementation`)
Following the **Skill Chain** documented in the header, the agent applies the logic recursively, starting from the deepest dependency.

---

## ️ Infrastructure Integration

This library is designed to work seamlessly with the **Godot MCP Server**.
*   **Scenes**: Use `mcp-scene-builder` patterns.
*   **Code**: Adhere to `gdscript-mastery` (Static typing, PascalCase classes).
*   **Optimization**: Always audit via `performance-optimization` before final check-ins.

---

## 🤝 Contributing & Requests

We welcome contributions from fellow developers and agents!

*   **Have a specific skill request?** Open an issue with the [Request] tag.
*   **Want to improve an existing skill?** Submit a PR with your expert patterns.
*   **Found a bug?** Let us know!

---

> [!IMPORTANT]
> **Anti-Erosion Policy**: Documentation MUST remain in sync with implementation. If a Godot 4 API changes, update the relevant `SKILL.md` immediately.

---

*Authored by the Divergent AI. Maintained by the Agents.*
