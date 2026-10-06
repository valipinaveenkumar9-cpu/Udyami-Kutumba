const fs = require('fs');
let text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');

text = text.replace(/GeofenceScreen/g, 'MemberMapScreen');
text = text.replace(/_GeofenceScreenState/g, '_MemberMapScreenState');
text = text.replace("import '../../../core/api/ward_api.dart';", "import '../../../core/api/ward_api.dart';\nimport '../../../core/api/dashboard_api.dart';");

// Add state variables
text = text.replace('bool _isSheetVisible = true;', `bool _isSheetVisible = true;

  final DashboardAPI _dashboardAPI = DashboardAPI();
  List<dynamic> _districtsList = [];
  List<dynamic> _talukasList = [];
  List<dynamic> _wardsList = [];
  String? _selectedDistrictId;
  String? _selectedTalukaId;
  String? _selectedWardId;
  String? _selectedDistrictName;
  String? _selectedTalukaName;
  String? _selectedWardName;
`);

// Modify _checkProfileAndInit to fetch initial dropdowns
const initRegex = /String\? areaName;/;
text = text.replace(initRegex, `String? areaName;
          if (roleType == 'superadmin' || roleType == 'state') {
             _fetchDistricts();
          }`);

const initRegex2 = /if \(roleType == 'district' && profile\['district'\] != null\) \{/;
text = text.replace(initRegex2, `if (roleType == 'district' && profile['district'] != null) {
              _fetchTalukasForDistrict(profile['district']);
`);

// Add Dropdown UI and fetch methods
const bottomSheetRegex = /Widget _buildBottomSheet\(\) \{/;
text = text.replace(bottomSheetRegex, `
  Future<void> _fetchDistricts() async {
    try {
      final res = await _dashboardAPI.fetchAllDistricts();
      if (res != null && res['success'] == true) setState(() => _districtsList = res['data'] ?? []);
    } catch (_) {}
  }
  Future<void> _fetchTalukasForDistrict(String districtName) async {
    try {
      final res = await _dashboardAPI.fetchTalukasByDistrict(districtName); // might need districtId
      if (res != null && res['success'] == true) setState(() => _talukasList = res['data'] ?? []);
    } catch (_) {}
  }
  Future<void> _fetchWardsForTaluka(String talukaName) async {
    try {
      final res = await _dashboardAPI.fetchWardsByTaluka(talukaName); // might need talukaId
      if (res != null && res['success'] == true) setState(() => _wardsList = res['data'] ?? []);
    } catch (_) {}
  }

  Widget _buildAreaFilters() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (!_hasPrivilegedRole && _getRoleType() != 'superadmin' && _getRoleType() != 'state') return const SizedBox();

    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            if (_getRoleType() == 'superadmin' || _getRoleType() == 'state')
               DropdownButton<String>(
                 isExpanded: true,
                 hint: const Text('Select District'),
                 value: _selectedDistrictName,
                 items: _districtsList.map((e) => DropdownMenuItem<String>(value: e['districtName'], child: Text(e['districtName']))).toList(),
                 onChanged: (val) {
                   setState(() {
                     _selectedDistrictName = val;
                     _selectedTalukaName = null;
                     _selectedWardName = null;
                     _talukasList = [];
                     _wardsList = [];
                   });
                   if (val != null) {
                     _fetchTalukasForDistrict(val);
                     _fetchLocationAndData(val, 'district');
                   }
                 },
               ),
            if (_getRoleType() == 'superadmin' || _getRoleType() == 'state' || _getRoleType() == 'district')
               DropdownButton<String>(
                 isExpanded: true,
                 hint: const Text('Select Taluka'),
                 value: _selectedTalukaName,
                 items: _talukasList.map((e) => DropdownMenuItem<String>(value: e['talukaName'], child: Text(e['talukaName']))).toList(),
                 onChanged: (val) {
                   setState(() {
                     _selectedTalukaName = val;
                     _selectedWardName = null;
                     _wardsList = [];
                   });
                   if (val != null) {
                     _fetchWardsForTaluka(val);
                     _fetchLocationAndData(val, 'taluka');
                   }
                 },
               ),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Ward'),
              value: _selectedWardName,
              items: _wardsList.map((e) => DropdownMenuItem<String>(value: e['wardName'], child: Text(e['wardName']))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedWardName = val;
                });
                if (val != null) {
                  _fetchLocationAndData(val, 'ward');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
`);

// Add _buildAreaFilters() to the Stack
text = text.replace('_buildSearchBar(),', '_buildSearchBar(),\n          _buildAreaFilters(),');

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
