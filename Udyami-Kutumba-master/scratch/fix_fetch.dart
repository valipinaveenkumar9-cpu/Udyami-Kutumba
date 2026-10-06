import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();
  
  // Regex to replace _fetchAssemblyStats
  content = content.replaceFirst(RegExp(r'  Future<void> _fetchAssemblyStats\(\) async \{.*?\n  \}\n\n  void _determineRole', dotAll: true),
'''
  Future<void> _fetchAssemblyStats() async {
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

  void _determineRole'''
  );

  file.writeAsStringSync(content);
}
