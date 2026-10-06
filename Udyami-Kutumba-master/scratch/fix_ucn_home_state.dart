import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Remove the injected block from _fetchAssemblyStats
  content = content.replaceAll('''
          final roleWithTaluka = userModel.roles.firstWhere(
            (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
            orElse: () => RoleModel(roleId: 0, roleName: ''),
          );
          if (roleWithTaluka.talukaId != null &&
              roleWithTaluka.talukaId!.isNotEmpty) {
            _talukaId = roleWithTaluka.talukaId!;
            _fetchAssemblyStats();
          }

          setState(() {''', '''
          setState(() {''');

  // 2. Put it in _determineRole before setState(() { _isPrime = userModel.isPrime == true; ... })
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

  // 3. Let's fix the missing _buildAssemblyOverview call in build()
  // Wait, my replacement for if (_selectedRole == 'Circle Leader') might have failed.
  // Let's replace the Circle Leader block safely.
  if (!content.contains('_buildAssemblyOverview(),')) {
    content = content.replaceFirst(
      '''
        if (_selectedRole == 'Circle Leader') ...[''',
      '''
        if (_selectedRole == 'Assembly Leader' || _selectedRole == 'Taluka Head') _buildAssemblyOverview(),

        if (_selectedRole == 'Circle Leader') ...['''
    );
  }
  
  file.writeAsStringSync(content);
}
