import os
import re

def fix_damage_3():
    dir_path = 'c:/office/projects/udyamicircleflutter/lib'
    
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if not file.endswith('.dart'):
                continue
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            original = content
            
            # Border.all(color: Colors.grey.shade100)), -> Border.all(color: Colors.grey.shade100),
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\),',
                r'Border.all(color: Colors.grey.shade100),',
                content
            )
            
            # BoxShadow(color: Colors.grey.shade100)), -> BoxShadow(color: Colors.grey.shade100),
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\),',
                r'BoxShadow(color: Colors.grey.shade100),',
                content
            )

            # BoxShadow(color: Colors.grey.shade100))\n -> BoxShadow(color: Colors.grey.shade100)\n
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\)',
                r'BoxShadow(color: Colors.grey.shade100)',
                content
            )

            # Border.all(color: Colors.grey.shade100))\n -> Border.all(color: Colors.grey.shade100)\n
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\)',
                r'Border.all(color: Colors.grey.shade100)',
                content
            )

            if content != original:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

fix_damage_3()
print("Damage fixed 3.")
