import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('_fetchAssemblyStats')) {
    content = content.replaceFirst(
      "  void _determineRole() {",
      """  Future<void> _fetchAssemblyStats() async {
    if (_talukaId.isEmpty) return;
    setState(() => _isLoadingStats = true);
    try {
      final res = await TalukaAPI().getAllUcnMembersUnderTaluka(_talukaId);
      if (res != null && res['success'] == true && res['data'] != null) {
        if (mounted) {
          setState(() {
            _assemblyStats = res['data'];
            _wards = res['data']['wards'] ?? [];
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _determineRole() {"""
    );
  }
  
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
  }
  
  file.writeAsStringSync(content);
}
