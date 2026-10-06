import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api/ubn/scorecard_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/location/location_api.dart';
import '../../../core/api/role/role_api.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/taluka_leaderboard_model.dart';
import '../../../../core/models/ward_leaderboard_model.dart';
import '../../../../core/utils/session_manager.dart';

class AssemblyLeaderboardScreen extends StatefulWidget {
  const AssemblyLeaderboardScreen({super.key, this.assemblyName = 'Assembly'});
  final String assemblyName;

  @override
  State<AssemblyLeaderboardScreen> createState() => _AssemblyLeaderboardScreenState();
}

class _AssemblyLeaderboardScreenState extends State<AssemblyLeaderboardScreen> with SingleTickerProviderStateMixin {
  Future<dynamic>? _leaderboardFuture;
  late TabController _tabController;
  String _talukaId = "";
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  Future<void> _initData() async {
    final userData = SessionManager.user;
    if (userData == null) return;
    
    _currentUser = UserModel.fromJson(userData);
    if (_currentUser == null) return;

    try {
      final roleWithTaluka = _currentUser!.roles.firstWhere(
        (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      
      if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
        _talukaId = roleWithTaluka.talukaId!;
      } else {
        // Fallback to ProfileAPI like in members screen
        final profileRes = await ProfileAPI().getUserProfileById(_currentUser!.userId);
        if (profileRes != null && profileRes['success'] == true) {
          final profile = profileRes['data']?['profile'] ?? {};
          
          final districtName = profile['district']?.toString();
          final assemblyName = profile['assembly']?.toString() ?? profile['taluka']?.toString();
          
          if (districtName != null && districtName.isNotEmpty && assemblyName != null && assemblyName.isNotEmpty) {
            final distApiRes = await LocationAPI().getAllDistricts();
            if (distApiRes != null && distApiRes['success'] == true) {
              final List rawDistricts = distApiRes['data'] ?? [];
              
              // First try strict district matching
              final matchDist = rawDistricts.cast<Map<String, dynamic>>().firstWhere(
                (d) => d['districtName']?.toString().toLowerCase() == districtName.toLowerCase(),
                orElse: () => <String, dynamic>{},
              );
              
              bool found = false;
              if (matchDist.isNotEmpty) {
                final distId = matchDist['districtId']?.toString();
                if (distId != null) {
                  final talukaApiRes = await LocationAPI().getAllDistricts(districtId: distId);
                  if (talukaApiRes != null && talukaApiRes['success'] == true) {
                    final List rawTalukas = talukaApiRes['data'] ?? [];
                    final matchTaluka = rawTalukas.cast<Map<String, dynamic>>().firstWhere(
                      (t) => t['talukaName']?.toString().toLowerCase() == assemblyName.toLowerCase(),
                      orElse: () => <String, dynamic>{},
                    );
                    
                    if (matchTaluka.isNotEmpty) {
                      _talukaId = matchTaluka['talukaId']?.toString() ?? '';
                      if (_talukaId.isNotEmpty) {
                        found = true;
                      }
                    }
                  }
                }
              }

              // If strict matching failed (e.g. user selected wrong district in profile), search all districts
              if (!found) {
                for (var dist in rawDistricts) {
                  final dId = dist['districtId']?.toString();
                  if (dId != null) {
                    final talukasRes = await LocationAPI().getAllDistricts(districtId: dId);
                    if (talukasRes != null && talukasRes['success'] == true) {
                      final List tList = talukasRes['data'] ?? [];
                      final tMatch = tList.cast<Map<String, dynamic>>().firstWhere(
                        (t) => t['talukaName']?.toString().toLowerCase() == assemblyName.toLowerCase(),
                        orElse: () => <String, dynamic>{},
                      );
                      if (tMatch.isNotEmpty) {
                        _talukaId = tMatch['talukaId']?.toString() ?? '';
                        if (_talukaId.isNotEmpty) {
                          found = true;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        if (_talukaId.isEmpty) {
          final rolesRes = await RoleAPI().getAllRoleUsers();
          if (rolesRes != null && rolesRes['success'] == true) {
            final List rawRoleUsers = rolesRes['data'] ?? [];
            final matchUser = rawRoleUsers.cast<Map<String, dynamic>>().firstWhere(
              (u) => u['userId'] == _currentUser!.userId,
              orElse: () => <String, dynamic>{},
            );
            
            if (matchUser.isNotEmpty) {
              Map<String, dynamic>? assignment;
              if (matchUser.containsKey('assignment') && matchUser['assignment'] != null) {
                assignment = matchUser['assignment'];
              } else if (matchUser.containsKey('positionHolder') && matchUser['positionHolder'] != null) {
                final ph = matchUser['positionHolder'];
                if (ph is Map && ph.containsKey('assignment') && ph['assignment'] != null) {
                  assignment = ph['assignment'];
                }
              }
              
              if (assignment != null && assignment['talukaId'] != null) {
                _talukaId = assignment['talukaId'].toString();
                debugPrint('DEV DEBUG [AssemblyLeaderboard] - Successfully resolved _talukaId from RoleAPI: $_talukaId');
              } else {
                debugPrint('DEV DEBUG [AssemblyLeaderboard] - RoleAPI returned user, but NO talukaId found in assignment! User: $matchUser');
              }
            } else {
              debugPrint('DEV DEBUG [AssemblyLeaderboard] - User not found in RoleAPI!');
            }
          } else {
             debugPrint('DEV DEBUG [AssemblyLeaderboard] - RoleAPI failed or returned null');
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching role: $e");
    }

    if (_talukaId.isNotEmpty) {
      setState(() {
        _leaderboardFuture = ScorecardApi().getTalukaLeaderboard(_talukaId);
      });
    } else {
      setState(() {
        _leaderboardFuture = Future.error("Could not determine Assigned Area for President.");
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.assemblyName.trim().isNotEmpty ? '${widget.assemblyName} Leaderboard' : 'Leaderboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: FutureBuilder<dynamic>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (_leaderboardFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final response = snapshot.data;
          if (response == null) {
            return const Center(child: Text("Failed to load leaderboard"));
          }

          if (response is! TalukaLeaderboardResponse) {
             return Center(child: Text(response['message']?.toString() ?? "Failed to load leaderboard"));
          }

          if (response.success != true || response.data == null) {
            return Center(child: Text(response.message ?? "Failed to load leaderboard"));
          }

          final data = response.data!;

          return Column(
            children: [
              Container(
                color: theme.primaryColor.withValues(alpha: 0.1),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.primaryColor,
                  tabs: const [
                    Tab(text: "Overall"),
                    Tab(text: "Area Based"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverallTab(data),
                    _buildWardBasedTab(data.wardLeaderboard),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallTab(TalukaLeaderboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.talukaName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(widget.assemblyName.trim().isNotEmpty ? "${widget.assemblyName} Summary" : "Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem("Areas", "${data.summary.totalWards}"),
                      _buildSummaryItem("Members", "${data.summary.totalUsers}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem("Business Passed", data.summary.formattedBusinessPassed ?? "?0", isLarge: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (data.topWard != null) ...[
            const Text(
              "Top Performing Area",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWardCard(data.topWard!, isExpanded: true),
          ]
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWardBasedTab(List<TalukaWardLeaderboard> wards) {
    if (wards.isEmpty) {
      return const Center(child: Text("No area data available"));
    }

    return PageView.builder(
      itemCount: wards.length,
      itemBuilder: (context, index) {
        final ward = wards[index];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Area ${index + 1} of ${wards.length}",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildWardCard(ward, isExpanded: true),
              const SizedBox(height: 24),
              const Text(
                "Area Leaderboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (ward.memberLeaderboard.isNotEmpty)
                ...ward.memberLeaderboard.map((user) => _buildMemberTile(user))
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No members found in this area."),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWardCard(TalukaWardLeaderboard ward, {bool isExpanded = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                  child: Text(
                    "${ward.rank}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ward.wardName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ward.wardNumber,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${ward.totalScore} pts",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            if (isExpanded) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(Icons.people, "Users", "${ward.totalUsers}"),
                  _buildStatColumn(Icons.handshake, "F2F", "${ward.totalFaceToFace}"),
                  _buildStatColumn(Icons.person_add, "Guests", "${ward.totalGuests}"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(Icons.leaderboard, "Leads", "${ward.totalLeads}"),
                  _buildStatColumn(Icons.event_available, "Attended", "${ward.attendance.attended}"),
                  _buildStatColumn(Icons.currency_rupee, "Business", ward.formattedBusinessPassed ?? "?0"),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMemberTile(LeaderboardUser member) {
    Widget avatar;
    if (member.profileImage == null || member.profileImage!.isEmpty) {
      avatar = CircleAvatar(child: Text(member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : '?'));
    } else if (member.profileImage!.startsWith('data:')) {
      avatar = CircleAvatar(
        backgroundImage: MemoryImage(base64Decode(member.profileImage!.split(',').last)),
      );
    } else {
      avatar = ClipOval(
        child: Image.network(
          member.profileImage!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            child: Text(member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : '?'),
          ),
        ),
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(member.name),
      subtitle: Text(
        "F2F: ${member.faceToFace} | Leads: ${member.leads} | Business: ?${member.businessPassed}",
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          "${member.score}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
      ),
    );
  }
}


