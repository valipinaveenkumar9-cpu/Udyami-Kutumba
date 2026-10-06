import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'meeting_detail_screen.dart';
import 'circle_meeting_agenda_screen.dart';
import 'new_meeting_screen.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/api/ubn/scorecard_api.dart';
import '../../../core/models/taluka_leaderboard_model.dart';
import '../../../core/models/meeting_model.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/models/user_model.dart';
import '../../../core/api/role/role_api.dart' as import_role_api;
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/location/location_api.dart';

class MeetingsScreen extends StatefulWidget {
  final String userRole;
  const MeetingsScreen({super.key, required this.userRole});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final MeetingAPI _meetingAPI = MeetingAPI();
  bool _isLoading = true;

  bool _isAssemblyRole = false;
  bool _isWardRole = false;

  List<MeetingModel> _assemblyMeetings = [];
  List<MeetingModel> _wardMeetings = [];
  List<MeetingModel> _allMeetings = []; // For normal users

  List<TalukaWardLeaderboard>? _wardsList;
  Map<String, List<MeetingModel>> _wardMeetingsMap =
      {}; // Cache for Assembly role ward meetings
  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    setState(() {
      _isLoading = true;
      _assemblyMeetings.clear();
      _wardMeetings.clear();
      _allMeetings.clear();
      _wardsList = null;
      _wardMeetingsMap.clear();
    });

    final user = SessionManager.user;
    if (user == null || user['userId'] == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final String userId = user['userId'].toString();
    final String roleLower = widget.userRole.toLowerCase();

    _isAssemblyRole = roleLower.contains('assembly');
    _isWardRole =
        roleLower.contains('ward') ||
        roleLower.contains('area') ||
        roleLower.contains('circle leader') ||
        roleLower.contains('sector head');

    String? tId;
    String? wId;
    final currentUser = UserModel.fromJson(user);

    // Attempt to extract IDs from roles
    try {
      final roleWithWard = currentUser.roles.firstWhere(
        (r) => r.wardId != null && r.wardId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      if (roleWithWard.wardId != null && roleWithWard.wardId!.isNotEmpty) {
        wId = roleWithWard.wardId;
        tId = roleWithWard.talukaId;
      }

      final roleWithTaluka = currentUser.roles.firstWhere(
        (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      if (roleWithTaluka.talukaId != null &&
          roleWithTaluka.talukaId!.isNotEmpty) {
        if (tId == null) tId = roleWithTaluka.talukaId;
      }
    } catch (_) {}

    // Fallback to RoleAPI if needed
    if (tId == null || (_isWardRole && wId == null)) {
      try {
        final rolesRes = await import_role_api.RoleAPI().getAllRoleUsers();
        if (rolesRes != null && rolesRes['success'] == true) {
          final List rawRoleUsers = rolesRes['data'] ?? [];
          final matchUser = rawRoleUsers
              .cast<Map<String, dynamic>>()
              .firstWhere((u) => u['userId'] == userId, orElse: () => {});
          if (matchUser.isNotEmpty) {
            Map<String, dynamic>? assignment;
            if (matchUser.containsKey('assignment') &&
                matchUser['assignment'] != null) {
              assignment = matchUser['assignment'];
            } else if (matchUser.containsKey('positionHolder') &&
                matchUser['positionHolder'] != null) {
              final ph = matchUser['positionHolder'];
              if (ph is Map &&
                  ph.containsKey('assignment') &&
                  ph['assignment'] != null) {
                assignment = ph['assignment'] as Map<String, dynamic>;
              }
            }

            if (assignment != null) {
              if (wId == null && assignment['wardId'] != null)
                wId = assignment['wardId'].toString();
              if (tId == null && assignment['talukaId'] != null)
                tId = assignment['talukaId'].toString();
            }
          }
        }
      } catch (e) {
        print("DEV DEBUG - Fallback parsing failed: $e");
      }
    }

    // ULTIMATE FALLBACK FOR TALUKA ID (especially for Assembly President without proper assignment)
    if (tId == null && (_isAssemblyRole || _isWardRole)) {
      tId = await _resolveTalukaId(userId);
    }

    print(
      "DEV DEBUG - _fetchMeetings - Final Extracted -> tId: $tId, wId: $wId, _isAssemblyRole: $_isAssemblyRole, _isWardRole: $_isWardRole",
    );

    if (_isAssemblyRole) {
      // ASSEMBLY ROLE
      if (tId != null && tId.isNotEmpty) {
        // Fetch Assembly Meetings
        final rAssm = await _meetingAPI.getAllAssemblyMeetings(tId!);
        if (rAssm != null && rAssm['success'] == true) {
          _assemblyMeetings = (rAssm['data'] as List)
              .map((m) => MeetingModel.fromJson(m))
              .toList();
        }

        // Fetch Wards List for swipeable view
        try {
          final lbRes = await ScorecardApi().getTalukaLeaderboard(tId!);
          if (lbRes != null && lbRes.success && lbRes.data != null) {
            _wardsList = lbRes.data!.wardLeaderboard;

            // Pre-fetch meetings for each ward so the swipeable tabs are instantly loaded
            for (var ward in _wardsList!) {
              final wRes = await _meetingAPI.getAllWardMeetings(ward.wardId);
              if (wRes != null && wRes['success'] == true) {
                _wardMeetingsMap[ward.wardId] = (wRes['data'] as List)
                    .map((m) => MeetingModel.fromJson(m))
                    .toList();
              } else {
                _wardMeetingsMap[ward.wardId] = [];
              }
            }
          }
        } catch (_) {}
      } else {
        // Fallback for test user without proper talukaId
        final resAll = await _meetingAPI.getAllMeetings();
        if (resAll != null && resAll is List) {
          _assemblyMeetings = resAll
              .map((m) => MeetingModel.fromJson(m))
              .toList();
        }
      }
    } else if (_isWardRole) {
      // WARD / AREA ROLE
      if (tId != null && tId.isNotEmpty) {
        final rAssm = await _meetingAPI.getAllAssemblyMeetings(tId!);
        if (rAssm != null && rAssm['success'] == true) {
          _assemblyMeetings = (rAssm['data'] as List)
              .map((m) => MeetingModel.fromJson(m))
              .toList();
        }
      }
      if (wId != null && wId.isNotEmpty) {
        final rWard = await _meetingAPI.getAllWardMeetings(wId!);
        if (rWard != null && rWard['success'] == true) {
          _wardMeetings = (rWard['data'] as List)
              .map((m) => MeetingModel.fromJson(m))
              .toList();
        }
      }
    } else {
      // NORMAL USER
      final resAll = await _meetingAPI.getAllMeetings();
      if (resAll != null && resAll is List) {
        _allMeetings = resAll.map((m) => MeetingModel.fromJson(m)).toList();
        // Basic filtering logic for normal members
        _allMeetings = _allMeetings
            .where(
              (m) =>
                  m.talukaId == null && (m.wardId == null || m.wardId!.isEmpty),
            )
            .toList();
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('EEE d MMM · h:mm a').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Circle Meetings",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton:
          (widget.userRole == 'Circle Leader' ||
              widget.userRole == 'Sector Head' ||
              widget.userRole == 'Assembly President')
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90.0, right: 65.0),
              child: FloatingActionButton(
                heroTag: 'meetings_fab',
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewMeetingScreen()),
                  );
                  if (result == true) {
                    _fetchMeetings();
                  }
                },
                child: Icon(Icons.add),
              ),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_isAssemblyRole || _isWardRole)
          ? DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: "Assembly Meetings"),
                      Tab(text: "Area Meetings"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Assembly Meetings
                        _buildMeetingList(_assemblyMeetings, isDark),

                        // Tab 2: Area Meetings
                        _isAssemblyRole
                            ? _buildAssemblySwipeableWardList(isDark, theme)
                            : _buildMeetingList(_wardMeetings, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _buildMeetingList(_allMeetings, isDark),
    );
  }

  Widget _buildAssemblySwipeableWardList(bool isDark, ThemeData theme) {
    if (_wardsList == null || _wardsList!.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchMeetings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Text("No Wards found for this Assembly"),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: _wardsList!.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabAlignment: TabAlignment.start,
            tabs: _wardsList!.map((w) => Tab(text: w.wardName)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _wardsList!.map((ward) {
                final wMeetings = _wardMeetingsMap[ward.wardId] ?? [];
                return _buildMeetingList(wMeetings, isDark);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingList(List<MeetingModel> meetings, bool isDark) {
    print("DEV DEBUG - _buildMeetingList received ${meetings.length} meetings");
    for (var m in meetings) {
      print("DEV DEBUG - Meeting ID: ${m.meetingId}, Status: '${m.status}' (Length: ${m.status.length})");
    }
    final upcomingMeetings = meetings
        .where((m) => m.status.toLowerCase().trim() == 'scheduled' || m.status.toLowerCase().trim() == 'started')
        .toList();
    final pastMeetings = meetings
        .where((m) => m.status.toLowerCase().trim() == 'completed' || m.status.toLowerCase().trim() == 'ended')
        .toList();
    print("DEV DEBUG - upcomingMeetings count: ${upcomingMeetings.length}");
    print("DEV DEBUG - pastMeetings count: ${pastMeetings.length}");

    return RefreshIndicator(
      onRefresh: _fetchMeetings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upcoming",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            if (upcomingMeetings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No upcoming meetings",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...upcomingMeetings.map(
                (meeting) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _meetingCard(
                    icon: Icons.calendar_month,
                    iconColor: Colors.orange,
                    title: meeting.agenda.isNotEmpty
                        ? meeting.agenda
                        : "Circle Meeting",
                    subtitle: "${_formatDate(meeting.date)} · ${meeting.venue}",
                    badgeText: meeting.status,
                    badgeColor: meeting.status == 'Started' ? Colors.green : Colors.orange,
                    actionButton: (() {
                      final currentUser = SessionManager.user;
                      final currentUserId = currentUser?['userId']?.toString();
                      final creatorId = meeting.createdUser?['userId']?.toString();

                      bool isManager = false;
                      if (currentUserId != null && creatorId != null && currentUserId == creatorId) {
                        isManager = true;
                      } else if (_isAssemblyRole && meeting.talukaId != null && (meeting.wardId == null || meeting.wardId!.isEmpty)) {
                        isManager = true;
                      } else if (_isWardRole && meeting.wardId != null && meeting.wardId!.isNotEmpty && widget.userRole.toLowerCase().contains('circle leader')) {
                        isManager = true;
                      }

                      return isManager ? ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MeetingDetailScreen(type: 'Circle', meeting: meeting)),
                            );
                            if (result == true) {
                              _fetchMeetings();
                            }
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: meeting.status == 'Started' ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(meeting.status == 'Started' ? 'End Meeting' : 'Start Meeting'),
                      ) : null;
                    })(),
                    onTap: () async {
                      final currentUser = SessionManager.user;
                      final currentUserId = currentUser?['userId']?.toString();
                      final creatorId = meeting.createdUser?['userId']
                          ?.toString();

                      bool isManager = false;
                      // If I created it, I manage it
                      if (currentUserId != null &&
                          creatorId != null &&
                          currentUserId == creatorId) {
                        isManager = true;
                      }
                      // Otherwise, check role scopes
                      else if (_isAssemblyRole &&
                          meeting.talukaId != null &&
                          (meeting.wardId == null || meeting.wardId!.isEmpty)) {
                        // Assembly President manages Assembly Meetings
                        isManager = true;
                      } else if (_isWardRole &&
                          meeting.wardId != null &&
                          meeting.wardId!.isNotEmpty &&
                          widget.userRole.toLowerCase().contains(
                            'circle leader',
                          )) {
                        // Circle Leader manages Ward Meetings
                        isManager = true;
                      }

                      if (isManager) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MeetingDetailScreen(type: 'Circle', meeting: meeting),
                          ),
                        );
                        if (result == true) {
                          _fetchMeetings();
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MeetingDetailScreen(
                              type: 'Circle',
                              meeting: meeting,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            const SizedBox(height: 25),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 20),
            Text(
              "Past",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            if (pastMeetings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No past meetings",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...pastMeetings.map(
                (meeting) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _meetingCard(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: meeting.agenda.isNotEmpty
                        ? meeting.agenda
                        : "Circle Meeting",
                    subtitle: "${_formatDate(meeting.date)} · ${meeting.venue}",
                    badgeText: "Completed",
                    badgeColor: Colors.green,
                    actionButton: ElevatedButton(
                      onPressed: () {
                        if (meeting.summary != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MeetingDetailScreen(type: 'Circle', meeting: meeting)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MeetingDetailScreen(type: 'Circle', meeting: meeting)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Summary'),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _meetingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
    Widget? actionButton,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: iconColor.withOpacity(.15),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (actionButton != null) ...[
                    const SizedBox(height: 8),
                    actionButton,
                  ],
                ],
              ),
            ),
            if (actionButton == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _resolveTalukaId(String userId) async {
    try {
      final profileRes = await ProfileAPI().getUserProfileById(userId);
      if (profileRes != null && profileRes['success'] == true) {
        final profile = profileRes['data']?['profile'] ?? {};
        final districtName = profile['district']?.toString();
        final assemblyName =
            profile['assembly']?.toString() ?? profile['taluka']?.toString();

        if (districtName != null &&
            districtName.isNotEmpty &&
            assemblyName != null &&
            assemblyName.isNotEmpty) {
          final distApiRes = await LocationAPI().getAllDistricts();
          if (distApiRes != null && distApiRes['success'] == true) {
            final List rawDistricts = distApiRes['data'] ?? [];
            final matchDist = rawDistricts
                .cast<Map<String, dynamic>>()
                .firstWhere(
                  (d) =>
                      d['districtName']?.toString().toLowerCase() ==
                      districtName.toLowerCase(),
                  orElse: () => <String, dynamic>{},
                );

            if (matchDist.isNotEmpty) {
              final distId = matchDist['districtId']?.toString();
              if (distId != null) {
                final talukaApiRes = await LocationAPI().getAllDistricts(
                  districtId: distId,
                );
                if (talukaApiRes != null && talukaApiRes['success'] == true) {
                  final List rawTalukas = talukaApiRes['data'] ?? [];
                  final matchTaluka = rawTalukas
                      .cast<Map<String, dynamic>>()
                      .firstWhere(
                        (t) =>
                            t['talukaName']?.toString().toLowerCase() ==
                            assemblyName.toLowerCase(),
                        orElse: () => <String, dynamic>{},
                      );
                  if (matchTaluka.isNotEmpty) {
                    return matchTaluka['talukaId']?.toString();
                  }
                }
              }
            }

            // Search all districts
            for (var dist in rawDistricts) {
              final dId = dist['districtId']?.toString();
              if (dId != null) {
                final talukasRes = await LocationAPI().getAllDistricts(
                  districtId: dId,
                );
                if (talukasRes != null && talukasRes['success'] == true) {
                  final List tList = talukasRes['data'] ?? [];
                  final tMatch = tList.cast<Map<String, dynamic>>().firstWhere(
                    (t) =>
                        t['talukaName']?.toString().toLowerCase() ==
                        assemblyName.toLowerCase(),
                    orElse: () => <String, dynamic>{},
                  );
                  if (tMatch.isNotEmpty) {
                    return tMatch['talukaId']?.toString();
                  }
                }
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
