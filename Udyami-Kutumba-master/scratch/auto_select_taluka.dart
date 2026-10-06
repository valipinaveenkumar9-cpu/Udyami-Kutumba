import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart');
  var content = file.readAsStringSync();

  final regex = RegExp(r'    if \(userData != null\) \{.*?    \}', dotAll: true);
  final newCode = '''    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
      _isTalukaHead = _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('assembly_head') || rName.contains('taluka_head') || rName.contains('assembly head') || rName.contains('taluk head') || rName.contains('assembly_president') || rName.contains('assembly president');
      });

      // Try to auto-select taluka based on user roles
      final roleWithTaluka = _currentUser!.roles.firstWhere(
        (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
        _talukaId = roleWithTaluka.talukaId!;
        _selectedTalukaId = _talukaId;
      }
    }''';

  content = content.replaceFirst(regex, newCode);

  final loadDataEndRegex = RegExp(r'      if \(distRes != null && distRes\[.success.\] == true\) \{.*?      \}', dotAll: true);
  final newLoadDataEnd = '''      if (distRes != null && distRes['success'] == true) {
        final List rawDistricts = distRes['data'] ?? [];
        _districts = rawDistricts.cast<Map<String, dynamic>>();
      }

      // If we auto-selected a talukaId from roles, fetch its leadership immediately
      if (_talukaId.isNotEmpty) {
        await _loadLeadership(_talukaId);
      }''';

  content = content.replaceFirst(loadDataEndRegex, newLoadDataEnd);

  file.writeAsStringSync(content);
}
