const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const replacementMethod = `
  Future<void> _fetchTalukasForDistrict(String districtId) async {
    print("DEV DEBUG - Map: _fetchTalukasForDistrict called with ID: " + districtId);
    try {
      final res = await _dashboardAPI.fetchTalukasByDistrict(districtId);
      if (res != null && res['success'] == true) {
        setState(() => _talukasList = res['data'] ?? []);
      }
    } catch (_) {}
  }

  Future<void> _fetchWardsForTaluka(String talukaId) async {
    print("DEV DEBUG - Map: _fetchWardsForTaluka called with ID: " + talukaId);
    try {
      final res = await _dashboardAPI.fetchWardsByTaluka(talukaId);
      if (res != null && res['success'] == true) {
        setState(() {
          _wardsList = res['data'] ?? [];
          print("DEV DEBUG - Map: Wards fetched: " + _wardsList.length.toString());
        });
      }
    } catch (_) {}
  }
`;

text = text.replace(/Future<void> _fetchTalukasForDistrict[\s\S]*?catch \(\_\) \{\}\s*\}/, replacementMethod.trim());
text = text.replace(/Future<void> _fetchWardsForTaluka[\s\S]*?catch \(\_\) \{\}\s*\}/, '');

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
