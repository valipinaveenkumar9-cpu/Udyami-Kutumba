import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/directory/presentation/directory_screen.dart');
  var content = file.readAsStringSync();

  // 1. Update the mapping to include isBasic and isPatron
  content = content.replaceAll(
    "'isPrime': e['isPrime'] == true,",
    "'isPrime': e['isPrime'] == true,\n                'isBasic': e['isBasic'] == true,\n                'isPatron': e['isPatron'] == true,"
  );

  // 2. Update the role filter UI to include "Basic", "Prime", "Patron"
  content = content.replaceAll(
    '["All", "Circle Roles", "Designations"]',
    '["All", "Circle Roles", "Designations", "Basic", "Prime", "Patron"]'
  );

  // 3. Update the filter logic
  final filterRegex = RegExp(r'if \(_selectedRoleFilter == "Designations"\) return hasDesignationRole\(\);', dotAll: true);
  content = content.replaceAll(filterRegex, '''if (_selectedRoleFilter == "Designations") return hasDesignationRole();
                    if (_selectedRoleFilter == "Basic") return m['isBasic'] == true;
                    if (_selectedRoleFilter == "Prime") return m['isPrime'] == true;
                    if (_selectedRoleFilter == "Patron") return m['isPatron'] == true;''');

  file.writeAsStringSync(content);
}
