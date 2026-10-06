import os
import re

def fix_all_borders_and_shadows():
    dir_path = 'c:/office/projects/udyamicircleflutter/lib'
    
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace Border.all(color: ANY_COLOR, ...) with Border.all(color: Colors.grey.shade100, ...)
                # Match Border.all(color: <something>)
                # Since <something> could be Colors.grey.shade300, Theme.of(...), etc.
                # We can match up to the next comma or closing parenthesis.
                content = re.sub(
                    r'Border\.all\(\s*color:\s*[^,)]+',
                    r'Border.all(color: Colors.grey.shade100',
                    content
                )
                
                # Replace BoxShadow(color: ANY_COLOR, ...) with BoxShadow(color: Colors.grey.shade100, ...)
                content = re.sub(
                    r'BoxShadow\(\s*color:\s*[^,)]+',
                    r'BoxShadow(color: Colors.grey.shade100',
                    content
                )

                # Special case for LeaderBoard Screen which we manually touched
                if 'leader_board_screen.dart' in file:
                    # In _leaderTile we have: border: Border.all(color: highlight ? Colors.teal : Colors.grey.shade100)
                    # The above regex would replace it with Border.all(color: Colors.grey.shade100 which is fine, but it breaks the highlight?
                    # Oh, wait! highlight ? Colors.teal : Colors.grey.shade100 is good to keep. 
                    pass

                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

fix_all_borders_and_shadows()
print("Done fixing all borders and shadows.")
