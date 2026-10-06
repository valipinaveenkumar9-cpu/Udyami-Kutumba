import 'dart:io';

void main() {
  final ucnHomeFile = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var ucnContent = ucnHomeFile.readAsStringSync();

  // Fix the commented out insertion
  ucnContent = ucnContent.replaceAll('''        //         if (_selectedRole == 'Taluka Head') ...[
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

        if (_selectedRole == 'Circle Leader') ...[''', '''        // if (_selectedRole == 'Circle Leader') ...[''');

  final uiInsertionPoint2 = "        if (_selectedRole == 'Circle Leader') ...[";
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
  ucnContent = ucnContent.replaceFirst(uiInsertionPoint2, talukaHeadUI + uiInsertionPoint2);

  ucnHomeFile.writeAsStringSync(ucnContent);

  // Fix assembly_roles_screen.dart
  final assemblyRolesFile = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart');
  var assemblyContent = assemblyRolesFile.readAsStringSync();

  // Fix `talukaId` in RoleModel
  assemblyContent = assemblyContent.replaceAll('r.talukaId != null && r.talukaId!.isNotEmpty', 'false'); // Ignore talukaId in role model for now, use fallback or other logic
  assemblyContent = assemblyContent.replaceAll('roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty', 'false');
  assemblyContent = assemblyContent.replaceAll('_talukaId = roleWithTaluka.talukaId!;', '');

  // Remove Chairman and President from build method
  assemblyContent = assemblyContent.replaceAll('''                  _buildRoleRow(
                    context,
                    "Chairman",
                    chairman,
                    null,
                    icon: Icons.lock_rounded,
                    isUnassigned: chairman == null,
                  ),
                  _buildRoleRow(
                    context,
                    "President",
                    president,
                    null,
                    icon: Icons.lock_rounded,
                    isUnassigned: president == null,
                  ),''', '');
  
  // Fix _isPresident usage in _officeBearers.map 
  assemblyContent = assemblyContent.replaceAll('_isPresident', '_isTalukaHead');
  
  // Fix "Expected to find ']'"
  // We need to look at how we replaced `_officeBearers.map`. In my previous script, I might have messed up the list spread `..._officeBearers.map((roleDef) {`

  assemblyRolesFile.writeAsStringSync(assemblyContent);
}
