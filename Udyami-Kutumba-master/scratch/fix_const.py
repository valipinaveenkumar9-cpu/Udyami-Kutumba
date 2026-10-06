import os
import re
import subprocess

def fix_const_errors():
    print("Fixing const errors via flutter analyze...")
    max_iters = 30
    for i in range(max_iters):
        print(f"Iteration {i+1}...")
        result = subprocess.run(['flutter.bat', 'analyze'], capture_output=True, text=True, cwd='c:/office/projects/udyamicircleflutter')
        
        lines = result.stdout.split('\n')
        fixed = False
        
        for line in lines:
            if "error" in line.lower() and ("const" in line.lower() or "constant" in line.lower() or "not a constant" in line.lower()):
                match = re.search(r'(lib[/\\][^:]+\.dart):(\d+):(\d+)', line)
                if match:
                    filepath = os.path.join('c:/office/projects/udyamicircleflutter', match.group(1))
                    line_num = int(match.group(2)) - 1
                    
                    if os.path.exists(filepath):
                        with open(filepath, 'r', encoding='utf-8') as f:
                            content_lines = f.readlines()
                        
                        if 0 <= line_num < len(content_lines):
                            for offset in range(4):
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

if __name__ == '__main__':
    fix_const_errors()
