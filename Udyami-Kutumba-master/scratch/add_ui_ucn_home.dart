import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/features/ucn/presentation/ucn_home_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('_buildAssemblyOverview')) {
    content = content.replaceFirst(
      "  Widget _buildJoinPrimeUI",
      """  Widget _buildAssemblyOverview() {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_assemblyStats == null && _wards.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_assemblyStats != null) ...[
          const SizedBox(height: 16),
          _buildOverallStatsCard(_assemblyStats!),
        ],
        if (_wards.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Wards Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _wards.length,
            itemBuilder: (context, index) {
              return _buildWardCard(_wards[index]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOverallStatsCard(Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall Assembly Statistics",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Total Wards", "\"),
              _buildMiniStat("Total Members", "\"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Basic", "\", color: Colors.blue),
              _buildMiniStat("Prime", "\", color: Colors.orange),
              _buildMiniStat("Patron", "\", color: Colors.purple),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Gratitude Slips", "\"),
              _buildMiniStat("Gratitude Value", "? \"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWardCard(Map<String, dynamic> ward) {
    final members = ward['members'] as List<dynamic>? ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          "\ (Ward \)",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Members: \ | Gratitude: ?\",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat("Basic", "\", color: Colors.blue),
                    _buildMiniStat("Prime", "\", color: Colors.orange),
                    _buildMiniStat("Patron", "\", color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Members List:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (members.isEmpty)
                  const Text("No members found.", style: TextStyle(color: Colors.grey))
                else
                  ...members.map((m) {
                    final String name = m['name'] ?? 'Unknown';
                    final String email = m['email'] ?? '';
                    final String phone = m['mobileNumber'] ?? '';
                    final String memType = m['membership'] ?? 'BASIC';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?"),
                      ),
                      title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text("\\\n\", style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: memType == 'PRIME' ? Colors.orange.shade100 : (memType == 'PATRON' ? Colors.purple.shade100 : Colors.blue.shade100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(memType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildJoinPrimeUI"""
    );
  }

  if (content.contains("if (_selectedRole == 'Assembly Leader') ...[")) {
    content = content.replaceFirst(
      "          if (_selectedRole == 'Circle Leader') ...[",
      "          if (_selectedRole == 'Assembly Leader' || _selectedRole == 'Taluka Head') _buildAssemblyOverview(),\n\n          if (_selectedRole == 'Circle Leader') ...["
    );
  }
  
  file.writeAsStringSync(content);
}
