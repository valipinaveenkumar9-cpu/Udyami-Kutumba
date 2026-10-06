import os

def fix_cards_screen():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/cards/presentation/cards_screen.dart'
    with open(path, 'r') as f:
        content = f.read()
    
    # In my previous replace_file_content I removed const from Expanded, but wait, the error is still there? 
    # Ah, the error is because the user pasted the SAME list of errors again? No, the user pasted a NEW list of errors, which had the cards_screen error on line 243.
    # Oh! The user request just shows the remaining errors from the second run of flutter analyze that I didn't see because it was truncated. My script `fix_compile.py` already fixed `cards_screen.dart`? No, `fix_compile.py` didn't fix `cards_screen.dart` because the python script only looked at `compile_errors.txt` which had truncated output (so `cards_screen.dart` wasn't in it)! 
    # Ah!!! The previous `compile_errors.txt` only had 390 issues, and I only got the first few lines of flutter analyze in the prompt, so I didn't have the full list!
    
    pass

# We will just replace these specifically.
def fix_campaign():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/communications/presentation/campaign_detail_screen.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for i in [290, 292, 296, 401]:
        if i-1 < len(lines):
            lines[i-1] = lines[i-1].replace('Theme.of(context).colorScheme.surface', 'Colors.white')
            
    for i in [321, 406]:
        if i-1 < len(lines):
            lines[i-1] = lines[i-1].replace('Theme.of(context).colorScheme.onSurface', 'Colors.black')
            
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

def fix_score_card():
    path = 'c:/office/projects/udyamicircleflutter/lib/features/ucn/ucnsubscreens/score_card_screen.dart'
    if not os.path.exists(path): return
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for i in [159]:
        if i-1 < len(lines):
            # The line has `color: Theme.of(context).colorScheme.onSurface,`
            lines[i-1] = lines[i-1].replace('Theme.of(context).colorScheme.onSurface', 'Colors.black')
            
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

fix_campaign()
fix_score_card()
print("Done fixing specific errors.")
