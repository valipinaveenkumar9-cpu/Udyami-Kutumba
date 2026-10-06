const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

const replacement = `
                    const Text(
                      'Business Circles',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search circles...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _statusFilter,
                                isExpanded: true,
                                icon: const Icon(Icons.filter_list, size: 18),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All')),
                                  DropdownMenuItem(value: 'live', child: Text('Live')),
                                  DropdownMenuItem(value: 'eligible', child: Text('Eligible')),
                                  DropdownMenuItem(value: 'planned', child: Text('Planned')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _statusFilter = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _filteredCircles.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No circles found for this area.', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredCircles.length,
                            itemBuilder: (context, index) {
                              final circle = _filteredCircles[index];
                              final status = circle['status']?.toString() ?? 'Planned';
                              
                              Color statusColor = Colors.grey;
                              if (status.toLowerCase() == 'live') statusColor = Colors.green;
                              if (status.toLowerCase() == 'eligible') statusColor = Colors.orange;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              circle['name'] ?? 'Unknown',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8, height: 8,
                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        circle['level'] ?? 'Ward',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoCol('Members', '${circle['members'] ?? 0}'),
                                          _buildInfoCol('Attendance', '${circle['attendancePercentage'] ?? 0}%'),
                                          _buildInfoCol('Coverage', '${circle['uniquePresentMembers'] ?? 0}/${circle['members'] ?? 0}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
`;

// Also need to add `_buildInfoCol` method outside build.
const infoCol = `
  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
`;

const startIndex = text.indexOf("const Text(");
const endIndex = text.indexOf("],", startIndex);

text = text.substring(0, startIndex) + replacement + text.substring(endIndex);

const buildIndex = text.lastIndexOf("Widget build(BuildContext context) {");
text = text.substring(0, buildIndex) + infoCol + '\n  @override\n  ' + text.substring(buildIndex);

// Also remove the extra const Text('Business Circles' that might be matched incorrectly.
// Actually startIndex will find the first const Text(. Let's be safer:

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.tmp.dart', text, 'utf-8');
