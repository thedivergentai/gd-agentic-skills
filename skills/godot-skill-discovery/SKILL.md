---
name: godot-skill-discovery
description: "Expert blueprint for GDSkills skill discovery and indexing system. Enables AI agents to find relevant skills by topic/keyword. Use when building skill libraries OR implementing search functionality. Keywords skill discovery, indexing, search, metadata, skill registry."
---

# Skill Discovery

Skill indexing, metadata parsing, and search define efficient skill library navigation.

## Available Scripts

### [skill_index_generator.gd](scripts/skill_index_generator.gd)
Expert skill indexer that parses SKILL.md files and generates searchable metadata.

## NEVER Do in Skill Discovery

- **NEVER rely on filename for skill identification** — `filesystem-advanced.md` vs `SKILL.md`? Use frontmatter `name` field as source of truth, not filename.
- **NEVER skip keyword extraction** — Skill without keywords? Impossible to discover via search. MUST extract from description OR maintain keyword list.
- **NEVER cache without invalidation** — Skill index cached, SKILL.md updated? Stale results. Invalidate cache on file modification OR version changes.
- **NEVER use full-text search without ranking** — Searching 100 skills for "input"? Returns everything. Use TF-IDF OR keyword weighting for relevance.
- **NEVER forget to handle missing frontmatter** — Malformed SKILL.md without `---` delimiter? Parser crash. Validate YAML frontmatter before parsing.

---

## Skill Metadata Format

```yaml
---
name: skill-name
description: Expert blueprint for X including [features]. Use when [scenarios]. Keywords topic, action, domain.
---
```

## Indexing Pattern

```gdscript
# skill_indexer.gd
class_name SkillIndexer
extends RefCounted

var skill_registry: Dictionary = {}

func index_skills(skills_dir: String) -> void:
    var dir := DirAccess.open(skills_dir)
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    
    while file_name != "":
        if dir.current_is_dir():
            var skill_path := skills_dir.path_join(file_name).path_join("SKILL.md")
            if FileAccess.file_exists(skill_path):
                index_skill(skill_path)
        file_name = dir.get_next()

func index_skill(path: String) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return
    
    var content := file.get_as_text()
    var metadata := parse_frontmatter(content)
    
    if metadata.has("name"):
        skill_registry[metadata.name] = {
            "path": path,
            "description": metadata.get("description", ""),
            "keywords": extract_keywords(metadata.get("description", ""))
        }

func parse_frontmatter(content: String) -> Dictionary:
    var lines := content.split("\n")
    if lines[0].strip_edges() != "---":
        return {}
    
    var frontmatter_lines: Array[String] = []
    for i in range(1, lines.size()):
        if lines[i].strip_edges() == "---":
            break
        frontmatter_lines.append(lines[i])
    
    var metadata := {}
    for line in frontmatter_lines:
        var parts := line.split(":", true, 1)
        if parts.size() == 2:
            metadata[parts[0].strip_edges()] = parts[1].strip_edges()
    
    return metadata

func search_skills(query: String) -> Array[Dictionary]:
    var results: Array[Dictionary] = []
    var query_lower := query.to_lower()
    
    for skill_name in skill_registry:
        var skill_data := skill_registry[skill_name]
        var relevance := 0.0
        
        # Check name match
        if skill_name.to_lower().contains(query_lower):
            relevance += 10.0
        
        # Check description match
        if skill_data.description.to_lower().contains(query_lower):
            relevance += 5.0
        
        # Check keyword match
        for keyword in skill_data.keywords:
            if keyword.to_lower() == query_lower:
                relevance += 20.0  # Exact keyword match
            elif keyword.to_lower().contains(query_lower):
                relevance += 3.0
        
        if relevance > 0:
            results.append({
                "name": skill_name,
                "relevance": relevance,
                "data": skill_data
            })
    
    # Sort by relevance
    results.sort_custom(func(a, b): return a.relevance > b.relevance)
    return results

func extract_keywords(description: String) -> Array[String]:
    var keywords: Array[String] = []
    
    # Extract from "Keywords X, Y, Z" pattern
    var keyword_marker := "Keywords "
    var keyword_index := description.find(keyword_marker)
    if keyword_index != -1:
        var keyword_section := description.substr(keyword_index + keyword_marker.length())
        var parts := keyword_section.split(".", true, 1)
        var keyword_str := parts[0] if parts.size() > 0 else keyword_section
        
        for word in keyword_str.split(","):
            keywords.append(word.strip_edges())
    
    return keywords
```

## Best Practices

1. **Version Skill Index** — Include skill version in metadata for compatibility checks
2. **Cache Aggressively** — Parse SKILL.md on index build, cache results for fast search
3. **Support Fuzzy Matching** — Allow typos in search (e.g., Levenshtein distance)
4. **Category Grouping** — Organize skills by category for browsing (2D, 3D, Genre, etc.)

## Reference
- Related: `godot-project-foundations`, `godot-gdscript-mastery`

### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
