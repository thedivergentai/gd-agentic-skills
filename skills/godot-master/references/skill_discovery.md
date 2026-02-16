> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Skill Discovery & Indexing**. Accessed via Godot Master.

# Skill Discovery & Indexing

Expert blueprint for building and navigating a library of Godot skills. This module focuses on automated metadata extraction, keyword-based search ranking, and ensuring AI agents can efficiently find the most relevant blueprints for any given task.

## Available Scripts

### [skill_indexer.gd](../scripts/skill_discovery_skill_indexer.gd)
A high-level utility class for parsing `SKILL.md` files. It extracts YAML frontmatter, identifies the skill's primary objective, and generates a structured `Registry` that can be queried by name, description, or keyword.

### [skill_index_generator.gd](../scripts/skill_discovery_skill_index_generator.gd)
A Godot tool script that traverses the filesystem and produces a unified `skills_index.json`. This index is used to power real-time search and discovery in the agentic development environment.


## NEVER Do

- **NEVER rely on a File Name for skill identity** — A file named `filesystem_logic.md` might have its internal `name` set to `godot-save-systems`. ALWAYS use the **Frontmatter `name`** field as the single source of truth for skill identification.
- **NEVER skip Keyword extraction** — Descriptions are for humans; keywords are for search engines. A skill without a comprehensive `Keywords` list in its description will be invisible to automated search queries.
- **NEVER use Full-Text search without Relevance Ranking** — Searching for the term "Input" across 100 skills will return nearly everything. Implement a **Weighted Search**: exact title matches rank highest, followed by exact keywords, and finally description mentions.
- **NEVER use stale Search Caches** — If a `SKILL.md` is updated and the index is not rebuilt, the agent will act on outdated information. Implement a hash-check or file-timestamp verification before returning results from a cache.
- **NEVER ignore Malformed Frontmatter** — If a skill file starts with something other than `---`, the YAML parser will crash the indexing service. ALWAYS use a `try-catch` block or a defensive line-check when reading skill files.
- **NEVER conflate "Similar" skills** — Ensure `composition` and `composition_apps` have distinct enough keywords that the discovery system doesn't return the wrong one for a game-logic vs. UI-logic request.

---

## Frontmatter Standard
All discovery-compliant skills must follow this header format:
```yaml
---
name: godot-skill-id
description: Expert blueprint for [feature]. Use when [scenario]. Keywords [a, b, c].
---
```

## Weighted Relevance Logic
Professional discovery ordering:
1. **Weight 10**: Exact Name Match (e.g., query "tweening" vs. name "tweening").
2. **Weight 5**: Description Match (query found anywhere in the text).
3. **Weight 20**: Exact Keyword Match (primary tag match).

## Automated Indexing Pipeline
The `skill_index_generator` follows these steps:
1. `DirAccess` loop through the `skills/` directory.
2. Filter for directories containing a `SKILL.md`.
3. Parse frontmatter and resolve relative file paths.
4. Export as a unified `skills_index.json` for fast loading.

## Improving Discovery
- **TF-IDF**: Term Frequency-Inverse Document Frequency. If a word appears in every skill (like "Godot"), it should carry less weight than a rare word (like "Raymarching").
- **Synonyms**: The discovery system should treat "Character" and "Player" as related terms to improve the success rate of user queries.

## Reference
- [Godot Docs: FileAccess API](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)
- [Master Skill: godot-master](../SKILL.md)
