import 'package:flutter/material.dart';
import '../../../core/api/role/role_api.dart';
import '../../../core/api/area/dashboard_api.dart';
import '../../../core/utils/session_manager.dart';

class ManageRolesScreen extends StatefulWidget {
  const ManageRolesScreen({super.key});

  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  final RoleAPI _roleApi = RoleAPI();
  final DashboardAPI _dashboardApi = DashboardAPI();
  bool _isLoading = true;
  List<dynamic> _roleUsers = [];
  List<dynamic> _availableRoles = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRoles();
    _fetchAllRoles();
  }

  Future<void> _fetchAllRoles() async {
    try {
      print('DEV DEBUG ManageRoles - Calling getAllRoles API...');
      final res = await _roleApi.getAllRoles();
      print('DEV DEBUG ManageRoles - getAllRoles Response received: $res');
      if (res != null && res['success'] == true) {
        final currentUser = SessionManager.user;
        String? currentRole;
        if (currentUser?['userRoles'] != null && currentUser!['userRoles'].isNotEmpty) {
          currentRole = currentUser['userRoles'][0]['role']?['role'];
        } else if (currentUser?['roles'] != null && currentUser!['roles'].isNotEmpty) {
          currentRole = currentUser['roles'][0]?['role'];
        }
        
        final roleLower = (currentRole ?? currentUser?['roleName'] ?? '').toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
        
        // Match the web app's HIDDEN_ROLES_BY_LOGIN logic
        final hiddenRoles = {
          'superadmin': <String>[],
          'districthead': ['SuperAdmin', 'DistrictHead'],
          'talukhead': ['SuperAdmin', 'DistrictHead', 'TalukHead'],
          'wardchairman': ['SuperAdmin', 'DistrictHead', 'TalukHead', 'WardChairman'],
        };
        
        final rolesToHide = hiddenRoles[roleLower] ?? <String>[];
        
        setState(() {
          final allRoles = res['data'] ?? [];
          _availableRoles = allRoles.where((r) {
             final roleName = r['role']?.toString() ?? '';
             return !rolesToHide.contains(roleName);
          }).toList();
          print('DEV DEBUG ManageRoles - Parsed ${_availableRoles.length} available roles after hierarchy filtering');
        });
      }
    } catch (e) {
      debugPrint("Error fetching all roles: $e");
      print('DEV DEBUG ManageRoles - Error in _fetchAllRoles: $e');
    }
  }

  Future<void> _fetchRoles() async {
    try {
      print('DEV DEBUG ManageRoles - Calling getAllUsers API...');
      final res = await _dashboardApi.fetchUsersSuperAdmin();
      print('DEV DEBUG ManageRoles - getAllUsers Response received');
      
      if (res != null && res['success'] == true) {
        final currentUser = SessionManager.user;
        String? currentRole;
        if (currentUser?['userRoles'] != null && currentUser!['userRoles'].isNotEmpty) {
          currentRole = currentUser['userRoles'][0]['role']?['role'];
        } else if (currentUser?['roles'] != null && currentUser!['roles'].isNotEmpty) {
          currentRole = currentUser['roles'][0]?['role'];
        }
        
        final roleLower = (currentRole ?? currentUser?['roleName'] ?? '').toString().toLowerCase();
        
        final isDistrictHead = roleLower.contains('districthead') || roleLower.contains('district_head') || roleLower == 'district head';
        final isTalukaHead = roleLower.contains('talukhead') || roleLower.contains('taluka_head') || roleLower.contains('talukahead') || roleLower == 'taluk head' || roleLower == 'taluka head';
        
        String? loggedInDistrictId = currentUser?['location']?['district']?['districtId']?.toString();
        String? loggedInTalukaId = currentUser?['location']?['taluka']?['talukaId']?.toString();
        
        if (loggedInDistrictId == null && currentUser?['positions'] != null && currentUser!['positions'].isNotEmpty) {
          loggedInDistrictId = currentUser['positions'][0]?['district']?['districtId']?.toString();
        }
        if (loggedInTalukaId == null && currentUser?['positions'] != null && currentUser!['positions'].isNotEmpty) {
          loggedInTalukaId = currentUser['positions'][0]?['taluka']?['talukaId']?.toString();
        }

        List<dynamic> allUsers = [];
        if (res['data'] is List) {
          allUsers = res['data'];
        } else if (res['data'] != null && res['data']['data'] is List) {
          allUsers = res['data']['data'];
        }
        
        if (isTalukaHead && loggedInTalukaId != null) {
          allUsers = allUsers.where((u) {
             final locTalId = u['location']?['taluka']?['talukaId']?.toString();
             if (locTalId == loggedInTalukaId) return true;
             
             final positions = u['positions'] as List?;
             if (positions != null) {
               return positions.any((p) => p['taluka']?['talukaId']?.toString() == loggedInTalukaId);
             }
             return u['talukaId']?.toString() == loggedInTalukaId;
          }).toList();
        } else if (isDistrictHead && loggedInDistrictId != null) {
          allUsers = allUsers.where((u) {
             final locDistId = u['location']?['district']?['districtId']?.toString();
             if (locDistId == loggedInDistrictId) return true;
             
             final positions = u['positions'] as List?;
             if (positions != null) {
               return positions.any((p) => p['district']?['districtId']?.toString() == loggedInDistrictId);
             }
             return u['districtId']?.toString() == loggedInDistrictId;
          }).toList();
        }

        setState(() {
          _roleUsers = allUsers;
          print('DEV DEBUG ManageRoles - Total users parsed and filtered: ${_roleUsers.length}');
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      print('DEV DEBUG ManageRoles - Error in _fetchRoles: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _roleUsers.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Manage Roles'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Org Chart'),
              Tab(text: 'Role Cards'),
              Tab(text: 'Assign Roles'),
            ],
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Org Chart
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Organizational Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Text('Best viewed on the Web Dashboard.', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
            
            // Tab 2: Role Cards (Definitions)
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Role Definitions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildRoleDefCard(context, 'State Head', 'Top-level admin across the state.', Colors.purple),
                _buildRoleDefCard(context, 'District Head', 'Manages a specific district.', Colors.blue),
                _buildRoleDefCard(context, 'Taluka Head', 'Manages talukas under a district.', Colors.teal),
                _buildRoleDefCard(context, 'Ward Chairman', 'Manages specific wards.', Colors.green),
                _buildRoleDefCard(context, 'Channel Partner', 'Onboards local businesses.', Colors.orange),
              ],
            ),
            
            // Tab 3: Assign Roles (List of Users)
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRoles,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredUsers.isEmpty
                              ? const Center(child: Text('No role users found.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = filteredUsers[index];
                                    final name = user['name'] ?? 'Unknown User';
                                    final rolesList = user['roles'] as List? ?? [];
                                    final rolesStr = rolesList.map((r) => r['roleName']).join(', ');
                                    final loc = user['location'] ?? {};
                                    final List<dynamic>? positions = user['positions'];
                                    final primaryPos = (positions != null && positions.isNotEmpty) ? positions[0] : null;
                                    
                                    final String districtRaw = loc['district']?['districtName']?.toString() 
                                        ?? primaryPos?['district']?['districtName']?.toString() 
                                        ?? user['districtName']?.toString() 
                                        ?? user['district']?.toString() 
                                        ?? '';
                                        
                                    final String talukaRaw = loc['taluka']?['talukaName']?.toString() 
                                        ?? primaryPos?['taluka']?['talukaName']?.toString() 
                                        ?? user['talukaName']?.toString() 
                                        ?? user['taluka']?.toString() 
                                        ?? '';
                                        
                                    final String wardRaw = loc['ward']?['wardName']?.toString() 
                                        ?? primaryPos?['ward']?['wardName']?.toString() 
                                        ?? user['wardName']?.toString() 
                                        ?? user['ward']?.toString() 
                                        ?? '';
                                    
                                    final hasLocation = districtRaw.isNotEmpty || talukaRaw.isNotEmpty || wardRaw.isNotEmpty;
                                    final businessLocation = user['businessLocation']?.toString() ?? '—';
                                    
                                    final locationParts = [talukaRaw, districtRaw].where((e) => e.isNotEmpty).join(", ");

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
                                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                          child: Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                          ),
                                        ),
                                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              rolesStr.isNotEmpty ? rolesStr : 'No roles assigned',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (hasLocation) ...[
                                              if (wardRaw.isNotEmpty)
                                                Text('Ward: $wardRaw', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                              if (locationParts.isNotEmpty)
                                                Text(locationParts, style: const TextStyle(fontSize: 12)),
                                            ] else
                                              Text('Location: $businessLocation', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                        trailing: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                            foregroundColor: Theme.of(context).colorScheme.primary,
                                          ),
                                          onPressed: () {
                                            _showRoleAssignmentSheet(context, user);
                                          },
                                          child: const Text('Assign'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showRoleAssignmentSheet(BuildContext context, dynamic user) {
    print('DEV DEBUG ManageRoles - Opening Assignment Sheet for user: ${user['userId']} (${user['name']})');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Assign Role to ${user['name'] ?? 'User'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              if (_availableRoles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableRoles.length,
                    itemBuilder: (context, index) {
                      final role = _availableRoles[index];
                      return ListTile(
                        leading: const Icon(Icons.security),
                        title: Text(role['roleName']?.toString() ?? 'Unknown Role'),
                        onTap: () {
                          print('DEV DEBUG ManageRoles - Selected role: ${role['roleName']} (ID: ${role['roleId']}) for user ${user['userId']}');
                          Navigator.pop(context);
                          _confirmRoleAssignment(context, user, role);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRoleAssignment(BuildContext context, dynamic user, dynamic role) {
    print('DEV DEBUG ManageRoles - Prompting confirmation for user: ${user['userId']}, role: ${role['roleId']}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Assignment'),
          content: Text('Are you sure you want to assign the role "${role['roleName']}" to ${user['name'] ?? 'this user'}?'),
          actions: [
            TextButton(
              onPressed: () {
                print('DEV DEBUG ManageRoles - Confirmation cancelled');
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                print('DEV DEBUG ManageRoles - Confirmation accepted');
                Navigator.pop(context);
                await _assignRole(user, role);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignRole(dynamic user, dynamic role) async {
    try {
      print('DEV DEBUG ManageRoles - Starting _assignRole process...');
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final currentUser = SessionManager.user;
      
      String roleType = role['roleName']?.toString().toLowerCase() ?? '';
      
      final payload = {
        "userId": user['userId'],
        "roleId": role['roleId'],
        "assignedBy": currentUser?['userId'] ?? currentUser?['memberId'],
        "type": roleType,
      };
      
      // Attempt to extract target user's location
      final loc = user['location'] ?? {};
      final List<dynamic>? positions = user['positions'];
      final primaryPos = (positions != null && positions.isNotEmpty) ? positions[0] : null;

      String? dId = user['districtId']?.toString() 
          ?? loc['district']?['districtId']?.toString() 
          ?? primaryPos?['district']?['districtId']?.toString();
          
      String? tId = user['talukaId']?.toString() 
          ?? loc['taluka']?['talukaId']?.toString()
          ?? primaryPos?['taluka']?['talukaId']?.toString();
          
      String? wId = user['wardId']?.toString() 
          ?? loc['ward']?['wardId']?.toString()
          ?? primaryPos?['ward']?['wardId']?.toString();
      
      // Fallback to current admin's location if target user doesn't have it (e.g. Taluka Head assigning Ward Chairman within their taluka)
      if (dId == null || dId.isEmpty) dId = currentUser?['location']?['district']?['districtId']?.toString();
      if (tId == null || tId.isEmpty) tId = currentUser?['location']?['taluka']?['talukaId']?.toString();
      if (wId == null || wId.isEmpty) wId = currentUser?['location']?['ward']?['wardId']?.toString();

      if (roleType == 'district_head') {
        if (dId != null) payload['districtId'] = dId;
      } else if (roleType == 'taluka_head') {
        if (dId != null) payload['districtId'] = dId;
        if (tId != null) payload['talukaIds'] = [tId]; // array required by API
        // Fallback for missing dropdown in mobile:
        payload['districtHeadId'] = currentUser?['userId'] ?? currentUser?['memberId'];
      } else if (roleType == 'ward_chairman') {
        if (tId != null) payload['talukaId'] = tId;
        if (wId != null) payload['wardId'] = wId;
        // Fallback for missing dropdown in mobile:
        payload['talukaHeadId'] = currentUser?['userId'] ?? currentUser?['memberId'];
      } else if (roleType == 'channel_partner' || roleType == 'circle_leader') {
        if (wId != null) payload['wardId'] = wId;
        // Fallback for missing dropdown in mobile:
        payload['wardHeadId'] = currentUser?['userId'] ?? currentUser?['memberId'];
      } else {
        // generic role
        if (dId != null) payload['districtId'] = dId;
        if (tId != null) payload['talukaId'] = tId;
        if (wId != null) payload['wardId'] = wId;
      }

      print('DEV DEBUG ManageRoles - assignRole Payload: $payload');
      final res = await _roleApi.assignRole(payload);
      print('DEV DEBUG ManageRoles - assignRole Response: $res');

      // Hide loading overlay
      if (mounted) Navigator.pop(context);

      if (res != null && res['success'] == true) {
        print('DEV DEBUG ManageRoles - Role successfully assigned');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role assigned successfully')),
          );
        }
        _fetchRoles(); // Refresh the list
      } else {
        print('DEV DEBUG ManageRoles - Role assignment failed: ${res?['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to assign role: ${res?['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      print('DEV DEBUG ManageRoles - Exception in _assignRole: $e');
      if (mounted) Navigator.pop(context); // Hide loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning role: $e')),
        );
      }
    }
  }

  Widget _buildRoleDefCard(BuildContext context, String name, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      color: color.withValues(alpha: 0.05),
      child: ListTile(
        leading: Icon(Icons.admin_panel_settings, color: color),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ),
    );
  }
}
