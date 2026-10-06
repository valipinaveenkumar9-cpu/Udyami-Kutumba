const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const regex = /Widget _buildSearchBar\(\) \{[\s\S]*?Widget _buildBottomSheet\(\)/;

const replacement = `
  Widget _buildFilters() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ucn', 'UCN / Businesses', Icons.business),
                const SizedBox(width: 8),
                _buildFilterChip('members', 'Members', Icons.people),
                const SizedBox(width: 8),
                _buildFilterChip('heads', 'Heads', Icons.account_balance),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Dropdowns
          if (_hasPrivilegedRole)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (_getRoleType() == 'superadmin' || _getRoleType() == 'state')
                     _buildDropdown('District', _districtsList, _selectedDistrictId, (val) {
                       setState(() {
                         _selectedDistrictId = val;
                         _selectedDistrictName = _districtsList.firstWhere((e) => e['_id'] == val, orElse: () => {})['districtName'];
                         _selectedTalukaId = null;
                         _selectedWardId = null;
                       });
                       _fetchTalukas(val);
                       _fetchMapDataForSelection();
                     }),
                  if (_getRoleType() == 'superadmin' || _getRoleType() == 'state' || _getRoleType() == 'district')
                     _buildDropdown('Taluka', _talukasList, _selectedTalukaId, (val) {
                       setState(() {
                         _selectedTalukaId = val;
                         _selectedTalukaName = _talukasList.firstWhere((e) => e['_id'] == val, orElse: () => {})['talukaName'];
                         _selectedWardId = null;
                       });
                       _fetchWards(val);
                       _fetchMapDataForSelection();
                     }),
                  _buildDropdown('Ward', _wardsList, _selectedWardId, (val) {
                       setState(() {
                         _selectedWardId = val;
                         _selectedWardName = _wardsList.firstWhere((e) => e['_id'] == val, orElse: () => {})['wardName'];
                       });
                       _fetchMapDataForSelection();
                     }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label, IconData icon) {
    final isSelected = _filterType == type;
    return ChoiceChip(
      label: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: type == 'ucn' ? Colors.blue : (type == 'members' ? Colors.purple : Colors.orange),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade800),
      onSelected: (val) {
        if (val) {
          setState(() => _filterType = type);
          _fetchMapDataForSelection();
        }
      },
    );
  }

  Widget _buildDropdown(String hint, List<dynamic> items, String? value, Function(String) onChanged) {
    if (items.isEmpty) return const SizedBox();
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text('Select $hint'),
      value: value,
      items: items.map((e) {
        final id = e['_id']?.toString() ?? e['id']?.toString();
        final name = e['districtName'] ?? e['talukaName'] ?? e['wardName'] ?? e['name'] ?? 'Unknown';
        return DropdownMenuItem<String>(
          value: id,
          child: Text(name),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Future<void> _fetchMapDataForSelection() async {
    String queryName = '';
    String queryType = 'ward';

    if (_selectedWardName != null) {
      queryName = _selectedWardName!;
      queryType = 'ward';
    } else if (_selectedTalukaName != null) {
      queryName = _selectedTalukaName!;
      queryType = 'taluka';
    } else if (_selectedDistrictName != null) {
      queryName = _selectedDistrictName!;
      queryType = 'district';
    } else if (_assignedAreaName != null) {
      queryName = _assignedAreaName!;
      final r = _getRoleType();
      queryType = (r == 'superadmin' || r == 'state') ? 'district' : r.replaceAll('head', '');
    }

    if (queryName.isNotEmpty) {
      setState(() => _isSearching = true);
      await _fetchLocationAndData(queryName, queryType);
    }
  }

  Future<void> _fetchTalukas(String districtId) async {
    try {
      final res = await _dashboardAPI.fetchTalukasByDistrict(districtId);
      if (res != null && res['success'] == true) {
        setState(() => _talukasList = res['data'] ?? []);
      }
    } catch (_) {}
  }

  Future<void> _fetchWards(String talukaId) async {
    try {
      final res = await _dashboardAPI.fetchWardsByTaluka(talukaId);
      if (res != null && res['success'] == true) {
        setState(() => _wardsList = res['data'] ?? []);
      }
    } catch (_) {}
  }

  Widget _buildBottomSheet()`;

text = text.replace(regex, replacement);

// Replace _buildSearchBar() in the build method with _buildFilters()
text = text.replace('_buildSearchBar(),', '_buildFilters(),');

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
