import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add import for assembly_console_screen.dart
  if (!content.contains("import '../ucnsubscreens/assembly_console_screen.dart';")) {
    content = content.replaceFirst(
      "import '../ucnsubscreens/assembly_roles_screen.dart';",
      "import '../ucnsubscreens/assembly_roles_screen.dart';\nimport '../ucnsubscreens/assembly_console_screen.dart';"
    );
  }

  // 2. Fix _determineRole logic
  final oldRoleRegex = RegExp(r'      bool isTalukaHead = .*?setState\(\(\) \{.*?if \(isTalukaHead\) \{.*?\} else \{.*?_selectedRole = .Member.;.*?\}\s*\}\);', dotAll: true);
  final newRoleLogic = '''
      bool isTalukaHead = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('assembly_head') || rName.contains('taluka_head') || rName.contains('assembly head') || rName.contains('taluk head');
      }) || userModel.name.toLowerCase().contains('assembly head') || userModel.name.toLowerCase().contains('taluk head');

      bool isAssemblyLeader = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('assembly_president') || rName.contains('taluka_president') || rName.contains('assembly_vice_president');
      }) || userModel.name.toLowerCase().contains('assembly president') || userModel.name.toLowerCase().contains('assembly vice president');

      bool isCircleLeader = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return (rName.contains('circle_leader') || rName.contains('president') || rName.contains('chairman') || rName.contains('head')) && !(rName.contains('assembly') || rName.contains('taluka'));
      }) || userModel.name.toLowerCase().contains('circle leader') || (userModel.name.toLowerCase().contains('president') && !userModel.name.toLowerCase().contains('assembly'));
      
      bool isSectorHead = userModel.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('sector_head') || rName.contains('sector head');
      }) || userModel.name.toLowerCase().contains('sector head');
      
      setState(() {
        _isPrime = userModel.isPrime == true;
        
        if (isTalukaHead) {
          _selectedRole = 'Taluka Head';
        } else if (isAssemblyLeader) {
          _selectedRole = 'Assembly Leader';
        } else if (isCircleLeader) {
          _selectedRole = 'Circle Leader';
        } else if (isSectorHead) {
          _selectedRole = 'Sector Head';
        } else {
          _selectedRole = 'Member';
        }
      });
''';

  content = content.replaceFirst(oldRoleRegex, newRoleLogic);

  // 3. Add Assembly Leader UI block
  final uiInsertionPoint = "\n        if (_selectedRole == 'Circle Leader') ...[";
  final assemblyLeaderUI = '''

        if (_selectedRole == 'Assembly Leader') ...[
          const SizedBox(height: 16),
          const Text("Assembly Leader", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
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
                title: "Console",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssemblyConsoleScreen()),
                  );
                },
              ),
            ],
          ),
        ],
''';

  content = content.replaceFirst(uiInsertionPoint, assemblyLeaderUI + uiInsertionPoint);
  
  file.writeAsStringSync(content);
}
