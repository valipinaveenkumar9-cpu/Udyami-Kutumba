const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

text = text.replace(/Future<void> _fetchWardsForTaluka\(String talukaName\) async \{/g, `Future<void> _fetchWardsForTaluka(String talukaName) async {
    print("DEV DEBUG - Map: _fetchWardsForTaluka called with: " + talukaName);`);

text = text.replace(/Future<void> _fetchTalukasForDistrict\(String districtName\) async \{/g, `Future<void> _fetchTalukasForDistrict(String districtName) async {
    print("DEV DEBUG - Map: _fetchTalukasForDistrict called with: " + districtName);`);

text = text.replace(/Future<void> _fetchDistricts\(\) async \{/g, `Future<void> _fetchDistricts() async {
    print("DEV DEBUG - Map: _fetchDistricts called");`);

text = text.replace(/onChanged: \(val\) \{/g, `onChanged: (val) {
                   print("DEV DEBUG - Map: Dropdown changed to: " + String(val));`);

text = text.replace(/setState\(\(\) => _wardsList = res\['data'\] \?\? \[\]\);/g, `setState(() {
          _wardsList = res['data'] ?? [];
          print("DEV DEBUG - Map: Wards fetched: " + _wardsList.length.toString());
        });`);

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
