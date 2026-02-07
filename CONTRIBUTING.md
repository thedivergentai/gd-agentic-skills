# Contributing to Godot Agentic Skills

**Status**: Accepting PRs for Godot 4.5+ Expert Patterns.

Thank you for helping build the ultimate "Long-Term Memory" for AI Agents. This repository is maintained by **[Divergent AI](https://github.com/thedivergentai)**.

---

## 🏛️ The Philosophy

We are **NOT** building a tutorial library for humans.
We **ARE** building a deterministic knowledge base for Machines.

Every skill must provide **Expert Knowledge Delta**:
- **Don't** explain what a `for` loop is.
- **Do** explain *why* `for i in range(x)` is faster than `for x in array` in specific Godot versions.

---

## 📂 Skill Structure

Every skill lives in `skills/<category>-<skill-name>/`.

```text
skills/my-new-skill/
├── SKILL.md          # [REQUIRED] The Agent's instruction manual
├── scripts/          # [RECOMMENDED] Production-ready .gd files (for complex logic)
│   ├── my_class.gd   # PascalCase class names, static typing
│   └── util.gd
└── assets/           # [OPTIONAL] .tscn, .tres, or placeholders
```

---

## 📝 SKILL.md Standards

Your `SKILL.md` must adhere to the **Expert Knowledge Delta** principle.

### Frontmatter (Required)
```yaml
---
name: my-new-skill
description: Precise description of WHAT this does and WHEN to use it. Must include keywords.
---
```

### Core Sections
1.  **High-Level Concept**: The "Mental Model" of the system.
2.  **Critical Implementation**: Code snippets that show *architectural patterns*, not just syntax.
3.  **Anti-Patterns**: A explicit list of "NEVER DO THIS" (e.g., "Never use `get_node()` in `_process()`").

---

## 💻 Code Standards (Godot 4.5+)

If you include scripts, they must be:
1.  **Statically Typed**: `func move(vec: Vector2) -> void:`
2.  **Modular**: Self-contained classes.
3.  **Godot 4 Native**: Use `Signal`, `Tween`, `Callable` correctly. Avoid Godot 3 legacies (`move_and_slide` with args).

---

## 🚀 Submission Workflow

1.  **Fork & Create**:
    `cp -r skills/project-templates/ skills/my-new-skill`

2.  **Develop**:
    Write your `SKILL.md` and `scripts/`.

3.  **Validate**:
    Ensure your scripts parse correctly in the Godot 4.5 editor and are free of warnings.

4.  **Index**:
    Do **NOT** manually edit `skills_index.json`. We run a CI script (`update_skills_index.py`) to regenerate it.

5.  **Pull Request**:
    Submit your PR with a description of the "Knowledge Delta" this skill adds.

---

## ⚖️ License

By contributing, you agree that your code will be licensed under the project's **MIT License**.
