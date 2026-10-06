import os
import re

directory = 'lib/features/ucn/ucnsubscreens'

for filename in os.listdir(directory):
    if filename.endswith('.dart'):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        
        # Replace the onPressed block for FlutterNativeContactPicker
        pattern = r'onPressed:\s*\(\)\s*async\s*\{\s*final\s+FlutterNativeContactPicker\s+_contactPicker\s*=\s*FlutterNativeContactPicker\(\);\s*final\s+contact\s*=\s*await\s+_contactPicker\.selectContact\(\);\s*if\s*\(contact\s*!=\s*null\)\s*\{\s*final\s+name\s*=\s*contact\.fullName\s*\?\?\s*\'\';\s*final\s+phone\s*=\s*contact\.phoneNumbers\?\.isNotEmpty\s*==\s*true\s*\?\s*contact\.phoneNumbers!\.first\s*:\s*\'\';\s*widget\.onSelected\(name,\s*phone\);\s*\}\s*\}'
        
        replacement = '''onPressed: () async {
                            print('DEV DEBUG - Tapped Open Phone Contact Picker');
                            try {
                              final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
                              print('DEV DEBUG - Awaiting selectContact()');
                              final contact = await _contactPicker.selectContact();
                              print('DEV DEBUG - Contact selected: \');
                              if (contact != null) {
                                final name = contact.fullName ?? '';
                                final phone = contact.phoneNumbers?.isNotEmpty == true ? contact.phoneNumbers!.first : '';
                                print('DEV DEBUG - Calling onSelected with name: \, phone: \');
                                widget.onSelected(name, phone);
                              } else {
                                print('DEV DEBUG - Contact was null (user cancelled)');
                              }
                            } catch (e) {
                              print('DEV DEBUG - Error picking contact: \');
                            }
                          }'''
                          
        content = re.sub(pattern, replacement, content)
        
        # Also let's fix _GuestMemberSelectionSheet / _MemberSelectionSheet / _LeadBusinessSelectionSheet onSelected callback
        # to add prints
        
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Updated {filename}')

