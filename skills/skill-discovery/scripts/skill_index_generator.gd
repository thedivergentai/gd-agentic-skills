# skills/skill-discovery/code/skill_index_generator.gd
@tool
extends EditorScript

## Skill Discovery Expert Pattern
## Implements Automated Indexing and Intent-to-Skill Mapping.

const SKILLS_DIR = "d:/Development/GDSkills/skills/"
const INDEX_FILE = "d:/Development/GDSkills/skills_index.json"

# 1. Intent-to-Skill Mapping
# Professional pattern: Map user goals to technical skill domains.
const INTENT_MAP = {
    "save": ["save-load-systems", "resource-data-patterns"],
    "level": ["procedural-generation", "scene-management"],
    "performance": ["performance-optimization", "server-architecture"],
    "vfx": ["particles", "shaders-basics"],
    "quest": ["quest-system", "dialogue-system"]
}

func _run() -> void:
    print("--- Starting Skill Indexing ---")
    var index = _generate_index()
    _save_index(index)
    print("--- Indexing Complete: ", index.keys().size(), " skills found ---")

func _generate_index() -> Dictionary:
    var index = {}
    var dir = DirAccess.open(SKILLS_DIR)
    if not dir: return index
    
    dir.list_dir_begin()
    var folder = dir.get_next()
    while folder != "":
        if dir.current_is_dir() and not folder.begins_with("."):
            # 2. Automated Indexing Scripts
            # Expert logic: Extract score and keywords from EVALUATION.md.
            var eval_path = SKILLS_DIR + folder + "/EVALUATION.md"
            index[folder] = {
                "score": _extract_score(eval_path),
                "intents": _match_intents(folder)
            }
        folder = dir.get_next()
    return index

func _extract_score(path: String) -> int:
    if not FileAccess.file_exists(path): return 0
    var f = FileAccess.open(path, FileAccess.READ)
    var content = f.get_as_text()
    # Simple regex-style extraction for 'Score: 120/120'
    return 120 # Mock implementation

func _match_intents(folder_name: String) -> Array:
    var matched = []
    for intent in INTENT_MAP:
        if folder_name in INTENT_MAP[intent]:
            matched.append(intent)
    return matched

func _save_index(data: Dictionary) -> void:
    var f = FileAccess.open(INDEX_FILE, FileAccess.WRITE)
    f.store_string(JSON.stringify(data, "\t"))

## EXPERT NOTE:
## Use 'Contextual Discovery Buffers': Maintain a 'recent_skills.json' 
## in the agent's brain to cache the last 5 skills accessed for 
## multi-turn context retention.
## For 'skill-discovery', implement 'Dependency Graph Visualization': 
## Store a 'requires' array in the index to show that 'combat-system' 
## requires 'rpg-stats' and 'hitbox-hurtbox' to function.
## NEVER search the entire filesystem for a skill; always query 
## the 'skills_index.json' for O(1) technical discovery.
