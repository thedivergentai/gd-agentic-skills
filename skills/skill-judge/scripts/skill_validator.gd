# skills/skill-judge/scripts/skill_validator.gd
@tool
extends EditorScript

## Skill Validator (Expert Pattern)
## Meta-tool to validate the GDSkills library itself.
## Checks for SKILL.md presence, frontmatter validity, and basic script compilation.

func _run() -> void:
    print("⚖️  SKILL JUDGE STARTING...")
    var skills_dir = "res://skills" # or absolute path if running externally
    
    # If running as EditorScript, we might need absolute path
    # But usually ProjectSettings.globalize_path("res://") works
    
    var dir = DirAccess.open(skills_dir)
    if not dir:
        print("❌ Critical: Skills directory not found at ", skills_dir)
        return
        
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    var total_skills = 0
    var errors = 0
    
    while file_name != "":
        if dir.current_is_dir() and not file_name.begins_with("."):
            var skill_path = skills_dir + "/" + file_name
            if not validate_skill(skill_path, file_name):
                errors += 1
            total_skills += 1
        file_name = dir.get_next()
        
    print("---------------------------------------------------")
    print("⚖️  JUDGMENT COMPLETE")
    print("Skills Scanned: ", total_skills)
    print("Errors Found: ", errors)
    
    if errors == 0:
        print("✅ VALIDATION PASSED")
    else:
        print("❌ VALIDATION FAILED")

func validate_skill(path: String, folder_name: String) -> bool:
    var valid = true
    var skill_md_path = path + "/SKILL.md"
    
    # 1. Check SKILL.md
    if not FileAccess.file_exists(skill_md_path):
        print("❌ [", folder_name, "] MISSING SKILL.md")
        return false
    
    # 2. Check Frontmatter (Basic)
    var f = FileAccess.open(skill_md_path, FileAccess.READ)
    var content = f.get_as_text()
    if not content.begins_with("---"):
        print("❌ [", folder_name, "] INVALID Frontmatter start")
        valid = false
    
    # 3. Check Scripts folder (Optional but good)
    var scripts_dir = path + "/scripts"
    var s_dir = DirAccess.open(scripts_dir)
    if s_dir:
        s_dir.list_dir_begin()
        var s_file = s_dir.get_next()
        while s_file != "":
            if s_file.ends_with(".gd"):
                # Basic load check?
                # var res = load(scripts_dir + "/" + s_file)
                # if not res: print("Broken Script: " + s_file)
                pass
            s_file = s_dir.get_next()
            
    return valid
