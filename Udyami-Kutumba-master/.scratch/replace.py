import re

def process_file(path, replacements):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

replacements_assembly = [
    (\"const Text('Assembly Members'\", \"Text('\ Members'\"),
    ('\"Please select an Assembly.\"', '\"Please select an Assembly/Taluka.\"'),
    ('\"No Assembly data found\"', '\"No data found.\"'),
    ('\"Wards/Areas (\)\"', '\"Areas (\)\"'),
    ('\"No Wards found in this Assembly.\"', '\"No Areas found.\"'),
    ('\"Auto-loaded based on your assigned Assembly\"', '\"Auto-loaded based on your assigned profile\"'),
    ('\"Select Assembly / Taluka\"', '\"Select Taluka\"'),
    ('\"Total Wards\"', '\"Total Areas\"'),
    (\"'Unknown Ward'\", \"'Unknown Area'\")
]
process_file('lib/features/ucn/ucnsubscreens/assembly_ucn_members_screen.dart', replacements_assembly)

replacements_circle = [
    (\"const Text('Area/Ward Members'\", \"const Text('Area Members'\"),
    (\"'Ward ID not found'\", \"'Area ID not found'\")
]
process_file('lib/features/ucn/ucnsubscreens/circle_ucn_members_screen.dart', replacements_circle)
print('Done!')
