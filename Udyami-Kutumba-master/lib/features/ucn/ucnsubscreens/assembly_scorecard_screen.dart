import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api/ubn/scorecard_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/location/location_api.dart';
import '../../../core/api/role/role_api.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/assembly_scorecard_model.dart';
import '../../../../core/utils/session_manager.dart';

class AssemblyScorecardScreen extends StatefulWidget {
  const AssemblyScorecardScreen({super.key, this.assemblyName = 'Assembly'});
  final String assemblyName;

  @override
  State<AssemblyScorecardScreen> createState() => _AssemblyScorecardScreenState();
}

class _AssemblyScorecardScreenState extends State<AssemblyScorecardScreen> {
  Future<AssemblyScorecardResponse?>? _scorecardFuture;
  String _assemblyId = '';
  bool _isLoadingRole = true;
  String _roleError = '';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchRoleAndAssemblyId();
  }

  Future<void> _fetchRoleAndAssemblyId() async {
    final userData = SessionManager.user;
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
    }
    
    if (_currentUser == null) {
      setState(() {
        _roleError = "User session not found.";
        _isLoadingRole = false;
      });
      return;
    }

    try {
      final roleWithTaluka = _currentUser!.roles.firstWhere(
        (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      
      if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
        _assemblyId = roleWithTaluka.talukaId!;
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
                      _assemblyId = matchTaluka['talukaId']?.toString() ?? '';
                      if (_assemblyId.isNotEmpty) {
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
                        _assemblyId = tMatch['talukaId']?.toString() ?? '';
                        if (_assemblyId.isNotEmpty) {
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

        if (_assemblyId.isEmpty) {
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
                _assemblyId = assignment['talukaId'].toString();
                debugPrint('DEV DEBUG [AssemblyScorecard] - Successfully resolved _assemblyId from RoleAPI: $_assemblyId');
              } else {
                debugPrint('DEV DEBUG [AssemblyScorecard] - RoleAPI returned user, but NO talukaId found in assignment! User: $matchUser');
              }
            } else {
              debugPrint('DEV DEBUG [AssemblyScorecard] - User not found in RoleAPI!');
            }
          } else {
             debugPrint('DEV DEBUG [AssemblyScorecard] - RoleAPI failed or returned null');
          }
        }
      }
    } catch (e) {
      _roleError = e.toString();
    }

    setState(() {
      _isLoadingRole = false;
    });

    if (_assemblyId.isNotEmpty) {
      setState(() {
        _scorecardFuture = ScorecardApi().getAssemblyScoreCard(_assemblyId);
      });
    } else {
      if (_roleError.isEmpty) {
        setState(() {
          _roleError = "Assembly ID not found for current user role.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.assemblyName.trim().isNotEmpty ? '${widget.assemblyName} Scorecard' : 'Scorecard',
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
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoadingRole) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_roleError.isNotEmpty && _assemblyId.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Error: $_roleError\nPlease ensure you have an Assembly role assigned.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return FutureBuilder<AssemblyScorecardResponse?>(
      future: _scorecardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final response = snapshot.data;
        if (response == null || response.success != true || response.data == null) {
          return Center(child: Text(response?.message ?? "Failed to load assembly scorecard"));
        }

        final data = response.data!;
        
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: theme.primaryColor.withValues(alpha: 0.1),
                child: TabBar(
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
                  children: [
                    _buildOverallTab(data),
                    _buildWardBasedTab(data.wards ?? []),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallTab(AssemblyScorecardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.assemblyName ?? "Area",
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
                      _buildSummaryItem("Areas", "${data.summary?.totalWards ?? 0}"),
                      _buildSummaryItem("Members", "${data.summary?.totalUsers ?? 0}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem("Business Passed", data.summary?.formattedBusinessPassed ?? "?0", isLarge: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (data.score != null) ...[
            const Text(
              "Overall Score",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem("Total", "${data.score?.total ?? 0}"),
                    _buildSummaryItem("Max", "${data.score?.max ?? 0}"),
                    _buildSummaryItem("Level", data.score?.level ?? "-"),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildWardBasedTab(List<AssemblyWardInfo> wards) {
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
                "Area Scorecard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (ward.users != null && ward.users!.isNotEmpty)
                ...ward.users!.map((user) => _buildMemberTile(user))
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

  Widget _buildWardCard(AssemblyWardInfo ward, {bool isExpanded = false}) {
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
                    "${ward.rank ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ward.wardName ?? "Unknown Area",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ward.wardNumber ?? "",
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
                    "${ward.score?.total ?? 0} pts",
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
                  _buildStatColumn(Icons.people, "Users", "${ward.totalUsers ?? 0}"),
                  _buildStatColumn(Icons.handshake, "F2F", "${ward.statistics?.totalFaceToFace ?? 0}"),
                  _buildStatColumn(Icons.person_add, "Guests", "${ward.statistics?.totalGuests ?? 0}"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(Icons.leaderboard, "Leads", "${ward.statistics?.totalLeads ?? 0}"),
                  _buildStatColumn(Icons.event_available, "Attended", "${ward.statistics?.attendance?.achieved ?? 0}"),
                  _buildStatColumn(Icons.currency_rupee, "Business", ward.statistics?.formattedBusinessPassed ?? "?0"),
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

  Widget _buildMemberTile(AssemblyUserInfo member) {
    Widget avatar;
    if (member.profileImage == null || member.profileImage!.isEmpty) {
      avatar = CircleAvatar(child: Text(member.name?.isNotEmpty == true ? member.name!.substring(0, 1).toUpperCase() : "U"));
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
            child: Text(member.name?.isNotEmpty == true ? member.name!.substring(0, 1).toUpperCase() : "U"),
          ),
        ),
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(member.name ?? "Unknown"),
      subtitle: Text(
        "F2F: ${member.faceToFace?.achieved ?? 0} | Leads: ${member.leads?.achieved ?? 0} | Business: ${member.gratitudeSlips?.formattedValue ?? '?0'}",
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          "${member.score?.total ?? 0}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
      ),
    );
  }
}


