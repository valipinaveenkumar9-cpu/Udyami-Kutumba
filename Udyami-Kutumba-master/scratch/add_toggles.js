const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

// Add boolean states
const stateRegex = /String\? _selectedWardName;/;
text = text.replace(stateRegex, `String? _selectedWardName;
  
  bool _showDistrictLayer = true;
  bool _showTalukaLayer = true;
  bool _showWardLayer = true;
  bool _showBusinessMarkers = true;
  bool _isFiltersExpanded = true;
`);

// Wrap Area filters in an expandable card and add toggles
const areaFilterRegex = /Widget _buildAreaFilters\(\) \{[\s\S]*?Widget _buildBottomSheet\(\) \{/;
const replacement = `Widget _buildAreaFilters() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_hasPrivilegedRole && _getRoleType() != 'superadmin' && _getRoleType() != 'state') return const SizedBox();

    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_alt, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Map Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(_isFiltersExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
            if (_isFiltersExpanded) ...[
              const Divider(),
              // Dropdowns
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
              const Divider(),
              // Map Layer Toggles
              _buildToggleRow('District Boundary', _showDistrictLayer, (v) => setState(() => _showDistrictLayer = v)),
              _buildToggleRow('Taluka Boundary', _showTalukaLayer, (v) => setState(() => _showTalukaLayer = v)),
              _buildToggleRow('Ward Boundary', _showWardLayer, (v) => setState(() => _showWardLayer = v)),
              _buildToggleRow('Markers (Members/UCN)', _showBusinessMarkers, (v) => setState(() => _showBusinessMarkers = v)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {`;
text = text.replace(areaFilterRegex, replacement);

// Apply the toggles to the map rendering
text = text.replace("if (_districtPolygons.isNotEmpty)", "if (_showDistrictLayer && _districtPolygons.isNotEmpty)");
text = text.replace("if (_talukaPolygons.isNotEmpty)", "if (_showTalukaLayer && _talukaPolygons.isNotEmpty)");
text = text.replace("if (_wardPolygons.isNotEmpty)", "if (_showWardLayer && _wardPolygons.isNotEmpty)");
text = text.replace("if (_businesses.isNotEmpty)", "if (_showBusinessMarkers && _businesses.isNotEmpty)");
text = text.replace("if (_wardCentroid != null)", "if (_showWardLayer && _wardCentroid != null)");

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
