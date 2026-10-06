import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_console_screen.dart');
  var content = file.readAsStringSync();

  // 1. Rename class and state
  content = content.replaceAll('CircleConsoleScreen', 'AssemblyConsoleScreen');
  content = content.replaceAll('_CircleConsoleScreenState', '_AssemblyConsoleScreenState');
  
  // 2. Update AppBar title
  content = content.replaceAll('Circle Console', 'Assembly Console');
  
  // 3. Update 'Circle roles' to 'Assembly roles' tile? No, wait. 
  // What roles does Assembly President assign? "Coordinators"?
  // The user says "like Area have ward charmain, but its also have the Area of Circle President/Leader role need that here same"
  // So AssemblyConsoleScreen should probably have "Coordinators" and maybe "Assembly roles"? But Assembly President doesn't assign Assembly President, they assign Coordinators?
  // Let's just keep the tiles same as Circle Console for now, maybe remove "Circle roles". Or redirect "Circle roles" to "Assembly Roles"? But Assembly Roles assigns President, which is Taluka Head's job.
  // Actually, we can remove the "Circle roles" tile or rename it to "Assembly Coordinators"? 
  // Let's just remove "Circle roles" for the Assembly Leader, since Taluka Head assigns their role. Or leave it as Assembly Roles and they can see it but not assign.
  // Let's comment out the "Circle roles" tile for now.
  
  final circleRolesTileRegex = RegExp(r'                _buildLaunchTile\(Icons\.account_tree_rounded,\s*"Circle roles",\s*\(\)\s*\{.*?(?=\s*_buildLaunchTile)', dotAll: true);
  content = content.replaceFirst(circleRolesTileRegex, '');

  file.writeAsStringSync(content);
}
