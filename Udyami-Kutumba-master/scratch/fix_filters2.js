const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const regex = /Widget _buildAreaFilters\(\) \{[\s\S]*?Widget _buildBottomSheet\(\) \{/;

const replacement = `Widget _buildAreaFilters() {
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
               ),
            if (_getRoleType() == 'superadmin' || _getRoleType() == 'state' || _getRoleType() == 'district')
               DropdownButton<String>(
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
               ),
            DropdownButton<String>(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
