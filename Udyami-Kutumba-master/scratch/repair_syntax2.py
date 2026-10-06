import os
import re

def fix_damage_2():
    dir_path = 'c:/office/projects/udyamicircleflutter/lib'
    
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if not file.endswith('.dart'):
                continue
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            original = content
            
            # BoxShadow(color: Colors.grey.shade100).colorScheme.onSurface.withOpacity(0.03),
            # -> BoxShadow(color: Colors.grey.shade100,
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\.[a-zA-Z0-9_.]+(?:\([^)]*\))?\s*,(\s*(?:blurRadius|spreadRadius|offset))',
                r'BoxShadow(color: Colors.grey.shade100,\1',
                content
            )

            # Border.all(color: Colors.grey.shade100).colorScheme.onSurface, width: ...
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\.[a-zA-Z0-9_.]+(?:\([^)]*\))?\s*,(\s*(?:width|style|strokeAlign))',
                r'Border.all(color: Colors.grey.shade100,\1',
                content
            )

            # BoxShadow(color: Colors.grey.shade100).colorScheme.onSurface.withOpacity(0.03) -> BoxShadow(color: Colors.grey.shade100
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\.[a-zA-Z0-9_.]+(?:\([^)]*\))?',
                r'BoxShadow(color: Colors.grey.shade100',
                content
            )
            
            # Border.all(...) without comma
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\.[a-zA-Z0-9_.]+(?:\([^)]*\))?',
                r'Border.all(color: Colors.grey.shade100',
                content
            )

            # What if there is just an extra `)` closing something? Like:
            # BoxShadow(color: Colors.grey.shade100), -> BoxShadow(color: Colors.grey.shade100,
            # if followed by blurRadius etc.
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\s*,(\s*(?:blurRadius|spreadRadius|offset))',
                r'BoxShadow(color: Colors.grey.shade100,\1',
                content
            )
            
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\s*,(\s*(?:width|style|strokeAlign))',
                r'Border.all(color: Colors.grey.shade100,\1',
                content
            )

            if content != original:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

fix_damage_2()
print("Damage fixed 2.")
