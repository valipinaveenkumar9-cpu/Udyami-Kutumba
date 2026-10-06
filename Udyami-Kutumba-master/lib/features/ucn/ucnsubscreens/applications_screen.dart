import 'package:flutter/material.dart';
import '../../../core/api/ubn/application/application_api.dart';
import 'application_detail_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  bool _isLoading = true;
  List<dynamic> _applications = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch both in parallel
      final results = await Future.wait([
        ApplicationAPI.getAllApplications(),
        ApplicationAPI.getStatistics(),
      ]);

      final appsRes = results[0];
      final statsRes = results[1];

      if (appsRes != null && appsRes['success'] == true && appsRes['data'] != null) {
        _applications = appsRes['data'] as List;
      }

      if (statsRes != null && statsRes['success'] == true && statsRes['data'] != null) {
        _stats = statsRes['data'];
      }
    } catch (e) {
      print('DEV DEBUG - error - applications_screen.dart - _fetchData: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Hold':
        return Colors.amber.shade700;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Applications",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    if (_stats.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(child: _buildStatChip("Total", _stats['totalApplications'] ?? 0, Colors.blue)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatChip("Pending", _stats['pendingApplications'] ?? 0, Colors.orange)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatChip("Approved", _stats['approvedApplications'] ?? 0, Colors.green)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatChip("Rejected", _stats['rejectedApplications'] ?? 0, Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Text(
                      "Guest → member applications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_applications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text("No applications yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(_applications.length, (index) {
                        final app = _applications[index];
                        final name = app['guestName'] ?? 'Unknown';
                        final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                        final tag = app['businessTag'] ?? '';
                        final visits = app['visitCount'] ?? 0;
                        final status = app['status'] ?? 'Pending';
                        final statusColor = _getStatusColor(status);

                        // Alternate avatar colors
                        final avatarColors = [
                          [Colors.deepPurple.shade100, Colors.deepPurple.shade900],
                          [Colors.cyan.shade100, Colors.cyan.shade900],
                          [Colors.teal.shade100, Colors.teal.shade900],
                          [Colors.indigo.shade100, Colors.indigo.shade900],
                          [Colors.pink.shade100, Colors.pink.shade900],
                        ];
                        final colorPair = avatarColors[index % avatarColors.length];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildApplicationRow(
                            initials: initials,
                            name: name,
                            subtitle: "$tag · $visits visits",
                            avatarBg: colorPair[0],
                            avatarText: colorPair[1],
                            status: status,
                            statusColor: statusColor,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApplicationDetailScreen(application: app),
                                ),
                              );
                              if (result == true) {
                                _fetchData(); // Refresh after review
                              }
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatChip(String label, dynamic count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            "${count is int ? count : int.tryParse(count.toString()) ?? 0}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationRow({
    required String initials,
    required String name,
    required String subtitle,
    required Color avatarBg,
    required Color avatarText,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarBg,
              child: Text(
                initials,
                style: TextStyle(
                  color: avatarText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
