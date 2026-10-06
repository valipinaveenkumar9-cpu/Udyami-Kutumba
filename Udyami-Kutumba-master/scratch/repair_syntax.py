import os
import re

def fix_damage():
    dir_path = 'c:/office/projects/udyamicircleflutter/lib'
    
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if not file.endswith('.dart'):
                continue
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            original = content
            
            # Border.all(color: Colors.grey.shade100).colorScheme.surface -> Border.all(color: Colors.grey.shade100
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\.colorScheme\.[a-zA-Z]+',
                r'Border.all(color: Colors.grey.shade100',
                content
            )
            
            # Border.all(color: Colors.grey.shade100).withOpacity(0.1) -> Border.all(color: Colors.grey.shade100
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\.with(Opacity|Values)\([^)]*\)',
                r'Border.all(color: Colors.grey.shade100',
                content
            )
            
            # BoxShadow(color: Colors.grey.shade100).withOpacity(0.1) -> BoxShadow(color: Colors.grey.shade100
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\.with(Opacity|Values)\([^)]*\)',
                r'BoxShadow(color: Colors.grey.shade100',
                content
            )

            # BoxShadow(color: Colors.grey.shade100), -> BoxShadow(color: Colors.grey.shade100,
            # wait, if it's BoxShadow(color: Colors.grey.shade100),\n blurRadius: 10,
            # this means we should replace `),` with `,` ONLY IF it is followed by blurRadius, spreadRadius, offset, etc.
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

            # What if it was `(0.02),` from withValues(alpha: 0.02)?
            content = re.sub(
                r'BoxShadow\(color:\s*Colors\.grey\.shade100\)\([^)]*\)\s*,(\s*(?:blurRadius|spreadRadius|offset))',
                r'BoxShadow(color: Colors.grey.shade100,\1',
                content
            )
            
            content = re.sub(
                r'Border\.all\(color:\s*Colors\.grey\.shade100\)\([^)]*\)\s*,(\s*(?:width|style|strokeAlign))',
                r'Border.all(color: Colors.grey.shade100,\1',
                content
            )

            if content != original:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

fix_damage()
print("Damage fixed.")
