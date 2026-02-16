# godot-master/scripts/skill_discovery_skill_indexer.gd
class_name SkillIndexer
extends RefCounted

## Skill Indexer (Expert Pattern)
## Scans the skills directory, parses SKILL.md frontmatter, and builds a searchable registry.

var skill_registry: Dictionary = {}

func index_skills(skills_dir: String) -> void:
    var dir := DirAccess.open(skills_dir)
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name := dir.get_next()
    
    while file_name != "":
        if dir.current_is_dir() and not file_name.begins_with("."):
            var skill_path := skills_dir.path_join(file_name).path_join("SKILL.md")
            if FileAccess.file_exists(skill_path):
                index_skill(skill_path, file_name)
        file_name = dir.get_next()
    dir.list_dir_end()

func index_skill(path: String, folder_name: String) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return
    
    var content := file.get_as_text()
    var metadata := parse_frontmatter(content)
    
    # Fallback name if missing in frontmatter
    var s_name = metadata.get("name", folder_name)
    
    skill_registry[s_name] = {
        "path": path,
        "folder": folder_name,
        "description": metadata.get("description", ""),
        "keywords": extract_keywords(metadata.get("description", ""))
    }

func parse_frontmatter(content: String) -> Dictionary:
    var lines := content.split("\n")
    if lines.size() == 0 or lines[0].strip_edges() != "---":
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
        
        if skill_name.to_lower().contains(query_lower):
            relevance += 10.0
        if skill_data.description.to_lower().contains(query_lower):
            relevance += 5.0
        
        for keyword in skill_data.keywords:
            if keyword.to_lower().contains(query_lower):
                relevance += 15.0
                
        if relevance > 0:
            results.append({
                "name": skill_name,
                "relevance": relevance,
                "data": skill_data
            })
            
    results.sort_custom(func(a, b): return a.relevance > b.relevance)
    return results

func extract_keywords(description: String) -> Array[String]:
    var keywords: Array[String] = []
    var search_str = "Trigger keywords: "
    var idx = description.find(search_str)
    if idx == -1:
         search_str = "Keywords "
         idx = description.find(search_str)
    
    if idx != -1:
        var substr = description.substr(idx + search_str.length())
        # Assume keywords end at end of line or file
        var parts = substr.split(".", true, 1) # Stop at first period
        var keyword_line = parts[0]
        for word in keyword_line.split(","):
            keywords.append(word.strip_edges())
            
    return keywords

## EXPERT USAGE:
## var indexer = SkillIndexer.new()
## indexer.index_skills("res://skills")
## var results = indexer.search_skills("physics")
