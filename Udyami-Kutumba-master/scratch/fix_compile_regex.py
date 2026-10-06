import re

def fix_directory_screen_regex():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/ucn/ucnsubscreens/directory_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace _chip("Something", bool) with _chip(context, "Something", bool)
    # But be careful not to replace it if it already has context
    # _chip("State", false) -> _chip(context, "State", false)
    # Match _chip( followed by quote
    content = re.sub(r'_chip\(\s*("|\')', r'_chip(context, \1', content)

    # Replace _memberTile( with _memberTile(context,
    # But only if it's an invocation. The definition is _memberTile(BuildContext context, {
    # So we look for _memberTile( followed by initials: or something.
    content = re.sub(r'_memberTile\(\s*initials:', r'_memberTile(context, initials:', content)
    
    # Also handle _memberTile(\n initials:
    content = re.sub(r'_memberTile\(\s*\n\s*initials:', r'_memberTile(context,\n                                initials:', content)

    # Wait, some might just be _memberTile(
    # Let's see what the file has. Let's just run this much and see.
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

fix_directory_screen_regex()
print("Done fixing directory screen with regex.")
