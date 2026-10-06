const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

text = text.replace(/DropdownButton<String>\([\s\S]*?hint: const Text\('Select District'\),[\s\S]*?items: _districtsList.map[\s\S]*?onChanged: \(val\) \{[\s\S]*?_fetchTalukasForDistrict\(val\);[\s\S]*?_fetchLocationAndData\(val, 'district'\);[\s\S]*?\}\s*\},[\s\S]*?\),/, `DropdownButton<String>(
                 isExpanded: true,
                 hint: const Text('Select District'),
                 value: _selectedDistrictId,
                 items: _districtsList.map((e) => DropdownMenuItem<String>(value: e['_id'] ?? e['id'] ?? e['districtName'], child: Text(e['districtName'] ?? ''))).toList(),
                 onChanged: (val) {
                   if (val == null) return;
                   final selectedObj = _districtsList.firstWhere((e) => (e['_id'] ?? e['id'] ?? e['districtName']) == val, orElse: () => {});
                   final name = selectedObj['districtName'] ?? val;
                   setState(() {
                     _selectedDistrictId = val;
                     _selectedDistrictName = name;
                     _selectedTalukaId = null;
                     _selectedTalukaName = null;
                     _selectedWardId = null;
                     _selectedWardName = null;
                     _talukasList = [];
                     _wardsList = [];
                   });
                   _fetchTalukasForDistrict(val);
                   _fetchLocationAndData(name, 'district');
                 },
               ),`);

text = text.replace(/DropdownButton<String>\([\s\S]*?hint: const Text\('Select Taluka'\),[\s\S]*?items: _talukasList.map[\s\S]*?onChanged: \(val\) \{[\s\S]*?_fetchWardsForTaluka\(val\);[\s\S]*?_fetchLocationAndData\(val, 'taluka'\);[\s\S]*?\}\s*\},[\s\S]*?\),/, `DropdownButton<String>(
                 isExpanded: true,
                 hint: const Text('Select Taluka'),
                 value: _selectedTalukaId,
                 items: _talukasList.map((e) => DropdownMenuItem<String>(value: e['_id'] ?? e['id'] ?? e['talukaName'], child: Text(e['talukaName'] ?? ''))).toList(),
                 onChanged: (val) {
                   if (val == null) return;
                   final selectedObj = _talukasList.firstWhere((e) => (e['_id'] ?? e['id'] ?? e['talukaName']) == val, orElse: () => {});
                   final name = selectedObj['talukaName'] ?? val;
                   setState(() {
                     _selectedTalukaId = val;
                     _selectedTalukaName = name;
                     _selectedWardId = null;
                     _selectedWardName = null;
                     _wardsList = [];
                   });
                   _fetchWardsForTaluka(val);
                   _fetchLocationAndData(name, 'taluka');
                 },
               ),`);

text = text.replace(/DropdownButton<String>\([\s\S]*?hint: const Text\('Select Ward'\),[\s\S]*?items: _wardsList.map[\s\S]*?onChanged: \(val\) \{[\s\S]*?_selectedWardName = val;[\s\S]*?_fetchLocationAndData\(val, 'ward'\);[\s\S]*?\}\s*\},[\s\S]*?\),/, `DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Ward'),
              value: _selectedWardId,
              items: _wardsList.map((e) => DropdownMenuItem<String>(value: e['_id'] ?? e['id'] ?? e['wardName'], child: Text(e['wardName'] ?? ''))).toList(),
              onChanged: (val) {
                if (val == null) return;
                final selectedObj = _wardsList.firstWhere((e) => (e['_id'] ?? e['id'] ?? e['wardName']) == val, orElse: () => {});
                final name = selectedObj['wardName'] ?? val;
                setState(() {
                  _selectedWardId = val;
                  _selectedWardName = name;
                });
                _fetchLocationAndData(name, 'ward');
              },
            ),`);

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
