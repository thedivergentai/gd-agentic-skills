---
name: godot-skill-judge
description: "Meta-skill for validating the integrity and quality of other skills. automatically checks for SKILL.md existence, script syntax errors (via Godot CLI), and metadata completeness. Use this skill to verify the entire skill library. Trigger keywords: validation, continuous_integration, quality_assurance, syntax_check, metadata_check."
---

# Skill Judge

The Guardian of Quality.

## Responsibilities

1. **Existence Check**: Ensure every skill folder has a `SKILL.md`.
2. **Metadata Validation**: Ensure `SKILL.md` has valid YAML frontmatter with `name` and `description`.
3. **Script Validation**: Scan all `.gd` files and check for basic parsing errors.
4. **Godot 4 Compatibility**: Scan for banned Godot 3 keywords (`move_and_slide(vec)`, `rotation_degrees` vector usage errors, etc).

## Available Scripts

### [skill_validator.gd](scripts/skill_validator.gd)
The core validation engine. Can be run as an EditorScript or via CLI.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
