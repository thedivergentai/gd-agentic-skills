import os
import json
import re

# Use relative paths for portability, or absolute if preferred
SKILLS_DIR = r"D:\Development\GDSkills\skills"
OUTPUT_FILE = r"D:\Development\GDSkills\skills_index.json"

def get_frontmatter(content):
    match = re.search(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return {}
    
    data = {}
    for line in match.group(1).split('\n'):
        if ':' in line:
            key, val = line.split(':', 1)
            data[key.strip()] = val.strip()
    return data

def get_keywords(description):
    # Try to find "Trigger keywords: ..." or "Keywords ..."
    match = re.search(r'(?:Trigger keywords|Keywords)[:\s]+(.*?)(?:\.|$)', description, re.IGNORECASE)
    if match:
        # Split by comma
        return [k.strip() for k in match.group(1).split(',') if k.strip()]
    
    # Fallback to simple extraction if no explicit keywords found in prose
    desc_words = re.findall(r'\b\w{4,}\b', description.lower())
    return list(set(desc_words))

def update_index():
    print(f"Scanning skills in {SKILLS_DIR}...")
    
    if not os.path.exists(SKILLS_DIR):
        print("Skills directory not found!")
        exit(1)

    skills_list = []
    
    # Iterate through all directories
    for item in sorted(os.listdir(SKILLS_DIR)):
        item_path = os.path.join(SKILLS_DIR, item)
        
        # Filter out hidden folders
        if os.path.isdir(item_path) and not item.startswith("."):
            skill_md_path = os.path.join(item_path, "SKILL.md")
            
            if os.path.exists(skill_md_path):
                try:
                    with open(skill_md_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                        fm = get_frontmatter(content)
                        name = fm.get('name', item)
                        description = fm.get('description', '')
                        
                        # Get keywords from description or frontmatter (if someone added it there)
                        keywords = get_keywords(description)

                        skill_data = {
                            "name": name,
                            "description": description,
                            "keywords": keywords,
                            "path": f"skills/{item}"
                        }
                        
                        skills_list.append(skill_data)
                        
                except Exception as e:
                    print(f"Error reading {skill_md_path}: {e}")
            else:
                 print(f"Skipping {item} - No SKILL.md found")

    print(f"Found {len(skills_list)} skills.")

    try:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(skills_list, f, indent=2)
        print(f"Successfully wrote {len(skills_list)} skills to {OUTPUT_FILE}")
    except Exception as e:
        print(f"Error writing output file: {e}")

if __name__ == "__main__":
    update_index()
