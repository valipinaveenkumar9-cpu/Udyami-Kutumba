import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart');
  var content = file.readAsStringSync();

  // 1. Rename class and state
  content = content.replaceAll('CircleRolesScreen', 'AssemblyRolesScreen');
  content = content.replaceAll('_CircleRolesScreenState', '_AssemblyRolesScreenState');
  
  // 2. Update AppBar title
  content = content.replaceAll('Circle roles', 'Assembly Roles');
  
  // 3. Update imports
  content = content.replaceFirst(
    "import '../../../core/api/role_api.dart';",
    "import '../../../core/api/role_api.dart';\nimport '../../../core/api/taluka_api.dart';"
  );

  // 4. Update variables
  content = content.replaceAll('bool _isPresident = false;', 'bool _isTalukaHead = false;\n  String _talukaId = \'\';\n  List<dynamic> _assemblyLeadership = [];');

  // 5. Replace _loadData entirely
  final loadDataRegex = RegExp(r'  Future<void> _loadData\(\) async \{.*?(?=  void _showAssignRoleSheet)', dotAll: true);
  final loadDataReplacement = '''
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userData = SessionManager.user;
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);

      // Determine if current user is a Taluka Head
      _isTalukaHead = _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('taluka_head') || rName.contains('assembly_head');
      });
    }

    try {
      // fallback
      _talukaId = "f9a6257c-7cbe-4c1c-a25a-8403ee801110";

      final res = await AuthAPI().getAllUsers();
      if (res != null) {
        List data = [];
        if (res is Map && res['success'] == true && res.containsKey('data')) {
          data = res['data'] ?? [];
        } else if (res is Map && res.containsKey('membershipUsers')) {
          data = res['membershipUsers'] ?? [];
        } else if (res is List) {
          data = res;
        }
        _members = data.map((e) => UserModel.fromJson(e)).toList();
      }

      // Fetch Assembly Leadership
      try {
        final leadershipRes = await TalukaAPI().getAssemblyLeadership(_talukaId);
        if (leadershipRes != null && leadershipRes['success'] == true) {
          _assemblyLeadership = leadershipRes['data'] ?? [];
        }
      } catch (e) {
        print('DEV DEBUG - AssemblyRolesScreen: Failed to fetch assembly leadership: \$e');
      }
    } catch (e) {
      print("DEV DEBUG - Error in _loadData: \$e");
    }

    if (mounted) setState(() => _isLoading = false);
  }
''';
  content = content.replaceFirst(loadDataRegex, loadDataReplacement);

  // 6. Update _assignRole
  final assignRoleRegex = RegExp(r'  Future<void> _assignRole\(.*?finally \{\s+if \(mounted\) setState\(\(\) => _isLoading = false\);\s+\}\s+\}', dotAll: true);
  final assignRoleReplacement = '''
  Future<void> _assignRole(
    UserModel selectedMember,
    int roleId,
    String type,
    String roleTitle,
  ) async {
    setState(() => _isLoading = true);
    try {
      final payload = {
        "userId": selectedMember.userId,
        "roleId": roleId,
        "type": type,
        "talukaHeadId": _currentUser?.userId ?? '',
        "talukaId": _talukaId,
      };

      final res = await RoleAPI().assignRole(payload);
      if (res != null && res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("\$roleTitle assigned successfully!")),
          );
        }
        await _loadData();
      } else {
        final msg = res?['message'] ?? 'Failed to assign role';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
''';
  content = content.replaceFirst(assignRoleRegex, assignRoleReplacement);

  // 7. Update _officeBearers list
  final obRegex = RegExp(r'  final List<Map<String, dynamic>> _officeBearers = \[.*?\];', dotAll: true);
  final obReplacement = '''
  final List<Map<String, dynamic>> _officeBearers = [
    {"title": "Assembly President", "roleId": 15, "type": "assembly_president"},
    {"title": "Assembly Vice President", "roleId": 16, "type": "assembly_vice_president"},
  ];
''';
  content = content.replaceFirst(obRegex, obReplacement);

  // 8. Update build function for finding members
  final buildRegex = RegExp(r'  @override\s+Widget build\(BuildContext context\) \{.*?return Scaffold\(', dotAll: true);
  final buildReplacement = '''
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    UserModel? findMemberByRole(String typeSubstring) {
      final leadership = _assemblyLeadership.firstWhere(
        (l) => l['assignment'] != null && l['assignment']['assignmentType'] == typeSubstring,
        orElse: () => null,
      );
      
      if (leadership != null) {
        final holder = leadership['holder'];
        if (holder != null && holder['user'] != null) {
          return UserModel.fromJson({
            'userId': holder['user']['userId'],
            'name': holder['user']['name'],
            'email': holder['user']['email'],
            'mobileNumber': holder['user']['mobileNumber'],
            'roles': [],
            'profile': holder['profile'],
          });
        }
      }
      return null;
    }

    return Scaffold(
''';
  content = content.replaceFirst(buildRegex, buildReplacement);

  // 9. Remove static Chairman and President rows from the UI and Designations
  // Let's replace the whole body of the SingleChildScrollView
  final bodyRegex = RegExp(r'child: Column\(\s+crossAxisAlignment: CrossAxisAlignment.start,\s+children: \[.*\]\s+,\s+\),', dotAll: true);
  final bodyReplacement = '''
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assembly Bearers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Dynamically map through the assignable roles structure
                  ..._officeBearers.map((roleDef) {
                    final assignee = findMemberByRole(roleDef['type']);
                    return _buildRoleRow(
                      context,
                      roleDef['title'],
                      assignee,
                      _isTalukaHead
                          ? (assignee == null ? "Assign" : "Change")
                          : null,
                      badgeColor: Colors.indigo,
                      isUnassigned: assignee == null,
                      onTap: _isTalukaHead
                          ? () => _showAssignRoleSheet(
                              "Office Bearer",
                              roleDef['roleId'],
                              roleDef['type'],
                            )
                          : null,
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
''';
  content = content.replaceFirst(bodyRegex, bodyReplacement);

  file.writeAsStringSync(content);
}
