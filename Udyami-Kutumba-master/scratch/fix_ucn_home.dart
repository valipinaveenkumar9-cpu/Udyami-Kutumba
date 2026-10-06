import 'dart:io';

void main() {
  final ucnHomeFile = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = ucnHomeFile.readAsStringSync();

  // Fix _buildPrimeDashboard
  final match = RegExp(r'  Widget _buildPrimeDashboard\(BuildContext context\) \{.*', dotAll: true).firstMatch(content);
  if (match != null) {
    // Keep everything before _buildPrimeDashboard
    final before = content.substring(0, match.start);
    
    final newBuildPrimeDashboard = '''
  Widget _buildPrimeDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedRole == 'Taluka Head') ...[
          const SizedBox(height: 16),
          const Text("Assembly Head", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
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

        if (_selectedRole == 'Circle Leader') ...[
          const SizedBox(height: 16),
          const Text("Circle Leader", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
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
                    MaterialPageRoute(builder: (_) => const CircleConsoleScreen()),
                  );
                },
              ),
            ],
          ),
        ],

        if (_selectedRole == 'Sector Head') ...[
          const SizedBox(height: 16),
          const Text("Sector Head", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
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
                icon: Icons.dashboard_customize_rounded,
                title: "Sector Dashboard",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SectorDashboardScreen()),
                  );
                },
              ),
              DashboardTile(
                icon: Icons.tag_rounded,
                title: "Tag Overlap",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TagOverlapScreen()),
                  );
                },
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),
        const Text("Everyone", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
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
              icon: Icons.send,
              title: "Pass a Lead",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PassLeadScreen()),
                );
              },
            ),
            DashboardTile(
              icon: Icons.list_alt,
              title: "My Leads",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyLeadsScreen()),
                );
              },
            ),
            if (_selectedRole == 'Member')
              DashboardTile(
                icon: Icons.people,
                title: "Face to Face",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FaceToFaceScreen()),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
''';
    ucnHomeFile.writeAsStringSync(before + newBuildPrimeDashboard);
  }
}
