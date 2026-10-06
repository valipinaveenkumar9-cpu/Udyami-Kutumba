import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('taluka_api.dart')) {
    content = content.replaceFirst(
      "import '../../../core/models/user_model.dart';",
      "import '../../../core/models/user_model.dart';\nimport '../../../core/api/taluka_api.dart';"
    );
  }
  
  if (!content.contains('String _talukaId = ')) {
    content = content.replaceFirst(
      "bool _isPrime = false;",
      "bool _isPrime = false;\n  String _talukaId = '';\n  Map<String, dynamic>? _assemblyStats;\n  List<dynamic> _wards = [];\n  bool _isLoadingStats = false;"
    );
  }
  
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
  
  if (!content.contains('roleWithTaluka')) {
    content = content.replaceFirst(
      "      setState(() {",
      """      final roleWithTaluka = userModel.roles.firstWhere(
        (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
        _talukaId = roleWithTaluka.talukaId!;
        _fetchAssemblyStats();
      }

      setState(() {"""
    );
  }
  
  file.writeAsStringSync(content);
}
