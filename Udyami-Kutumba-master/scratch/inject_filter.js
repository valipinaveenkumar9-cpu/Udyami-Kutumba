const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

const filterMethod = `
  List<Map<String, dynamic>> get _filteredCircles {
    return _rawCirclesList.where((c) {
      final matchesSearch = c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            c['level'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || c['status'].toString().toLowerCase() == _statusFilter.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }
`;

const insertPos = text.indexOf('Widget _buildStatCard');
text = text.substring(0, insertPos) + filterMethod + '\n  ' + text.substring(insertPos);

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');
