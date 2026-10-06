import 'package:flutter/material.dart';
import '../../../core/api/area/dashboard_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_model.dart';
import '../../../core/api/profile/profile_api.dart';

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
  List<Map<String, dynamic>> _rawCirclesList = [];
  
  // Filters
  String _searchQuery = '';
  String _statusFilter = 'all';

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

      print('DEV DEBUG UCN - User Roles: ${userModel.roles.map((r) => r.roleName).toList()}');
      print('DEV DEBUG UCN - Highest Role resolved to: $_highestRole');

      // 1. Get user profile
      final profileRes = await _profileApi.getUserProfileById(user['userId'].toString());
      Map<String, dynamic>? profile;
      if (profileRes != null && profileRes['success'] == true) {
        if (profileRes['data'] is Map && profileRes['data']['profile'] is Map) {
          profile = profileRes['data']['profile'];
        }
      }

      // 2. Identify entityId and type
      if (_highestRole == 'super_admin') {
        _entityId = 'karnataka';
        _entityType = 'state';
      } else if (_highestRole.contains('district')) {
        _entityType = 'district';
        if (profile != null && profile['district'] != null) {
          _entityId = profile['district'] is Map ? (profile['district']['_id']?.toString() ?? '') : profile['district'].toString();
        }
        if (_entityId.isEmpty && user['district'] != null) {
          _entityId = user['district'] is Map ? (user['district']['_id']?.toString() ?? '') : user['district'].toString();
        }
      } else if (_highestRole.contains('taluka')) {
        _entityType = 'taluka';
        if (profile != null && profile['taluka'] != null) {
          _entityId = profile['taluka'] is Map ? (profile['taluka']['_id']?.toString() ?? '') : profile['taluka'].toString();
        }
        if (_entityId.isEmpty) {
          try {
            final locRes = await _dashboardApi.getLocationByWardHeadId(user['userId'].toString());
            final locData = locRes != null ? (locRes['data'] ?? locRes) : null;
            List wardsArray = [];
            if (locData is Map && locData['wards'] is List) wardsArray = locData['wards'];
            else if (locData is List) wardsArray = locData;
            else if (locData is Map && locData['areaChart'] != null && locData['areaChart']['wards'] is List) wardsArray = locData['areaChart']['wards'];
            if (wardsArray.isNotEmpty) {
              final source = wardsArray.first as Map;
              if (source['taluka'] is Map) {
                _entityId = source['taluka']['_id']?.toString() ?? source['taluka']['talukaId']?.toString() ?? '';
              }
            }
          } catch (_) {}
        }
      } else if (_highestRole.contains('ward')) {
        _entityType = 'ward';
        if (profile != null && profile['ward'] != null) {
          _entityId = profile['ward'] is Map ? (profile['ward']['_id']?.toString() ?? '') : profile['ward'].toString();
        }
      }

      // 3. Fetch Dashboard Data
      print('DEV DEBUG UCN - Final Entity Setup -> Type: $_entityType, ID: $_entityId');
      
      if (_entityId.isNotEmpty && _entityType.isNotEmpty) {
        final res = await _dashboardApi.getBusinessCircleDashboard(_entityId, _entityType);
        if (res != null && (res['success'] == true || res['summary'] != null)) {
          final dataObj = res['data'] ?? res;
          print('DEV DEBUG UCN - Dashboard API Response Data: $dataObj');
          setState(() {
            _summary = dataObj['summary'] ?? {};
            
            _rawCirclesList = [];
            if (dataObj['assemblies'] != null && (dataObj['assemblies'] as List).isNotEmpty) {
               for (var a in (dataObj['assemblies'] as List)) {
                 _rawCirclesList.add({
                   'id': a['assemblyId'] ?? a['talukaId'],
                   'name': a['assemblyName'] ?? a['talukaName'] ?? 'Unknown',
                   'level': 'Constituency',
                   'members': a['totalMembers'] ?? a['members'] ?? 0,
                   'attendancePercentage': a['attendancePercentage'] ?? 0,
                   'uniquePresentMembers': a['uniquePresentMembers'] ?? 0,
                   'status': a['status'] ?? 'Planned',
                 });
               }
            } else if (dataObj['wards'] != null && (dataObj['wards'] as List).isNotEmpty) {
               for (var w in (dataObj['wards'] as List)) {
                 final wardNum = w['wardNumber'] != null ? '${w['wardNumber']} ' : '';
                 _rawCirclesList.add({
                   'id': w['wardId'],
                   'name': '$wardNum${w['wardName']}',
                   'level': 'Ward',
                   'members': w['members'] ?? 0,
                   'attendancePercentage': w['attendancePercentage'] ?? 0,
                   'uniquePresentMembers': w['uniquePresentMembers'] ?? 0,
                   'status': w['status'] ?? 'Planned',
                 });
               }
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

  
  List<Map<String, dynamic>> get _filteredCircles {
    return _rawCirclesList.where((c) {
      final matchesSearch = c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            c['level'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || c['status'].toString().toLowerCase() == _statusFilter.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withValues(alpha: 0.1),
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8)),
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
                        _buildStatCard('Gratitude Value', '₹${_summary['totalGratitudeValue'] ?? 0}', Icons.monetization_on_outlined, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                  ],
                ),
              ),
            ),
    );
  }
}
