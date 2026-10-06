import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add import for assembly_roles_screen
  if (!content.contains("import '../ucnsubscreens/assembly_roles_screen.dart';")) {
    content = content.replaceFirst(
      "import '../ucnsubscreens/circle_console_screen.dart';",
      "import '../ucnsubscreens/circle_console_screen.dart';\nimport '../ucnsubscreens/assembly_roles_screen.dart';"
    );
  }

  // 2. Add isTalukaHead logic
  final determineRoleRegex = RegExp(r'bool isCircleLeader = .*?setState', dotAll: true);
  final newDetermineRole = '''
      bool isTalukaHead = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('assembly_head') || rName.contains('taluka_head') || rName.contains('assembly head') || rName.contains('taluk head');
      }) || userModel.name.toLowerCase().contains('assembly head') || userModel.name.toLowerCase().contains('taluk head');

      bool isCircleLeader = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return (rName.contains('circle_leader') || rName.contains('president') || rName.contains('chairman') || rName.contains('head')) && !(rName.contains('assembly') || rName.contains('taluka'));
      }) || userModel.name.toLowerCase().contains('circle leader') || (userModel.name.toLowerCase().contains('president') && !userModel.name.toLowerCase().contains('assembly'));
      
      bool isSectorHead = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('sector_head') || rName.contains('sector head');
      }) || userModel.name.toLowerCase().contains('sector head');
      
      setState''';
  content = content.replaceFirst(determineRoleRegex, newDetermineRole);

  // 3. Update setState logic
  final setStateRegex = RegExp(r'if \(isCircleLeader\) \{\s*_selectedRole = .Circle Leader.;\s*\} else if \(isSectorHead\) \{\s*_selectedRole = .Sector Head.;\s*\} else \{\s*_selectedRole = .Member.;\s*\}', dotAll: true);
  final newSetState = '''
        if (isTalukaHead) {
          _selectedRole = 'Taluka Head';
        } else if (isCircleLeader) {
          _selectedRole = 'Circle Leader';
        } else if (isSectorHead) {
          _selectedRole = 'Sector Head';
        } else {
          _selectedRole = 'Member';
        }
''';
  content = content.replaceFirst(setStateRegex, newSetState);

  // 4. Add UI for Taluka Head
  final uiInsertionPoint = "if (_selectedRole == 'Circle Leader') ...[";
  final talukaHeadUI = '''
        if (_selectedRole == 'Taluka Head') ...[
          const SizedBox(height: 16),
          const Text("Taluka Head", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              DashboardTile(
                icon: Icons.admin_panel_settings_rounded,
                title: "Assembly Roles",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssemblyRolesScreen()),
                  );
                },
              ),
            ],
          ),
        ],

        ''';
  content = content.replaceFirst(uiInsertionPoint, talukaHeadUI + uiInsertionPoint);

  file.writeAsStringSync(content);
}
