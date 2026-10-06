import re

with open('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Make it AssemblyRolesScreen specific
content = content.replace("bool _isPresident = false;", "bool _isTalukaHead = false;\n  String _talukaId = '';\n  List<dynamic> _assemblyLeadership = [];")

# We want to replace the `_loadData`
load_data_replacement = """
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
      if (_currentUser != null) {
        // Try to find talukaId from roles or profile
        final roleWithTaluka = _currentUser!.roles.firstWhere(
          (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
          orElse: () => RoleModel(roleId: 0, roleName: ''),
        );
        if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
          _talukaId = roleWithTaluka.talukaId!;
        } else {
          // fallback
          _talukaId = "f9a6257c-7cbe-4c1c-a25a-8403ee801110";
        }
      }

      if (_talukaId.isEmpty) {
        _talukaId = "f9a6257c-7cbe-4c1c-a25a-8403ee801110"; // Fallback
      }

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
        print('DEV DEBUG - AssemblyRolesScreen: Failed to fetch assembly leadership: $e');
      }

    } catch (e) {
      print("DEV DEBUG - Error in _loadData: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }
"""

content = re.sub(r'  Future<void> _loadData\(\) async \{.*?(?=  void _showAssignRoleSheet)', load_data_replacement, content, flags=re.DOTALL)

# Modify assignRole
assign_role_replacement = """
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
            SnackBar(content: Text("$roleTitle assigned successfully!")),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
"""
content = re.sub(r'  Future<void> _assignRole\(.*?finally \{\s+if \(mounted\) setState\(\(\) => _isLoading = false\);\s+\}\s+\}', assign_role_replacement, content, flags=re.DOTALL)

# Modify OfficeBearers
ob_replacement = """
  final List<Map<String, dynamic>> _officeBearers = [
    {"title": "Assembly President", "roleId": 15, "type": "assembly_president"},
    {"title": "Assembly Vice President", "roleId": 16, "type": "assembly_vice_president"},
  ];
"""
content = re.sub(r'  final List<Map<String, dynamic>> _officeBearers = \[.*?\];', ob_replacement, content, flags=re.DOTALL)

# Modify build
build_top_replacement = """
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    UserModel? findMemberByRole(String typeSubstring) {
      final leadership = _assemblyLeadership.firstWhere(
        (l) => l['assignment']?['assignmentType'] == typeSubstring,
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
          });
        }
      }
      return null;
    }

    final assemblyPresident = findMemberByRole('assembly_president');
    final assemblyVicePresident = findMemberByRole('assembly_vice_president');

    return Scaffold(
"""

content = re.sub(r'  @override\s+Widget build\(BuildContext context\) \{.*?return Scaffold\(', build_top_replacement, content, flags=re.DOTALL)

# In the build method body, remove the designations part
content = re.sub(r'const Text\(\s*"Designations".*?(?=Center\()', '', content, flags=re.DOTALL)

# Update the header in the UI to reflect Assembly Roles
content = content.replace('_buildRoleRow(\n                    context,\n                    "Chairman",\n                    chairman,\n                    null,\n                    icon: Icons.lock_rounded,\n                    isUnassigned: chairman == null,\n                  ),\n                  _buildRoleRow(\n                    context,\n                    "President",\n                    president,\n                    null,\n                    icon: Icons.lock_rounded,\n                    isUnassigned: president == null,\n                  ),', '')
content = content.replace('_isPresident\n                          ? (assignee == null ? "Assign" : "Change")\n                          : null,', '_isTalukaHead ? (assignee == null ? "Assign" : "Change") : null,')
content = content.replace('onTap: _isPresident', 'onTap: _isTalukaHead')
content = content.replace('G5 Malleshwaram circle', 'Assembly level')
content = content.replace('G5 Malleshwaram org chart', 'Assembly Org Chart')

with open('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
