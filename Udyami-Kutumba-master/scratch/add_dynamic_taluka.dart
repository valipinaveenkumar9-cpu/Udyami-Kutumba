import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/ucnsubscreens/assembly_roles_screen.dart');
  var content = file.readAsStringSync();

  // Add import for location_api
  if (!content.contains("import '../../../core/api/location_api.dart';")) {
    content = content.replaceFirst(
      "import '../../../core/api/taluka_api.dart';",
      "import '../../../core/api/taluka_api.dart';\nimport '../../../core/api/location_api.dart';"
    );
  }

  // Update variables
  final varsSearch = "  bool _isTalukaHead = false;\n  String _talukaId = '';\n  List<dynamic> _assemblyLeadership = [];";
  final newVars = '''
  bool _isTalukaHead = false;
  String _talukaId = '';
  List<dynamic> _assemblyLeadership = [];
  
  // Dynamic API state
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedTalukaId;
  String? _selectedTalukaName;
''';
  content = content.replaceFirst(varsSearch, newVars);

  // Update _loadData
  final loadDataRegex = RegExp(r'  Future<void> _loadData\(\) async \{.*?if \(mounted\) setState\(\(\) => _isLoading = false\);\s+\}', dotAll: true);
  final newLoadData = '''
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userData = SessionManager.user;
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
      _isTalukaHead = _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('assembly_head') || rName.contains('taluka_head') || rName.contains('assembly head') || rName.contains('taluk head') || rName.contains('assembly_president') || rName.contains('assembly president');
      });
    }

    try {
      final res = await AuthAPI().getAllUsers();
      if (res != null) {
        List data = [];
        if (res is Map && res['success'] == true && res.containsKey('data')) {
          data = res['data'] ?? [];
        } else if (res is Map && res.containsKey('membershipUsers')) {
          data = res['membershipUsers'] ?? [];
        } else if (res is List) {
          data = res;
        }
        _members = data.map((e) => UserModel.fromJson(e)).toList();
      }

      // Fetch all districts dynamically
      final distRes = await LocationAPI().getAllDistricts();
      if (distRes != null && distRes['success'] == true) {
        final List rawDistricts = distRes['data'] ?? [];
        _districts = rawDistricts.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // Ignored
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTalukas(String districtId) async {
    setState(() => _isLoading = true);
    try {
      final talukaRes = await LocationAPI().getAllDistricts(districtId: districtId);
      if (talukaRes != null && talukaRes['success'] == true) {
        final List rawTalukas = talukaRes['data'] ?? [];
        _talukas = rawTalukas.cast<Map<String, dynamic>>();
        _selectedTalukaId = null;
        _selectedTalukaName = null;
        _talukaId = '';
        _assemblyLeadership = [];
      }
    } catch (e) {
      // Ignored
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadLeadership(String talukaId) async {
    setState(() => _isLoading = true);
    try {
      final leadershipRes = await TalukaAPI().getAssemblyLeadership(talukaId);
      if (leadershipRes != null && leadershipRes['success'] == true) {
        _assemblyLeadership = leadershipRes['data'] ?? [];
      } else {
        _assemblyLeadership = [];
      }
    } catch (e) {
      _assemblyLeadership = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }
''';
  content = content.replaceFirst(loadDataRegex, newLoadData);

  // Update _assignRole to reload after assign
  content = content.replaceAll('await _loadData();', 'await _loadLeadership(_talukaId);');

  // Update build function
  final buildStartRegex = RegExp(r'              child: Column\(\s+crossAxisAlignment: CrossAxisAlignment.start,\s+children: \[', dotAll: true);
  final newBuildUI = '''              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // District Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Select District"),
                        value: _selectedDistrictId,
                        items: _districts.map((d) {
                          return DropdownMenuItem<String>(
                            value: d['districtId']?.toString(),
                            child: Text(d['districtName']?.toString() ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDistrictId = val;
                              _selectedDistrictName = _districts.firstWhere((d) => d['districtId']?.toString() == val)['districtName'];
                            });
                            _loadTalukas(val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Taluka Dropdown
                  if (_talukas.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("Select Assembly / Taluka"),
                          value: _selectedTalukaId,
                          items: _talukas.map((t) {
                            return DropdownMenuItem<String>(
                              value: t['talukaId']?.toString(),
                              child: Text(t['talukaName']?.toString() ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTalukaId = val;
                                _talukaId = val;
                                _selectedTalukaName = _talukas.firstWhere((t) => t['talukaId']?.toString() == val)['talukaName'];
                              });
                              _loadLeadership(val);
                            }
                          },
                        ),
                      ),
                    ),
                  
                  if (_talukas.isEmpty && _selectedDistrictId != null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("No assemblies found for this district.", style: TextStyle(color: Colors.redAccent)),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  if (_talukaId.isNotEmpty) ...[
''';
  content = content.replaceFirst(buildStartRegex, newBuildUI);

  // Close the if statement block
  final closeRegex = RegExp(r'                  Center\(\s+child: Text\(\s+"Networking posts from the Assembly Org Chart",\s+style: TextStyle\(\s+color: Colors.grey.shade500,\s+fontSize: 12,\s+\),\s+textAlign: TextAlign.center,\s+\),\s+\),\s+const SizedBox\(height: 32\),\s+\]\,\s+\),\s+\),\s+\);');
  final newClose = '''
                  Center(
                    child: Text(
                      "Networking posts from the \${_selectedTalukaName ?? 'Assembly'} Org Chart",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ], // End of if (_talukaId.isNotEmpty)
                ],
              ),
            ),
    );
''';
  content = content.replaceFirst(closeRegex, newClose);

  file.writeAsStringSync(content);
}
