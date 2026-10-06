import os
import re

files = [
    'lib/features/ucn/ucnsubscreens/face_to_face_detail_screen.dart',
    'lib/features/ucn/ucnsubscreens/face_to_face_invite_screen.dart',
    'lib/features/ucn/ucnsubscreens/invite_to_ucn_screen.dart',
    'lib/features/ucn/ucnsubscreens/passleadscreen.dart'
]

for fpath in files:
    if not os.path.exists(fpath): continue
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Replace the entire button onPressed block
    # We will find: onPressed: () async { ... } up to icon: const Icon(Icons.perm_contact_calendar)
    
    # Let's extract the exact widget.onSelected(...) string first so we can reuse it
    match = re.search(r'widget\.onSelected\([^)]+\);', content)
    if not match:
        continue
    on_selected_call = match.group(0)

    # Now replace the onPressed block entirely
    pattern = r'onPressed:\s*\(\)\s*async\s*\{.*?\},\s*icon:\s*const\s*Icon\(Icons\.perm_contact_calendar\)'
    
    replacement = '''onPressed: () async {
                            final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
                            dynamic contact;
                            try {
                              contact = await _contactPicker.selectContact();
                            } catch (e) {
                              debugPrint('Contact picker error: \');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to read contact data from phone.')),
                                );
                              }
                            }
                            if (contact != null) {
                              final name = contact.fullName ?? '';
                              final phone = (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) ? contact.phoneNumbers!.first : '';
                              ''' + on_selected_call + ''' 
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.perm_contact_calendar)'''
                          
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    # Ensure correct import
    content = content.replace("import 'package:flutter_contacts/flutter_contacts.dart';", "import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';")
    
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
