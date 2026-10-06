import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/core/models/user_model.dart');
  var content = file.readAsStringSync();

  final pattern = "parsedRoles.add(RoleModel.fromJson(r['role'] as Map<String, dynamic>));";

  final replace = '''final roleData = Map<String, dynamic>.from(r['role'] as Map<String, dynamic>);
          if (r.containsKey('assignment')) {
            roleData['assignment'] = r['assignment'];
          }
          if (r.containsKey('talukaId')) {
            roleData['talukaId'] = r['talukaId'];
          }
          if (r.containsKey('wardId')) {
            roleData['wardId'] = r['wardId'];
          }
          parsedRoles.add(RoleModel.fromJson(roleData));''';

  if (content.contains(pattern)) {
    content = content.replaceFirst(pattern, replace);
    file.writeAsStringSync(content);
    print("Replaced successfully!");
  } else {
    print("Pattern not found!");
  }
}
