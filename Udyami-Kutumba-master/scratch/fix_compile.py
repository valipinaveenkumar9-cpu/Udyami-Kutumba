import re

def main():
    with open('c:/office/projects/udyamicircleflutter/scratch/compile_errors.txt', 'r') as f:
        lines = f.readlines()
        
    for line in lines:
        if not line.strip():
            continue
            
        match = re.search(r'^(lib[/\\].+?\.dart):(\d+):', line)
        if match:
            filepath = 'c:/office/projects/udyamicircleflutter/' + match.group(1)
            line_num = int(match.group(2)) - 1
            
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.readlines()
            except:
                continue
                
            if 'PdfTheme' in line:
                # PDF generator doesn't use app theme
                if 0 <= line_num < len(content):
                    content[line_num] = content[line_num].replace('PdfTheme.of(context).colorScheme.surface', 'PdfColors.white')
                    content[line_num] = content[line_num].replace('PdfTheme.of(context).colorScheme.onSurface', 'PdfColors.black')
                    
            elif 'Not a constant expression' in line or 'Method invocation is not a constant expression' in line:
                # Need to remove const from this line and up to 10 lines above
                for i in range(10):
                    idx = line_num - i
                    if 0 <= idx < len(content):
                        if 'const ' in content[idx]:
                            # Only remove the last const if multiple or the first const?
                            content[idx] = content[idx].replace('const ', '')
                            break
                            
            elif "The getter 'context' isn't defined" in line or "Undefined name 'context'" in line:
                # We used Theme.of(context) in a place without context.
                # Revert to Colors.white/black
                if 0 <= line_num < len(content):
                    content[line_num] = content[line_num].replace('Theme.of(context).colorScheme.surface', 'Colors.white')
                    content[line_num] = content[line_num].replace('Theme.of(context).colorScheme.onSurface', 'Colors.black')
                    
            elif "Couldn't find constructor 'Theme.of'" in line:
                if 0 <= line_num < len(content):
                    content[line_num] = content[line_num].replace('const Theme.of(context)', 'Theme.of(context)')
                    
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(content)
                
    print("Done fixing compile errors.")

if __name__ == '__main__':
    main()
