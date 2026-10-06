const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const newMethod = `
  Future<void> _fetchLocationAndData(String query, String queryType) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _districtPolygons.clear();
      _talukaPolygons.clear();
      _wardPolygons.clear();
      _businesses.clear();
      _wardProperties = null;
      _wardCentroid = null;
      _selectedBusiness = null;
      _isSheetVisible = false;
    });

    try {
      final response = await _wardAPI.getWardMap(query, type: queryType);
      if (mounted) {
        if (response != null && response['success'] == true && response['data'] != null && response['data']['type'] == 'FeatureCollection') {
          _parseGeoJson(response['data']);
        } else {
          setState(() {
            _searchError = 'No data found for the selected area.';
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _searchError = 'Error fetching data.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }
`;

// Insert before _loadAssignedMap
text = text.replace('Future<void> _loadAssignedMap() async {', newMethod + '\n  Future<void> _loadAssignedMap() async {');
fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
