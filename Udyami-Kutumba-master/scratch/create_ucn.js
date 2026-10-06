const fs = require('fs');

const code = `import 'package:flutter/material.dart';
import '../../../core/api/dashboard_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_model.dart';
import '../../../core/api/profile_api.dart';

class UcnDashboardScreen extends StatefulWidget {
  const UcnDashboardScreen({super.key});

  @override
  State<UcnDashboardScreen> createState() => _UcnDashboardScreenState();
}

class _UcnDashboardScreenState extends State<UcnDashboardScreen> {
  final DashboardAPI _dashboardApi = DashboardAPI();
  final ProfileAPI _profileApi = ProfileAPI();

  bool _isLoading = true;
  String _highestRole = 'member';
  String _entityId = '';
  String _entityType = 'member';

  Map<String, dynamic> _summary = {};
  List<dynamic> _circlesList = [];

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    try {
      final user = SessionManager.user;
      if (user == null || user['userId'] == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final userModel = UserModel.fromJson(user);
      if (userModel.roles.isNotEmpty) {
        _highestRole = userModel.roles.first.roleName.toLowerCase();
        for (final r in userModel.roles) {
          final rl = r.roleName.toLowerCase();
          if (rl == 'super_admin') { _highestRole = rl; break; }
          if (rl.contains('district')) { _highestRole = rl; }
          if (rl.contains('taluka') && !_highestRole.contains('district')) { _highestRole = rl; }
          if ((rl.contains('ward_chairman') || rl.contains('ward_head')) && !_highestRole.contains('taluka') && !_highestRole.contains('district')) { _highestRole = rl; }
        }
      }

      // 1. Get user profile
      final profileRes = await _profileApi.getUserProfileById(user['userId'].toString());
      final profile = profileRes != null && profileRes['success'] == true ? profileRes['data']?['profile'] : null;

      // 2. Identify entityId and type based on Web's Business Circle logic
      if (_highestRole == 'super_admin') {
        _entityId = 'karnataka';
        _entityType = 'state';
      } else if (_highestRole.contains('district')) {
        _entityType = 'district';
        if (profile != null && profile['district'] != null) {
          _entityId = profile['district'] is Map ? profile['district']['_id']?.toString() ?? '' : profile['district'].toString();
        }
        if (_entityId.isEmpty && user['district'] != null) {
          _entityId = user['district'] is Map ? user['district']['_id']?.toString() ?? '' : user['district'].toString();
        }
      } else if (_highestRole.contains('taluka')) {
        _entityType = 'taluka';
        if (profile != null && profile['taluka'] != null) {
          _entityId = profile['taluka'] is Map ? profile['taluka']['_id']?.toString() ?? '' : profile['taluka'].toString();
        }
        if (_entityId.isEmpty) {
          try {
            final locRes = await _dashboardApi.getLocationByWardHeadId(user['userId'].toString());
            final locData = locRes?['data'] ?? locRes;
            List wardsArray = [];
            if (locData is Map && locData['wards'] is List) wardsArray = locData['wards'];
            else if (locData is List) wardsArray = locData;
            else if (locData is Map && locData['areaChart'] != null && locData['areaChart']['wards'] is List) wardsArray = locData['areaChart']['wards'];
            if (wardsArray.isNotEmpty) {
              final source = wardsArray.first as Map<String, dynamic>;
              _entityId = source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? '';
            }
          } catch (_) {}
        }
      } else if (_highestRole.contains('ward')) {
        _entityType = 'ward';
        if (profile != null && profile['ward'] != null) {
          _entityId = profile['ward'] is Map ? profile['ward']['_id']?.toString() ?? '' : profile['ward'].toString();
        }
      }

      // 3. Fetch Dashboard Data
      if (_entityId.isNotEmpty && _entityType.isNotEmpty) {
        final res = await _dashboardApi.getBusinessCircleDashboard(_entityId, _entityType);
        if (res != null && (res['success'] == true || res['summary'] != null)) {
          final dataObj = res['data'] ?? res;
          setState(() {
            _summary = dataObj['summary'] ?? {};
            if (dataObj['assemblies'] != null && (dataObj['assemblies'] as List).isNotEmpty) {
               _circlesList = dataObj['assemblies'];
            } else if (dataObj['wards'] != null && (dataObj['wards'] as List).isNotEmpty) {
               _circlesList = dataObj['wards'];
            } else {
               _circlesList = [];
            }
          });
        }
      }

    } catch (e) {
      debugPrint("Error loading UCN dashboard: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.1),
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
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('UBN Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard('Total Members', '${_summary['totalMembers'] ?? 0}', Icons.people_outline, Colors.blue),
                        _buildStatCard('Prime Members', '${_summary['primeMembers'] ?? 0}', Icons.star_outline, Colors.orange),
                        _buildStatCard('Total Leads', '${_summary['totalLeads'] ?? 0}', Icons.trending_up, Colors.green),
                        _buildStatCard('Gratitude Value', '?${_summary['totalGratitudeValue'] ?? 0}', Icons.monetization_on_outlined, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Business Circles',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _circlesList.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No circles found for this area.', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _circlesList.length,
                            itemBuilder: (context, index) {
                              final circle = _circlesList[index];
                              final name = circle['assemblyName'] ?? circle['talukaName'] ?? circle['wardName'] ?? 'Unknown';
                              final number = circle['wardNumber'] != null ? '${circle['wardNumber']} ' : '';
                              final members = circle['totalMembers'] ?? circle['members'] ?? 0;
                              final attendance = circle['attendancePercentage'] ?? 0;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    child: Icon(Icons.business_center, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  title: Text('$number$name', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Members: $members • Attendance: $attendance%'),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
`;

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', code, 'utf-8');
