import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();

  final regex = RegExp(r'      bool isCircleLeader = .*?setState\(\(\) \{.*?if \(isCircleLeader\) \{.*?\} else \{.*?_selectedRole = .Member.;.*?\}\s*\}\);', dotAll: true);
  
  final newRoleCheck = '''
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
      
      setState(() {
        _isPrime = userModel.isPrime == true;
        
        if (isTalukaHead) {
          _selectedRole = 'Taluka Head';
        } else if (isCircleLeader) {
          _selectedRole = 'Circle Leader';
        } else if (isSectorHead) {
          _selectedRole = 'Sector Head';
        } else {
          _selectedRole = 'Member';
        }
      });
''';

  content = content.replaceFirst(regex, newRoleCheck);
  file.writeAsStringSync(content);
}
