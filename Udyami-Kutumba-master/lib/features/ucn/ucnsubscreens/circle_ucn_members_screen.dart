import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/api/role/role_api.dart' as import_role_api;
import 'gratitude_history_screen.dart';
import 'member_activities_screen.dart';

class CircleUcnMembersScreen extends StatefulWidget {
  final String? wardId;
  const CircleUcnMembersScreen({super.key, this.wardId});

  @override
  State<CircleUcnMembersScreen> createState() => _CircleUcnMembersScreenState();
}

class _CircleUcnMembersScreenState extends State<CircleUcnMembersScreen> {
  bool _isLoading = true;
  String _wardId = '';
  UserModel? _currentUser;
  Map<String, dynamic>? _wardData;

  String _selectedPlanFilter = "All";
  final List<String> _planFilters = ["All", "Basic", "Prime", "Patron"];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    if (widget.wardId != null && widget.wardId!.isNotEmpty) {
      _wardId = widget.wardId!;
      await _fetchWardData();
      setState(() => _isLoading = false);
      return;
    }

    final userJson = SessionManager.user;
    if (userJson != null) {
      _currentUser = UserModel.fromJson(userJson);
      try {
        final roleWithWard = _currentUser!.roles.firstWhere(
          (r) => r.wardId != null && r.wardId!.isNotEmpty,
          orElse: () => RoleModel(roleId: 0, roleName: ''),
        );
        if (roleWithWard.wardId != null && roleWithWard.wardId!.isNotEmpty) {
          _wardId = roleWithWard.wardId!;
        } else {
          debugPrint('DEV DEBUG [CircleUcnMembers] - No wardId found in roles, falling back to RoleAPI...');
          final rolesRes = await import_role_api.RoleAPI().getAllRoleUsers();
          if (rolesRes != null && rolesRes['success'] == true) {
            final List rawRoleUsers = rolesRes['data'] ?? [];
            final matchUser = rawRoleUsers.cast<Map<String, dynamic>>().firstWhere(
              (u) => u['userId'] == _currentUser!.userId,
              orElse: () => {},
            );
            if (matchUser.isNotEmpty && matchUser.containsKey('assignment')) {
              final assignment = matchUser['assignment'] ?? {};
              if (assignment['wardId'] != null) {
                _wardId = assignment['wardId'].toString();
                debugPrint('DEV DEBUG [CircleUcnMembers] - Found wardId via RoleAPI: $_wardId');
              }
            }
          }
          
          if (_wardId.isEmpty) {
            debugPrint('DEV DEBUG [CircleUcnMembers] - Still no wardId, falling back to ProfileAPI...');
            final profileRes = await ProfileAPI().getUserProfileById(_currentUser!.userId);
            if (profileRes != null && profileRes['success'] == true) {
              final wardName = profileRes['data']?['profile']?['ward'];
              if (wardName != null && wardName.toString().isNotEmpty) {
                final allWardsRes = await WardAPI().getAllWards(wardName: wardName.toString());
                if (allWardsRes != null && allWardsRes['success'] == true) {
                  final List wards = allWardsRes['data'] ?? [];
                  if (wards.isNotEmpty) {
                    _wardId = wards[0]['wardId'];
                    debugPrint('DEV DEBUG [CircleUcnMembers] - Found wardId via ProfileAPI: $_wardId');
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error getting wardId: $e');
      }

      if (_wardId.isNotEmpty) {
        await _fetchWardData();
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchWardData() async {
    try {
      final res = await WardAPI().getAllUcnMembersUnderWard(_wardId);
      if (res != null && res['success'] == true) {
        debugPrint('WARD DATA RESPONSE: ${res['data']}');
        final data = res['data'];
        if (data != null && data['members'] != null && (data['members'] as List).isNotEmpty) {
          debugPrint('FIRST MEMBER DATA: ${data['members'][0]}');
        }
        setState(() {
          _wardData = data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ward data: $e');
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Members', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wardId.isEmpty
              ? const Center(child: Text('Area ID not found'))
              : _wardData == null
                  ? const Center(child: Text('No data found'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final allMembers = _wardData?['members'] as List? ?? [];
    
    // Filter members based on plan
    final members = allMembers.where((m) {
      if (_selectedPlanFilter == "All") return true;
      final planId = m['membership']?.toString().toLowerCase() ?? '';
      return planId.contains(_selectedPlanFilter.toLowerCase());
    }).toList();

    return RefreshIndicator(
      onRefresh: _fetchWardData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsHeader(context),
          const SizedBox(height: 16),
          _buildCountCards(context),
          const SizedBox(height: 16),
          _buildActivityStats(context),
          const SizedBox(height: 24),
          
          // Filters Header
          const Text(
            'Filter by Plan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          
          // Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _planFilters.map((plan) {
                final isSelected = _selectedPlanFilter == plan;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPlanFilter = plan;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: _buildPill(plan, isSelected: isSelected),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Members List (${members.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            const Text('No members found for this filter.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final m = members[index];
                
                // Try extracting role name
                String roleText = '';
                if (m['roles'] != null && m['roles'] is List && m['roles'].isNotEmpty) {
                  roleText = m['roles'][0]['roleName']?.toString() ?? '';
                }
                if (roleText.isEmpty) {
                  roleText = m['role']?.toString() ?? '';
                }
                
                final String planText = m['membership']?.toString().toUpperCase() ?? 'NONE';
                final String phoneText = m['mobileNumber']?.toString() ?? '';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final targetId = m['userId']?.toString();
                      if (targetId != null && targetId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberActivitiesScreen(memberData: m),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image
                          Builder(
                            builder: (context) {
                              if (m['profileImage'] == null || m['profileImage'].toString().isEmpty) {
                                return CircleAvatar(radius: 26, backgroundColor: Colors.blue.withValues(alpha: 0.1), child: const Icon(Icons.person, color: Colors.blue, size: 28));
                              } else if (m['profileImage'].toString().startsWith('data:')) {
                                return CircleAvatar(radius: 26, backgroundImage: MemoryImage(base64Decode(m['profileImage'].toString().split(',').last)));
                              } else {
                                return ClipOval(
                                  child: Image.network(
                                    m['profileImage'].toString(),
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => CircleAvatar(radius: 26, backgroundColor: Colors.blue.withValues(alpha: 0.1), child: const Icon(Icons.person, color: Colors.blue, size: 28)),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          
                          // Member Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['name']?.toString() ?? 'N/A',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (phoneText.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        phoneText,
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                if (m['email'] != null && m['email'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.email, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            m['email'].toString(),
                                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Actions & Tags
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Role / Plan Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  roleText.isNotEmpty ? roleText : planText,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Call Button
                              if (phoneText.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.call, color: Colors.green),
                                  onPressed: () => _launchPhoneCall(phoneText),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.teal
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: "Total Members",
            value: "${_wardData?['totalMembers'] ?? 0}",
            icon: Icons.groups_rounded,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCountCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSmallCountCard("Basic", _wardData?['basicCount'] ?? 0, Colors.blueGrey),
        _buildSmallCountCard("Prime", _wardData?['primeCount'] ?? 0, Colors.orange),
        _buildSmallCountCard("Patron", _wardData?['patronCount'] ?? 0, Colors.purple),
      ],
    );
  }

  Widget _buildSmallCountCard(String label, dynamic count, Color color) {
    int c = 0;
    if (count is int) c = count;
    else if (count is String) c = int.tryParse(count) ?? 0;
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(c.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context) {
    return Column(
      children: [
        _buildTwoColCard("Gratitude Slips", (_wardData?['totalGratitudeSlips'] ?? 0).toString(), 
                         "Total Amount", "₹${_wardData?['totalGratitudeAmount'] ?? 0}", 
                         [Colors.green.shade700, Colors.green.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Leads", 
                           "Total", (_wardData?['totalLeads'] ?? 0).toString(), 
                           [Colors.blue.shade700, Colors.blue.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Face to Face", 
                           "Total", (_wardData?['totalFaceToFace'] ?? 0).toString(), 
                           [Colors.indigo.shade700, Colors.indigo.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Guests", 
                           "Total", (_wardData?['totalGuests'] ?? 0).toString(), 
                           [Colors.deepPurple.shade700, Colors.deepPurple.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Attendance", 
                           "Total", (_wardData?['totalAttendance'] ?? 0).toString(), 
                           [Colors.teal.shade700, Colors.teal.shade500]),
      ],
    );
  }

  Widget _buildTitleAndStatCard(String title, String valLabel, String val, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: colors[0].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Text(
              title, 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), 
              textAlign: TextAlign.center
            ),
          ),
          Container(height: 40, width: 1, color: Colors.white30),
          Expanded(
            child: Column(
              children: [
                Text(valLabel, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColCard(String label1, String val1, String label2, String val2, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: colors[0].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(label1, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(val1, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(height: 40, width: 1, color: Colors.white30),
          Expanded(
            child: Column(
              children: [
                Text(label2, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(val2, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
