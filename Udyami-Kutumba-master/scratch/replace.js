const fs = require('fs');

let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const replacement = `
  String _getRoleDisplayName() {
    switch (_highestRole) {
      case 'super_admin': return 'Global Headquarters';
      case 'state_head': return 'State Head Dashboard';
      case 'district_head': return 'District Leadership';
      case 'taluka_head': return 'Taluka Leadership';
      case 'ward_chairman': return 'Ward Operations';
      default: return 'Dashboard';
    }
  }

  String _getRoleDescription() {
    switch (_highestRole) {
      case 'super_admin': return 'Platform-wide oversight, performance & analytics';
      case 'state_head': return 'State-wide operations, hierarchy & directory';
      case 'district_head': return 'District-wide operations, Taluka management & leadership';
      case 'taluka_head': return 'Taluka-wide operations, Ward management & leadership directory';
      case 'ward_chairman': return 'Ward operations, member analytics & live field updates';
      default: return 'Overview & Analytics';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    
    if (_highestRole == 'super_admin' || _highestRole.contains('state')) {
      cards.add(_buildStatCard('Total Platform Members', '\\$_primeCount Prime · \\$_basicCount Basic · \\$_freeCount Free', _totalUsers, Icons.people, Colors.blue, Colors.blue.shade50, Colors.blue.shade700));
      cards.add(_buildStatCard('Registered Districts', 'Total districts', _allDistrictsCount, Icons.public, Colors.green, Colors.green.shade50, Colors.green.shade700));
      cards.add(_buildStatCard('Total Appointed Heads', 'Leadership directory', _allHeadsCount, Icons.shield, Colors.purple, Colors.purple.shade50, Colors.purple.shade700));
      cards.add(_buildStatCard('Channel Partners', 'Active CPs', _channelPartners, Icons.business_center, Colors.teal, Colors.teal.shade50, Colors.teal.shade700));
    } else if (_highestRole.contains('district')) {
      cards.add(_buildStatCard('Total District Members', '\\$_primeCount Prime · \\$_basicCount Basic · \\$_freeCount Free', _totalUsers, Icons.people, Colors.blue, Colors.blue.shade50, Colors.blue.shade700));
      cards.add(_buildStatCard('Active Talukas', '\\$_activeTalukas / \\$_activeTalukas Active', _activeTalukas, Icons.flag, Colors.green, Colors.green.shade50, Colors.green.shade700));
      cards.add(_buildStatCard('Appointed Chairmen', '\\$_appointedChairmen active chairmen', _appointedChairmen, Icons.shield, Colors.purple, Colors.purple.shade50, Colors.purple.shade700));
      cards.add(_buildStatCard('Channel Partners', '\\$_channelPartners active CPs across wards', _channelPartners, Icons.business_center, Colors.teal, Colors.teal.shade50, Colors.teal.shade700));
    } else if (_highestRole == 'taluka_head') {
      cards.add(_buildStatCard('Total Taluka Members', '\\$_primeCount Prime · \\$_basicCount Basic · \\$_freeCount Free', _totalUsers, Icons.people, Colors.blue, Colors.blue.shade50, Colors.blue.shade700));
      cards.add(_buildStatCard('Wards Under Taluka', '\\$_wardsCount Active · 0 Chairmen Vacant', _wardsCount, Icons.location_on, Colors.green, Colors.green.shade50, Colors.green.shade700));
      cards.add(_buildStatCard('Appointed Ward Chairmen', '\\$_appointedChairmen active chairmen', _appointedChairmen, Icons.shield, Colors.purple, Colors.purple.shade50, Colors.purple.shade700));
      cards.add(_buildStatCard('Channel Partners', '\\$_channelPartners active CPs across wards', _channelPartners, Icons.business_center, Colors.teal, Colors.teal.shade50, Colors.teal.shade700));
    } else {
      cards.add(_buildStatCard('Total Ward Members', '\\$_primeCount Prime · \\$_basicCount Basic · \\$_freeCount Free', _totalUsers, Icons.people, Colors.blue, Colors.blue.shade50, Colors.blue.shade700));
      cards.add(_buildStatCard('Channel Partners', 'Active CPs in ward', _channelPartners, Icons.business_center, Colors.teal, Colors.teal.shade50, Colors.teal.shade700));
      cards.add(_buildStatCard('CP Applications', 'Pending review', _cpSubmissions, Icons.inbox, Colors.amber.shade800, Colors.amber.shade50, Colors.amber.shade700));
      cards.add(_buildStatCard('Cloud Patra', 'Applications', _cloudPatra, Icons.verified_user, Colors.blue, Colors.blue.shade50, Colors.blue.shade700));
    }

    if (cards.isEmpty) {
      cards.add(_buildStatCard('Engagement', 'User interactions', 0, Icons.local_activity, Colors.deepPurple, Colors.deepPurple.shade50, Colors.deepPurple.shade700));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getRoleDisplayName(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getRoleDisplayName(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(_getRoleDescription(), style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (_highestRole != 'super_admin' && (_talukaName.isNotEmpty || _districtName.isNotEmpty))
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                           Icon(Icons.location_on, color: Colors.red.shade400, size: 20),
                           const SizedBox(width: 8),
                           Text('Your Location: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                           Expanded(child: Text('\\$_stateName > \\$_districtName > \\$_talukaName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]
                      )
                    ),
                  const SizedBox(height: 16),
                  GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85,
                    children: cards,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTabs(),
                  
                  if (_activeTab == 'Overview & Analytics')
                    _buildOverviewTab()
                  else
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                         child: Text('\\$_activeTab data will appear here', style: TextStyle(color: Colors.grey.shade500))
                      )
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
`;

const newText = text.replace(/String _getRoleDisplayName\(\) \{[\s\S]*\}\s*\}$/, replacement.trim() + "\n");
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', newText, 'utf-8');
