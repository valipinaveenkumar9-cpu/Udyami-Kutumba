import re
import os

def fix_leader_board():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/ucn/ucnsubscreens/leader_board_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pass context to _leaderTile
    content = content.replace('Widget _leaderTile({', 'Widget _leaderTile(BuildContext context, {')
    # Update calls
    content = content.replace('_leaderTile(\n              rank: "1",', '_leaderTile(context,\n              rank: "1",')
    content = content.replace('_leaderTile(\n              rank: "2",', '_leaderTile(context,\n              rank: "2",')
    content = content.replace('_leaderTile(\n              rank: "3",', '_leaderTile(context,\n              rank: "3",')
    content = content.replace('_leaderTile(\n              rank: "4",', '_leaderTile(context,\n              rank: "4",')
    
    # Replace Colors.white inside _leaderTile with Theme.of(context).colorScheme.surface
    content = content.replace('color: Colors.white,\n        borderRadius: BorderRadius.circular(16),', 'color: Theme.of(context).colorScheme.surface,\n        borderRadius: BorderRadius.circular(16),')
    
    # Pass context to _filterChip
    content = content.replace('Widget _filterChip(String title, bool selected) {', 'Widget _filterChip(BuildContext context, String title, bool selected) {')
    content = content.replace('_filterChip("All", true),', '_filterChip(context, "All", true),')
    content = content.replace('_filterChip("Revenue", false),', '_filterChip(context, "Revenue", false),')
    content = content.replace('_filterChip("F2F", false),', '_filterChip(context, "F2F", false),')
    content = content.replace('_filterChip("Guests", false),', '_filterChip(context, "Guests", false),')
    
    # Inside _filterChip: color: selected ? Colors.teal : Colors.white, -> color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,
    content = content.replace('color: selected ? Colors.teal : Colors.white,', 'color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,')
    content = content.replace('color: selected ? Colors.white : Colors.black,', 'color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_shadows_borders():
    dir_path = 'c:/office/projects/udyamicircleflutter/lib'
    
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace inside BoxShadow
                content = re.sub(
                    r'(BoxShadow\s*\([^)]*?color:\s*)Theme\.of\(context\)\.colorScheme\.onSurface\.withValues\([^)]+\)',
                    r'\g<1>Colors.grey.shade100',
                    content,
                    flags=re.DOTALL
                )
                # Replace inside BoxShadow where there's no space before color: (just in case)
                content = re.sub(
                    r'BoxShadow\(color:\s*Theme\.of\(context\)\.colorScheme\.onSurface\.withValues\([^)]+\)',
                    r'BoxShadow(color: Colors.grey.shade100',
                    content,
                )
                
                # Replace inside Border.all
                content = re.sub(
                    r'(Border\.all\s*\([^)]*?color:\s*)Theme\.of\(context\)\.colorScheme\.onSurface\.withValues\([^)]+\)',
                    r'\g<1>Colors.grey.shade100',
                    content,
                    flags=re.DOTALL
                )
                content = re.sub(
                    r'Border\.all\(color:\s*Theme\.of\(context\)\.colorScheme\.onSurface\.withValues\([^)]+\)',
                    r'Border.all(color: Colors.grey.shade100',
                    content,
                )

                # Replace in bottom navigation menu shadow
                content = re.sub(
                    r'color:\s*Colors\.white\.withOpacity\(0\.3\)',
                    r'color: Colors.grey.shade100',
                    content,
                )
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

fix_leader_board()
fix_shadows_borders()
print("Done fixing borders and shadows.")
