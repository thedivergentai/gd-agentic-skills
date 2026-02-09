import os
import re

SKILLS_DIR = r"d:\Development\GDSkills\skills"
GODOT_MASTER_FILE = os.path.join(SKILLS_DIR, "godot-master", "SKILL.md")

def fixup():
    # 1. Fix godot-master links
    if os.path.exists(GODOT_MASTER_FILE):
        with open(GODOT_MASTER_FILE, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace [name](godot-something/SKILL.md) with [name](../godot-something/SKILL.md)
        # Avoid double ../ if already present
        content = re.sub(r'\]\((?!(\.\./|http|#))', r'](../', content)
        
        with open(GODOT_MASTER_FILE, "w", encoding="utf-8") as f:
            f.write(content)
        print("Fixed links in godot-master/SKILL.md")

    # 2. Cleanup all SKILL.md files
    folders = [f for f in os.listdir(SKILLS_DIR) if os.path.isdir(os.path.join(SKILLS_DIR, f))]
    
    # Build list of all new skill names to replace in text
    skill_names = folders # e.g. ["godot-2d-animation", ...]
    
    for folder in folders:
        skill_file = os.path.join(SKILLS_DIR, folder, "SKILL.md")
        if not os.path.exists(skill_file):
            continue
            
        with open(skill_file, "r", encoding="utf-8") as f:
            content = f.read()

        # Deduplicate ## Reference headers
        # If there are multiple "## Reference" lines, merge them or keep the last one with the master link
        if content.count("## Reference") > 1:
            # Simple approach: find the first instance and the last instance
            # and merge content until the next header or end
            sections = re.split(r'\n## Reference\n', content)
            # Combine the body of all reference sections and prepend once
            new_ref_content = ""
            for i in range(1, len(sections)):
                # Take everything until the next header or end
                sub_parts = re.split(r'\n#+ ', sections[i], 1)
                new_ref_content += sub_parts[0] + "\n"
                if len(sub_parts) > 1:
                    # Oops, we split too much? No, sub_parts[1] is the rest of the file
                    # This logic is a bit complex, let's simplify
                    pass
            
            # Simplified: just remove the one that DOESN'T have godot-master link
            # Or just normalize it.
            content = content.replace("\n## Reference\n", "\n### Related\n") # Temporary rename
            content = content.replace("\n### Related\n", "\n## Reference\n", 1) # Restore first
            # The script added the last one. Let's just remove any redundant "## Reference" strings
            # and ensure nice spacing.
            lines = content.split("\n")
            new_lines = []
            ref_found = False
            for line in lines:
                if line.strip() == "## Reference":
                    if not ref_found:
                        new_lines.append(line)
                        ref_found = True
                    else:
                        continue # Skip duplicate header
                else:
                    new_lines.append(line)
            content = "\n".join(new_lines)

        # Update text mentions of skills (e.g. Related: ability-system -> Related: godot-ability-system)
        for name in skill_names:
            old_name = name.replace("godot-", "", 1)
            if old_name:
                # Use word boundaries to avoid partial matches
                # But be careful with dashes.
                # Regex for "not preceded by godot-" and "is old_name"
                pattern = r'(?<!godot-)\b' + re.escape(old_name) + r'\b'
                content = re.sub(pattern, name, content)

        with open(skill_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Cleaned up {folder}")

if __name__ == "__main__":
    fixup()
