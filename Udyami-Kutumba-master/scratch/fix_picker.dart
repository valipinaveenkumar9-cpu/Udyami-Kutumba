import 'dart:io';

void main() {
  final directory = Directory('lib/features/ucn/ucnsubscreens');
  final pattern = RegExp(
    r'onPressed:\s*\(\)\s*async\s*\{\s*final\s+FlutterNativeContactPicker\s+_contactPicker\s*=\s*FlutterNativeContactPicker\(\);\s*final\s+contact\s*=\s*await\s+_contactPicker\.selectContact\(\);\s*if\s*\(contact\s*!=\s*null\)\s*\{\s*final\s+name\s*=\s*contact\.fullName\s*\?\?\s*\'';\s*final\s+phone\s*=\s*contact\.phoneNumbers\?\.isNotEmpty\s*==\s*true\s*\?\s*contact\.phoneNumbers!\.first\s*:\s*\'\';\s*widget\.onSelected\(name,\s*phone\);\s*\}\s*\}',
    multiLine: true,
  );

  final replacement = '''onPressed: () async {
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
                          }''';

  for (var entity in directory.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final newContent = content.replaceAll(pattern, replacement);
      
      if (content != newContent) {
        entity.writeAsStringSync(newContent);
        print('Updated');
      }
    }
  }
}
