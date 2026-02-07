import os
import json
import re

skills_dir = r"D:\Development\GDSkills\skills"
output_file = r"D:\Development\GDSkills\skills_index.json"

skills_list = []

print(f"Scanning skills in {skills_dir}...")

if not os.path.exists(skills_dir):
    print("Skills directory not found!")
    exit(1)

for item in sorted(os.listdir(skills_dir)):
    item_path = os.path.join(skills_dir, item)
    # Filter out hidden folders and the internal skill-judge tool
    if os.path.isdir(item_path) and not item.startswith(".") and item != "skill-judge":
        skill_md_path = os.path.join(item_path, "SKILL.md")
        
        skill_data = {
            "name": item,
            "description": "",
            "keywords": []
        }

        if os.path.exists(skill_md_path):
            try:
                with open(skill_md_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    # Parse frontmatter
                    match_name = re.search(r"^name:\s*(.+)$", content, re.MULTILINE)
                    match_desc = re.search(r"^description:\s*(.+)$", content, re.MULTILINE)
                    
                    if match_name:
                        skill_data["name"] = match_name.group(1).strip()
                    if match_desc:
                        skill_data["description"] = match_desc.group(1).strip()
                        
                    # Extract keywords from description (simple heuristic or use if present in frontmatter)
                    desc_words = re.findall(r'\b\w{4,}\b', skill_data["description"].lower())
                    skill_data["keywords"] = list(set(desc_words))

            except Exception as e:
                print(f"Error reading {skill_md_path}: {e}")
        
        skills_list.append(skill_data)

print(f"Found {len(skills_list)} skills.")

try:
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(skills_list, f, indent=2)
    print(f"Successfully wrote skills_index.json to {output_file}")
except Exception as e:
    print(f"Error writing output file: {e}")
