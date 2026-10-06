import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();

  // Add to Assembly Roles grid
  final pattern1 = r'''DashboardTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: "Assembly Roles",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssemblyRolesScreen(),
                      ),
                    );
                  },
                ),''';
  final replace1 = pattern1 + '\n                ..._buildStatsTiles(),';
  content = content.replaceFirst(pattern1, replace1);

  // Add to Assembly Leader grid
  final pattern2 = r'''DashboardTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: "Console",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssemblyConsoleScreen(),
                      ),
                    );
                  },
                ),''';
  final replace2 = pattern2 + '\n                ..._buildStatsTiles(),';
  content = content.replaceFirst(pattern2, replace2);

  file.writeAsStringSync(content);
}
