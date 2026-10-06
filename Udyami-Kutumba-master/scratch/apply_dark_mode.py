import os
import re
import subprocess

def replace_colors_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Replace Colors.black with Theme.of(context).colorScheme.onSurface
    content = re.sub(r'Colors\.black87', r'Theme.of(context).colorScheme.onSurface', content)
    content = re.sub(r'Colors\.black54', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)', content)
    content = re.sub(r'Colors\.black\b', r'Theme.of(context).colorScheme.onSurface', content)
    
    # Replace Colors.white with Theme.of(context).colorScheme.surface
    # Only if it's likely a background. This is tricky.
    # Let's map Colors.white to Theme.of(context).colorScheme.surface generally, 
    # except we should check if they explicitly want white text somewhere.
    # For now, let's replace Colors.white with Theme.of(context).colorScheme.surface
    content = re.sub(r'Colors\.white70', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)', content)
    content = re.sub(r'Colors\.white\b', r'Theme.of(context).colorScheme.surface', content)

    # Hardcoded dark colors
    content = re.sub(r'Color\(0xff18191A\)', r'Theme.of(context).colorScheme.surface', content)
    content = re.sub(r'Color\(0xff242526\)', r'Theme.of(context).colorScheme.surfaceContainer', content)
    content = re.sub(r'Color\(0xffF5F5F5\)', r'Theme.of(context).colorScheme.surface', content)

    if content != original_content:
        # Remove const from obvious widgets that now use Theme
        content = re.sub(r'const\s+(TextStyle\()', r'\1', content)
        content = re.sub(r'const\s+(Icon\()', r'\1', content)
        content = re.sub(r'const\s+(BoxDecoration\()', r'\1', content)
        content = re.sub(r'const\s+(Text\()', r'\1', content)
        content = re.sub(r'const\s+(Color\()', r'\1', content)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated colors in {filepath}")
        return True
    return False


def fix_const_errors():
    print("Fixing const errors via flutter analyze...")
    max_iters = 20
    for i in range(max_iters):
        print(f"Iteration {i+1}...")
        result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, cwd='c:/office/projects/udyamicircleflutter')
        
        lines = result.stdout.split('\n')
        fixed = False
        
        for line in lines:
            if "error" in line.lower() and ("const" in line.lower() or "constant" in line.lower() or "not a constant" in line.lower()):
                # Format: info • Invalid constant value • lib/main.dart:15:10 • invalid_constant
                # Format: error • Const variables must be initialized with a constant value • lib/x.dart:1:2 • ...
                match = re.search(r'(lib[/\\][^:]+\.dart):(\d+):(\d+)', line)
                if match:
                    filepath = os.path.join('c:/office/projects/udyamicircleflutter', match.group(1))
                    line_num = int(match.group(2)) - 1
                    
                    if os.path.exists(filepath):
                        with open(filepath, 'r', encoding='utf-8') as f:
                            content_lines = f.readlines()
                        
                        if 0 <= line_num < len(content_lines):
                            # We search backwards up to 3 lines to find and remove 'const '
                            for offset in range(3):
                                target_idx = line_num - offset
                                if 0 <= target_idx < len(content_lines):
                                    if 'const ' in content_lines[target_idx]:
                                        content_lines[target_idx] = content_lines[target_idx].replace('const ', '', 1)
                                        fixed = True
                                        break
                        
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.writelines(content_lines)

        if not fixed:
            print("No more const errors fixed.")
            break

def main():
    root_dir = 'c:/office/projects/udyamicircleflutter/lib'
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(subdir, file)
                replace_colors_in_file(filepath)
    
    fix_const_errors()
    print("Done refactoring theme!")

if __name__ == '__main__':
    main()
