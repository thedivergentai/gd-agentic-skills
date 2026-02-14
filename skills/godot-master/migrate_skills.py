import os
import shutil
import re
from pathlib import Path

SKILLS_ROOT = Path(r"D:\Development\GDSkills\skills")
MASTER_ROOT = SKILLS_ROOT / "godot-master"
REFS_DIR = MASTER_ROOT / "references"
SCRIPTS_DIR = MASTER_ROOT / "scripts"
ASSETS_DIR = MASTER_ROOT / "assets"

def migrate_skill(skill_dir):
    skill_name = skill_dir.name
    print(f"Processing {skill_name}...")

    skill_md_path = skill_dir / "SKILL.md"
    if not skill_md_path.exists():
        print(f"  No SKILL.md found in {skill_name}, skipping.")
        return

    # Read SKILL.md
    content = skill_md_path.read_text(encoding="utf-8")

    # Regex for link rewriting
    # Pattern 1: (scripts/filename) -> (../scripts/skill_name_filename)
    # Pattern 2: (assets/filename) -> (../assets/skill_name_filename)
    # Pattern 3: (references/filename) -> (../references/skill_name_filename)
    # Pattern 4: (../other-skill/SKILL.md) -> (other-skill.md)
    
    def rewrite_link(match):
        prefix = match.group(1)
        path = match.group(2)
        
        if path.startswith("scripts/"):
            filename = path.replace("scripts/", "")
            return f"{prefix}../scripts/{skill_name}_{filename})"
        elif path.startswith("assets/"):
            filename = path.replace("assets/", "")
            return f"{prefix}../assets/{skill_name}_{filename})"
        elif path.startswith("references/"):
            filename = path.replace("references/", "")
            return f"{prefix}../references/{skill_name}_{filename})"
        elif path.startswith("../") and path.endswith("/SKILL.md"):
            other_skill = path.split("/")[1]
            return f"{prefix}{other_skill}.md)"
        return match.group(0)

    # Simple Markdown link regex: [text](path)
    # We target the (path) part
    content = re.sub(r'(\]\()([^)]+)(\))', rewrite_link, content)

    # Save to references/skill-name.md
    target_md = REFS_DIR / f"{skill_name}.md"
    target_md.write_text(content, encoding="utf-8")

    # Migrate resources
    for subdir_name, target_dir in [("scripts", SCRIPTS_DIR), ("assets", ASSETS_DIR), ("references", REFS_DIR)]:
        source_subdir = skill_dir / subdir_name
        if source_subdir.exists() and source_subdir.is_dir():
            for item in source_subdir.iterdir():
                if item.is_file():
                    target_file = target_dir / f"{skill_name}_{item.name}"
                    shutil.copy2(item, target_file)

def main():
    if not MASTER_ROOT.exists():
        MASTER_ROOT.mkdir(parents=True, exist_ok=True)
    
    REFS_DIR.mkdir(exist_ok=True)
    SCRIPTS_DIR.mkdir(exist_ok=True)
    ASSETS_DIR.mkdir(exist_ok=True)

    for skill_dir in SKILLS_ROOT.iterdir():
        if skill_dir.is_dir() and skill_dir.name != "godot-master" and not skill_dir.name.startswith("."):
            migrate_skill(skill_dir)

if __name__ == "__main__":
    main()
