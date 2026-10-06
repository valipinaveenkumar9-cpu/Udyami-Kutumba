import os

def fix_leader_board():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/ucn/ucnsubscreens/leader_board_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix lines 32 and 34
    content = content.replace('_filterChip("This Quarter", true),', '_filterChip(context, "This Quarter", true),')
    content = content.replace('_filterChip("This Year", false),', '_filterChip(context, "This Year", false),')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_directory_screen():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/ucn/ucnsubscreens/directory_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove static keyword and add BuildContext
    content = content.replace('static Widget _chip(String text, bool selected) {', 'Widget _chip(BuildContext context, String text, bool selected) {')
    content = content.replace('static Widget _memberTile({', 'Widget _memberTile(BuildContext context, {')
    
    # Update invocations of _chip
    content = content.replace('_chip("All", true),', '_chip(context, "All", true),')
    content = content.replace('_chip("Chapter", false),', '_chip(context, "Chapter", false),')
    content = content.replace('_chip("Global", false),', '_chip(context, "Global", false),')
    
    # Update invocations of _memberTile
    content = content.replace('_memberTile(\n                      initials:', '_memberTile(context,\n                      initials:')
    # In case the format differs slightly:
    content = content.replace('_memberTile(initials:', '_memberTile(context, initials:')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

fix_leader_board()
fix_directory_screen()
print("Done fixing compile errors.")
