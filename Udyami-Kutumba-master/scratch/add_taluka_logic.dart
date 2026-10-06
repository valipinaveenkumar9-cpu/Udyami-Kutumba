import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('_talukaId = roleWithTaluka.talukaId!;')) {
    content = content.replaceFirst(
      '''
      setState(() {
        _isPrime = userModel.isPrime == true;''',
      '''
      if (isTalukaHead || isAssemblyLeader) {
        final roleWithTaluka = userModel.roles.firstWhere(
          (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
          orElse: () => RoleModel(roleId: 0, roleName: ''),
        );
        if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
          _talukaId = roleWithTaluka.talukaId!;
          _fetchAssemblyStats();
        }
      }

      setState(() {
        _isPrime = userModel.isPrime == true;'''
    );
    file.writeAsStringSync(content);
  }
}
