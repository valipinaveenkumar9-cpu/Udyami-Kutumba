import os
import re

files = [
    'lib/features/ucn/ucnsubscreens/face_to_face_detail_screen.dart',
    'lib/features/ucn/ucnsubscreens/face_to_face_invite_screen.dart',
    'lib/features/ucn/ucnsubscreens/guests_screen.dart',
    'lib/features/ucn/ucnsubscreens/passleadscreen.dart',
    'lib/features/ucn/ucnsubscreens/invite_to_ucn_screen.dart'
]

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace("import 'package:contacts_service/contacts_service.dart';", "import 'package:flutter_contacts/flutter_contacts.dart';")

    content = content.replace(
        "final contact = await ContactsService.openDeviceContactPicker();\n    if (contact != null && mounted) {\n      setState(() {\n        _nameController.text = contact.displayName ?? contact.givenName ?? '';\n        if (contact.phones != null && contact.phones!.isNotEmpty) {\n          _phoneController.text = contact.phones!.first.value ?? '';\n        }\n      });\n    }",
        "if (await FlutterContacts.requestPermission()) {\n      final contact = await FlutterContacts.openExternalPick();\n      if (contact != null && mounted) {\n        final fullContact = await FlutterContacts.getContact(contact.id);\n        if (fullContact != null) {\n          setState(() {\n            _nameController.text = fullContact.displayName;\n            if (fullContact.phones.isNotEmpty) {\n              _phoneController.text = fullContact.phones.first.number;\n            }\n          });\n        }\n      }\n    }"
    )

    content = content.replace(
        "final contact = await ContactsService.openDeviceContactPicker();\n                              if (contact != null) {\n                                final name = contact.displayName ?? contact.givenName ?? '';\n                                final phone = (contact.phones != null && contact.phones!.isNotEmpty) ? contact.phones!.first.value ?? '' : '';\n                                print('DEV DEBUG - Selected Name: \, Phone: \');\n                                widget.onSelected(name, phone, '', '');\n                              }",
        "if (await FlutterContacts.requestPermission()) {\n                                final contact = await FlutterContacts.openExternalPick();\n                                if (contact != null) {\n                                  final fullContact = await FlutterContacts.getContact(contact.id);\n                                  if (fullContact != null) {\n                                    final name = fullContact.displayName;\n                                    final phone = (fullContact.phones.isNotEmpty) ? fullContact.phones.first.number : '';\n                                    print('DEV DEBUG - Selected Name: \, Phone: \');\n                                    widget.onSelected(name, phone, '', '');\n                                  }\n                                }\n                              }"
    )

    content = content.replace(
        "final contact = await ContactsService.openDeviceContactPicker();\n                              if (contact != null) {\n                                final name = contact.displayName ?? contact.givenName ?? '';\n                                final phone = (contact.phones != null && contact.phones!.isNotEmpty) ? contact.phones!.first.value ?? '' : '';\n                                print('DEV DEBUG - Selected Name: \, Phone: \');\n                                widget.onSelected(null, name, phone);\n                            if (Navigator.canPop(context)) Navigator.pop(context);\n                              }",
        "if (await FlutterContacts.requestPermission()) {\n                                final contact = await FlutterContacts.openExternalPick();\n                                if (contact != null) {\n                                  final fullContact = await FlutterContacts.getContact(contact.id);\n                                  if (fullContact != null) {\n                                    final name = fullContact.displayName;\n                                    final phone = (fullContact.phones.isNotEmpty) ? fullContact.phones.first.number : '';\n                                    print('DEV DEBUG - Selected Name: \, Phone: \');\n                                    widget.onSelected(null, name, phone);\n                                    if (Navigator.canPop(context)) Navigator.pop(context);\n                                  }\n                                }\n                              }"
    )

    content = content.replace(
        "final contact = await ContactsService.openDeviceContactPicker();\n                              if (contact != null) {\n                                final name = contact.displayName ?? contact.givenName ?? '';\n                                final phone = (contact.phones != null && contact.phones!.isNotEmpty) ? contact.phones!.first.value ?? '' : '';\n                                print('DEV DEBUG - Selected Name: \, Phone: \');\n                                widget.onSelected(name, phone);\n                            if (Navigator.canPop(context)) Navigator.pop(context);\n                              }",
        "if (await FlutterContacts.requestPermission()) {\n                                final contact = await FlutterContacts.openExternalPick();\n                                if (contact != null) {\n                                  final fullContact = await FlutterContacts.getContact(contact.id);\n                                  if (fullContact != null) {\n                                    final name = fullContact.displayName;\n                                    final phone = (fullContact.phones.isNotEmpty) ? fullContact.phones.first.number : '';\n                                    print('DEV DEBUG - Selected Name: \, Phone: \');\n                                    widget.onSelected(name, phone);\n                                    if (Navigator.canPop(context)) Navigator.pop(context);\n                                  }\n                                }\n                              }"
    )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed {filepath}')

for f in files:
    if os.path.exists(f):
        fix_file(f)
