import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/auth/auth_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/role/role_api.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/ubn/udyami_member_api.dart';
import '../../../core/api/ubn/udyamimngt_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/session_manager.dart';

class CircleRolesScreen extends StatefulWidget {
  const CircleRolesScreen({super.key});

  @override
  State<CircleRolesScreen> createState() => _CircleRolesScreenState();
}

class _CircleRolesScreenState extends State<CircleRolesScreen> {
  bool _isLoading = false;
  List<UserModel> _members = [];
  List<UserModel> _wardMembers = [];
  UserModel? _currentUser;
  bool _isPresident = false;
  String _wardId = '';
  List<dynamic> _designations = [];
  List<dynamic> _assignedDesignations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userData = SessionManager.user;
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);

      print('DEV DEBUG - CircleRolesScreen: Current user roles:');
      for (var r in _currentUser!.roles) {
        print(
          ' - ID: ${r.roleId}, roleName: ${r.roleName}, role: ${r.role}, wardId: ${r.wardId}',
        );
      }

      // Determine if current user is a President
      _isPresident = _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? ''))
            .toLowerCase();
        return (rName.contains('president') ||
                rName.contains('circle_leader') ||
                rName.contains('chairman') ||
                rName.contains('head')) &&
            !rName.contains('vice');
      });
      print(
        'DEV DEBUG - CircleRolesScreen: _isPresident evaluated to: $_isPresident',
      );
    }

    try {
      if (_currentUser != null) {
        // Prioritize wardId from the user's role assignment
        final roleWithWard = _currentUser!.roles.firstWhere(
          (r) => r.wardId != null && r.wardId!.isNotEmpty,
          orElse: () => RoleModel(roleId: 0, roleName: ''),
        );
        if (roleWithWard.wardId != null && roleWithWard.wardId!.isNotEmpty) {
          _wardId = roleWithWard.wardId!;
        } else {
          try {
            // Get user's profile to find their ward name
            final profileRes = await ProfileAPI().getUserProfileById(
              _currentUser!.userId,
            );
            if (profileRes != null && profileRes['success'] == true) {
              final wardName = profileRes['data']?['profile']?['ward'];
              if (wardName != null && wardName.toString().isNotEmpty) {
                final allWardsRes = await WardAPI().getAllWards(wardName: wardName.toString());
                if (allWardsRes != null && allWardsRes['success'] == true) {
                  final List wards = allWardsRes['data'] ?? [];
                  if (wards.isNotEmpty) {
                    _wardId = wards[0]['wardId'];
                  }
                }
              }
            }
          } catch (e) {
            print(
              'DEV DEBUG - CircleRolesScreen: Failed to dynamically fetch ward ID: $e',
            );
          }
        }
      }

      if (_wardId.isEmpty) {
        _wardId =
            "726ca4fc-f1f5-4fa7-a276-fed0904245ad"; // Fallback provided in JSON
      }
      print(
        'DEV DEBUG - CircleRolesScreen: Fetching ALL members (no ward blocking)',
      );

      final res = await AuthAPI().getAllUsers();
      if (res != null) {
        List data = [];
        if (res is Map && res['success'] == true && res.containsKey('data')) {
          data = res['data'] ?? [];
        } else if (res is Map && res.containsKey('membershipUsers')) {
          data = res['membershipUsers'] ?? [];
        } else if (res is List) {
          data = res;
        }

        _members = data.map((e) => UserModel.fromJson(e)).toList();
        print(
          'DEV DEBUG - CircleRolesScreen: Fetched ${_members.length} members globally.',
        );
      }

      print('DEV DEBUG - CircleRolesScreen: Fetching members for ward: $_wardId for accurate top mappings');
      final wardRes = await AuthAPI().getUcnMembers(_wardId);
      if (wardRes != null && wardRes['success'] == true) {
        final List data = wardRes['data'] ?? [];
        _wardMembers = data.map((e) => UserModel.fromJson(e)).toList();
        print('DEV DEBUG - CircleRolesScreen: Fetched ${_wardMembers.length} members for this ward.');
      }

      // Fetch dynamic designations
      try {
        final desigRes = await UdyamimngtAPI().getAllDesignations();
        if (desigRes != null) {
          print(
            'DEV DEBUG - CircleRolesScreen: Designations fetched: $desigRes',
          );
          if (desigRes is Map &&
              desigRes['success'] == true &&
              desigRes.containsKey('data')) {
            _designations = desigRes['data'] ?? [];
          } else if (desigRes is List) {
            _designations = desigRes;
          } else if (desigRes is Map && desigRes.containsKey('designations')) {
            _designations = desigRes['designations'];
          }
        }
      } catch (e) {
        print(
          'DEV DEBUG - CircleRolesScreen: Failed to fetch designations: $e',
        );
      }

      // Fetch assigned designations
      try {
        final assignedRes = await UdyamimngtAPI().getMngtMembers(_wardId);
        if (assignedRes != null && assignedRes['success'] == true) {
          _assignedDesignations = assignedRes['data'] ?? [];
        }
      } catch (e) {
        print(
          'DEV DEBUG - CircleRolesScreen: Failed to fetch assigned designations: $e',
        );
      }
    } catch (e) {
      print("DEV DEBUG - Error in _loadData: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showAssignRoleSheet(String roleTitle, dynamic roleId, String type, {String? oldUserId}) {
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            final filteredMembers = _members.where((m) {
              return m.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  m.email.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          "Assign $roleTitle",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search members by name or email...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setStateSheet(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredMembers.isEmpty
                        ? const Center(child: Text("No UCN members found."))
                        : ListView.builder(
                            itemCount: filteredMembers.length,
                            itemBuilder: (context, index) {
                              final member = filteredMembers[index];
                              final String initials = member.name.isNotEmpty ? (member.name.split(' ').length > 1 ? '${member.name.split(' ')[0][0]}${member.name.split(' ')[1][0]}'.toUpperCase() : member.name[0].toUpperCase()) : '?';
                              final bool isPrime = member.isPrime ?? false;
                              final MaterialColor avatarColor = Colors.teal;

                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  if (roleTitle == "Office Bearer") {
                                    _assignRole(
                                      member,
                                      roleId is int ? roleId : int.tryParse(roleId.toString()) ?? 0,
                                      type,
                                      roleTitle,
                                    );
                                  } else {
                                    _assignDesignation(
                                      member,
                                      roleId.toString(),
                                      type,
                                      roleTitle,
                                      oldUserId,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              if (member.profileImage == null || member.profileImage!.isEmpty) {
                                                return CircleAvatar(radius: 20, backgroundColor: avatarColor.shade50, child: Text(initials, style: TextStyle(color: avatarColor.shade900, fontWeight: FontWeight.bold)));
                                              } else if (member.profileImage!.startsWith('data:')) {
                                                return CircleAvatar(radius: 20, backgroundImage: MemoryImage(base64Decode(member.profileImage!.split(',').last)));
                                              } else {
                                                return ClipOval(
                                                  child: Image.network(
                                                    member.profileImage!,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => CircleAvatar(radius: 20, backgroundColor: avatarColor.shade50, child: Text(initials, style: TextStyle(color: avatarColor.shade900, fontWeight: FontWeight.bold))),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          if (isPrime)
                                            Positioned(
                                              bottom: -4,
                                              right: -4,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.amber,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.star, color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : theme.colorScheme.surface, size: 10),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text(member.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                            if (member.roles.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  member.roles.map((r) => r.roleName.isNotEmpty ? r.roleName : r.role).join(', '),
                                                  style: TextStyle(
                                                    color: avatarColor.shade700,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios, color: Colors.grey.shade300, size: 14),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _assignRole(
    UserModel selectedMember,
    int roleId,
    String type,
    String roleTitle,
  ) async {
    setState(() => _isLoading = true);
    try {
      final payload = {
        "userId": selectedMember.userId,
        "roleId": roleId,
        "type": type,
        "circleLeaderId": _currentUser?.userId ?? '',
        "wardId": _wardId,
      };

      final res = await RoleAPI().assignRole(payload);
      if (res != null && res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$roleTitle assigned successfully!")),
          );
        }
        await _loadData();
      } else {
        final msg = res?['message'] ?? 'Failed to assign role';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _assignDesignation(
    UserModel selectedMember,
    String designationId,
    String type,
    String title,
    String? oldUserId,
  ) async {
    setState(() => _isLoading = true);
    try {
      dynamic res;
      if (oldUserId != null && oldUserId != selectedMember.userId) {
        final payload = {
          "designationId": designationId,
          "wardId": _wardId,
          "oldUserId": oldUserId,
          "newUserId": selectedMember.userId,
          "circleLeaderId": _currentUser?.userId ?? '',
        };
        res = await UdyamimngtAPI().replaceDesignationHolder(payload);
      } else {
        final payload = {
          "userId": selectedMember.userId,
          "designationId": designationId,
          "type": type,
          "circleLeaderId": _currentUser?.userId ?? '',
          "wardId": _wardId,
        };
        res = await UdyamimngtAPI().assignDesignation(payload);
      }

      if (res != null && res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title assigned successfully!")),
          );
        }
        await _loadData();
      } else {
        final msg = res?['message'] ?? 'Failed to assign designation';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // We'll define the assignable roles structure here
  final List<Map<String, dynamic>> _officeBearers = [
    {"title": "Vice President", "roleId": 11, "type": "vice_president"},
    {"title": "General Secretary", "roleId": 12, "type": "general_secretary"},
    {"title": "Treasurer", "roleId": 13, "type": "treasurer"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Helpers to find members dynamically based on the role types above
    UserModel? findMemberByRole(String typeSubstring) {
      final withoutUnderscore = typeSubstring.replaceAll('_', ' ');
      return _wardMembers
          .where(
            (m) => m.roles.any((r) {
              final n = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? ''))
                  .toLowerCase();
              return n.contains(typeSubstring) || n.contains(withoutUnderscore);
            }),
          )
          .firstOrNull;
    }

    UserModel? findAssigneeForDesignation(dynamic designationId) {
      if (designationId == null) return null;
      final String idStr = designationId.toString();
      
      final matchingAssignments = _assignedDesignations.where((assignment) {
        final desig = assignment['designation'];
        return desig != null &&
            (desig['designationId']?.toString() == idStr ||
                desig['id']?.toString() == idStr);
      }).toList();

      if (matchingAssignments.isEmpty) return null;

      matchingAssignments.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); // descending
      });

      var latestAssignment = matchingAssignments.firstWhere(
        (a) => a['isCurrent'] == true || (a['holder'] != null && a['holder']['isCurrent'] == true),
        orElse: () => matchingAssignments.first,
      );

      final holder = latestAssignment['holder'];
      if (holder != null) {
        final user = holder['user'];
        if (user != null) {
          return UserModel.fromJson({
            'userId': user['userId'],
            'name': user['name'],
            'email': user['email'],
            'mobileNumber': user['mobileNumber'],
            'roles': [],
            'profile': user['profile'],
          });
        }
      }
      return null;
    }

    final chairman = findMemberByRole('chairman');
    final president = _wardMembers
        .where(
          (m) => m.roles.any((r) {
            final n = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? ''))
                .toLowerCase();
            return (n.contains('president') || n.contains('circle_leader')) &&
                !n.contains('vice');
          }),
        )
        .firstOrNull;

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
          "Circle roles",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Office bearers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildRoleRow(
                    context,
                    "Chairman",
                    chairman,
                    null,
                    icon: Icons.lock_rounded,
                    isUnassigned: chairman == null,
                  ),
                  _buildRoleRow(
                    context,
                    "President",
                    president,
                    null,
                    icon: Icons.lock_rounded,
                    isUnassigned: president == null,
                  ),

                  // Dynamically map through the assignable roles structure
                  ..._officeBearers.map((roleDef) {
                    final assignee = findMemberByRole(roleDef['type']);
                    return _buildRoleRow(
                      context,
                      roleDef['title'],
                      assignee,
                      _isPresident
                          ? (assignee == null ? "Assign" : "Change")
                          : null,
                      badgeColor: roleDef['title'] == 'Treasurer'
                          ? Colors.orange
                          : Colors.indigo,
                      isUnassigned: assignee == null,
                      onTap: _isPresident
                          ? () => _showAssignRoleSheet(
                              "Office Bearer",
                              roleDef['roleId'],
                              roleDef['type'],
                            )
                          : null,
                    );
                  }),

                  const SizedBox(height: 24),

                  const Text(
                    "Designations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_designations.isEmpty)
                    const Center(child: Text("No designations available."))
                  else
                    ..._designations.map((d) {
                      final title =
                          d['designationName'] ??
                          d['name'] ??
                          d['title'] ??
                          'Unknown Role';
                      final type =
                          d['type'] ??
                          d['designationType'] ??
                          title.toString().toLowerCase().replaceAll(' ', '_');
                      final roleId =
                          d['id'] ?? d['designationId'] ?? d['roleId'] ?? 0;

                      final assignee =
                          findAssigneeForDesignation(roleId) ??
                          findMemberByRole(type);

                      return _buildRoleRow(
                        context,
                        title,
                        assignee,
                        _isPresident
                            ? (assignee == null ? "Assign" : "Change")
                            : null,
                        badgeColor: Colors.indigo,
                        isUnassigned: assignee == null,
                        onTap: _isPresident
                            ? () => _showAssignRoleSheet(title, roleId, type, oldUserId: assignee?.userId)
                            : null,
                      );
                    }),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      "Networking posts from the G5 Malleshwaram org chart · open tools in Coordinators",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleRow(
    BuildContext context,
    String role,
    UserModel? assignedUser,
    String? badgeText, {
    MaterialColor? badgeColor,
    IconData? icon,
    bool isUnassigned = false,
    VoidCallback? onTap,
    String? fallbackName,
  }) {
    final assigneeName = assignedUser?.name ?? fallbackName ?? "Unassigned";

    Widget content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isUnassigned
            ? Colors.orange.shade50
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.white),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
        boxShadow: [
          if (!isUnassigned)
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          if (assignedUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Builder(
                builder: (context) {
                  if (assignedUser.profileImage == null || assignedUser.profileImage!.isEmpty) {
                    return CircleAvatar(radius: 20, backgroundColor: Colors.teal.shade50, child: Text(assigneeName.isNotEmpty ? assigneeName[0].toUpperCase() : '?', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)));
                  } else if (assignedUser.profileImage!.startsWith('data:')) {
                    return CircleAvatar(radius: 20, backgroundImage: MemoryImage(base64Decode(assignedUser.profileImage!.split(',').last)));
                  } else {
                    return ClipOval(
                      child: Image.network(
                        assignedUser.profileImage!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => CircleAvatar(radius: 20, backgroundColor: Colors.teal.shade50, child: Text(assigneeName.isNotEmpty ? assigneeName[0].toUpperCase() : '?', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold))),
                      ),
                    );
                  }
                },
              ),
            )
          else if (isUnassigned)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  Icons.person_outline,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isUnassigned
                        ? Colors.orange.shade900
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assigneeName,
                  style: TextStyle(
                    color: isUnassigned
                        ? Colors.orange.shade800
                        : Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (icon != null && !isUnassigned && assignedUser == null)
            Icon(icon, color: Colors.grey.shade400, size: 20),
          if (badgeText != null && badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: content,
      );
    }
    return content;
  }
}
