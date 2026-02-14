> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Skill Judge (QA & Validation)**. Accessed via Godot Master.

# Skill Judge (QA & Validation)

The "Guardian of Quality" for the GDSkills library. This module provides automated tools for validating the integrity, metadata accuracy, and script compatibility of other skills within the repository.

## Available Scripts

### [skill_validator.gd](../scripts/godot-skill-judge_skill_validator.gd)
The core validation engine used to audit the entire skill library. It performs recursive directory scans to ensure every skill contains a valid `SKILL.md`, verifies the YAML frontmatter syntax, and uses the Godot CLI to perform head-less syntax checks on all `.gd` files.


## NEVER Do

- **NEVER skip automated validation before a commit** — Human error in a `SKILL.md` frontmatter can break the entire discovery index. ALWAYS run the `skill_validator` as part of your local pre-commit or CI/CD pipeline.
- **NEVER allow scripts with syntax errors** — A skill that prints errors when loaded in Godot is worse than no skill at all. The judge MUST verify that every script passes the Godot parser (`godot --check-only`).
- **NEVER use outdated Godot 3 syntax** — The judge should flag deprecated patterns (e.g., `move_and_slide(velocity)` instead of the Godot 4 `move_and_slide()` with property-based velocity).
- **NEVER bypass the "Completeness" check** — A skill is incomplete if it lacks a `description`, `Category`, or at least one `Script`. The judge must strictly enforce the baseline documentation standards.
- **NEVER ignore malformed JSON/YAML** — Metadata files must be strictly valid. The judge should treat a single missing comma as a "Fatal Error" for that skill module.

---

## Validation Categories
1. **Structure**: Does the folder layout match the standard (`scripts/`, `assets/`, `SKILL.md`)?
2. **Metadata**: Is the YAML frontmatter complete and searchable?
3. **Compatibility**: Does the GDScript adhere to the project's target Godot version (4.x)?
4. **Referential Integrity**: Are all relative file links in the `SKILL.md` valid and reachable?

## Using the CLI Validator
The `skill_validator.gd` can be triggered via a terminal for automated QA:
```powershell
godot --headless -s scripts/godot-skill-judge_skill_validator.gd --path .
```
This produces a `qa_report.json` detailing every success and failure across the library.

## Continuous Integration (CI)
Integrate the Skill Judge into your GitHub Actions:
- On every Push: Run the syntax validator.
- On every Pull Request: Verify that the new skill's metadata follows the naming convention (`godot-xxx-xxx`).

## Reference
- [Godot Docs: Command Line Interface](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_interface.html)
- [Master Skill: godot-master](../godot-master/SKILL.md)
