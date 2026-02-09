import os
import re
import shutil

SKILLS_DIR = r"d:\Development\GDSkills\skills"
GODOT_MASTER_DIR = os.path.join(SKILLS_DIR, "godot-master")
ROOT_MOC_FILE = os.path.join(SKILLS_DIR, "SKILL.md")

def refactor():
    # 1. Get all folders
    items = os.listdir(SKILLS_DIR)
    folders = [f for f in items if os.path.isdir(os.path.join(SKILLS_DIR, f))]
    
    # 2. Determine mapping
    mapping = {}
    for folder in folders:
        if folder.startswith("godot-"):
            mapping[folder] = folder
        else:
            mapping[folder] = "godot-" + folder
            
    print(f"Mapping {len(mapping)} folders...")

    # 3. Create godot-master directory and move root SKILL.md
    if not os.path.exists(GODOT_MASTER_DIR):
        os.makedirs(GODOT_MASTER_DIR)
        print(f"Created {GODOT_MASTER_DIR}")
        
    if os.path.exists(ROOT_MOC_FILE):
        shutil.move(ROOT_MOC_FILE, os.path.join(GODOT_MASTER_DIR, "SKILL.md"))
        print(f"Moved MOC to {GODOT_MASTER_DIR}")

    # 4. Rename folders (excluding godot-master itself if it already existed)
    for old_name, new_name in mapping.items():
        if old_name != new_name:
            old_path = os.path.join(SKILLS_DIR, old_name)
            new_path = os.path.join(SKILLS_DIR, new_name)
            if os.path.exists(old_path):
                os.rename(old_path, new_path)
                print(f"Renamed: {old_name} -> {new_name}")

    # 5. Update contents of all SKILL.md files
    all_skill_dirs = os.listdir(SKILLS_DIR)
    for folder in all_skill_dirs:
        folder_path = os.path.join(SKILLS_DIR, folder)
        if not os.path.isdir(folder_path):
            continue
            
        skill_file = os.path.join(folder_path, "SKILL.md")
        if not os.path.exists(skill_file):
            continue
            
        with open(skill_file, "r", encoding="utf-8") as f:
            content = f.read()

        # Update frontmatter name
        # ---
        # name: old-name
        if folder == "godot-master":
            content = re.sub(r"name:\s*gd-agentic-skills-moc", "name: godot-master", content)
        else:
            # Find the old name from the mapping if possible
            old_name = None
            for o, n in mapping.items():
                if n == folder:
                    old_name = o
                    break
            
            if old_name:
                content = re.sub(r"name:\s*" + re.escape(old_name), f"name: {folder}", content)

        # Update all links in content based on mapping
        for old_name, new_name in mapping.items():
            if old_name != new_name:
                # Replace paths like [link](old-name/SKILL.md) -> [link](new-name/SKILL.md)
                content = content.replace(f"({old_name}/", f"({new_name}/")
                # Also replace plain-text references if they match exactly (riskier but desired here)
                # But let's stick to links first as they are most common
                # And handle the frontmatter names already done above

        # Add organic backlink to godot-master if not present (except in godot-master itself)
        if folder != "godot-master" and "godot-master" not in content:
            backlink = "\n\n## Reference\n- Master Skill: [godot-master](../godot-master/SKILL.md)\n"
            content += backlink

        with open(skill_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Updated content for {folder}")

if __name__ == "__main__":
    refactor()
