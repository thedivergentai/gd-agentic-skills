> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Quest Systems**. Accessed via Godot Master.

# Quest System

Expert blueprint for narrative progression and mission tracking using resource-based quests and signal-driven objectives.

## Available Scripts

### [quest_manager.gd](../scripts/quest_system_quest_manager.gd)
Central AutoLoad tracker. Manages active quest lists, objective progress updates, and automatic reward distribution upon completion.

### [quest_graph_manager.gd](../scripts/quest_system_quest_graph_manager.gd)
Runtime manager for branching, graph-based quests. Tracks complex dependencies and conditional node progression.


## NEVER Do

- **NEVER store quest progress in temporary scene nodes** — Variables in `player.gd` or `level.gd` are lost on scene reload. Always use a persistent AutoLoad or the `Resource` itself to track state.
- **NEVER use loose strings for IDs without validation** — Typoing a quest ID (e.g., `"kil_bandts"`) causes silent failures. Use `StringName` constants or validate against a master registry.
- **NEVER poll for objective updates** — Don't check `if enemies_killed == 10` in `_process`. Connect to signals: `enemy.died.connect(quest_manager.update_objective)`.
- **NEVER forget to persist quest state** — Player progress must be saved and loaded. Track `active_quests` and `completed_quests` arrays in your global save dictionary.
- **NEVER allow duplicate quest rewards** — Disconnect completion signals immediately after a quest is finished to prevent rewards from being granted twice if an objective is re-triggered.

---

## Architecture: Quest Resources
A `Quest` resource should contain:
- **Objectives**: An array of `QuestObjective` resources (Kill, Collect, Talk, Reach).
- **Rewards**: An array of `QuestReward` resources (Experience, Gold, Items).
- **Status**: Track if the quest is `AVAILABLE`, `ACTIVE`, `FAILED`, or `COMPLETED`.

## Objective Tracking
Each `QuestObjective` tracks its own `current_amount` and `required_amount`.
- **Signal Flow**: Event (Enemy Death) → System Signal → QuestManager → Active Quest → Objective Update → Manager Signal → UI Refresh.

## Quest UI
Display active quests in a vertical list. Each entry should show the quest title and a bulleted list of current objectives with progress markers (e.g., `Collect Herbs: 3/5`).

## Branching Quests
For complex story paths, use a graph structure where each node is a quest stage. Completion of one node unlocks specific "Next" nodes based on player choices or outcomes.

## Reward Distribution
Implement a `grant()` method on the `QuestReward` base class. Subclasses handle specific logic like `RewardGold`, `RewardItem`, or `RewardExperience`. 

## Reference
- [Godot Docs: Custom Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot Docs: Signal Implementation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
