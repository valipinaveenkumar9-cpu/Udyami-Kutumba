import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'dart:convert';
import '../../../core/api/auth/auth_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/role/role_api.dart';
import '../../../core/api/area/taluka_api.dart';
import '../../../core/api/location/location_api.dart';
import '../../../core/api/ubn/meeting_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/session_manager.dart';

class AssemblyRolesScreen extends StatefulWidget {
  const AssemblyRolesScreen({super.key, this.assemblyName = 'Assembly'});
  final String assemblyName;

  @override
  State<AssemblyRolesScreen> createState() => _AssemblyRolesScreenState();
}

class _AssemblyRolesScreenState extends State<AssemblyRolesScreen> {
  bool _isLoading = false;
  List<UserModel> _members = [];
  UserModel? _currentUser;
  bool _isTalukaHead = false;
  bool _isAssemblyPresident = false;
  String _talukaId = '';
  List<dynamic> _assemblyLeadership = [];
  List<dynamic> _areaCircleLeadership = [];

  // Dynamic API state
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedTalukaId;
  String? _selectedTalukaName;

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

      bool isSuperAdmin = _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName == 'superadmin' || rName == 'super_admin' || rName == 'state_head';
      });

      _isTalukaHead = isSuperAdmin || _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('taluka_head') || rName.contains('taluk head') || rName.contains('taluka_president');
      }) || _currentUser!.name.toLowerCase().contains('taluk head');

      _isAssemblyPresident = isSuperAdmin || _currentUser!.roles.any((r) {
        final rName = (r.roleName.isNotEmpty ? r.roleName : (r.role ?? '')).toLowerCase();
        return rName.contains('assembly_head') || 
               rName.contains('assembly head') || 
               rName.contains('assembly_president') || 
               rName.contains('assembly president');
      }) || _currentUser!.name.toLowerCase().contains('assembly head') || _currentUser!.name.toLowerCase().contains('assembly president');

      // Try to auto-select taluka based on user roles
      final roleWithTaluka = _currentUser!.roles.firstWhere(
        (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
        orElse: () => RoleModel(roleId: 0, roleName: ''),
      );
      if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
        _talukaId = roleWithTaluka.talukaId!;
        _selectedTalukaId = _talukaId;
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
                orElse: () => {},
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
                      orElse: () => {},
                    );
                    
                    if (matchTaluka.isNotEmpty) {
                      _talukaId = matchTaluka['talukaId']?.toString() ?? '';
                      if (_talukaId.isNotEmpty) {
                        _selectedTalukaId = _talukaId;
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
                        orElse: () => {},
                      );
                      if (tMatch.isNotEmpty) {
                        _talukaId = tMatch['talukaId']?.toString() ?? '';
                        if (_talukaId.isNotEmpty) {
                          _selectedTalukaId = _talukaId;
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
              orElse: () => {},
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
                _selectedTalukaId = _talukaId;
                debugPrint('DEV DEBUG [AssemblyRoles] - Successfully resolved _talukaId from RoleAPI: $_talukaId');
              } else {
                debugPrint('DEV DEBUG [AssemblyRoles] - RoleAPI returned user, but NO talukaId found in assignment! User: $matchUser');
              }
            } else {
              debugPrint('DEV DEBUG [AssemblyRoles] - User not found in RoleAPI!');
            }
          } else {
             debugPrint('DEV DEBUG [AssemblyRoles] - RoleAPI failed or returned null');
          }
        }
      }
      debugPrint('DEV DEBUG [AssemblyRoles] - Final resolved _talukaId: "$_talukaId", _selectedDistrictId: "$_selectedDistrictId"');
    }

    try {
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
      }

      // Fetch all districts dynamically
      final distRes = await LocationAPI().getAllDistricts();
      if (distRes != null && distRes['success'] == true) {
        final List rawDistricts = distRes['data'] ?? [];
        _districts = rawDistricts.cast<Map<String, dynamic>>();
      }

      // If we auto-selected a talukaId from roles, fetch its leadership immediately
      if (_talukaId.isNotEmpty) {
        await _loadLeadership(_talukaId);
      }
    } catch (e) {
      // Ignored
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTalukas(String districtId) async {
    setState(() => _isLoading = true);
    try {
      final talukaRes = await LocationAPI().getAllDistricts(
        districtId: districtId,
      );
      if (talukaRes != null && talukaRes['success'] == true) {
        final List rawTalukas = talukaRes['data'] ?? [];
        _talukas = rawTalukas.cast<Map<String, dynamic>>();
        _selectedTalukaId = null;
        _selectedTalukaName = null;
        _talukaId = '';
        _assemblyLeadership = [];
      }
    } catch (e) {
      // Ignored
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadLeadership(String talukaId) async {
    setState(() => _isLoading = true);
    try {
      final res = await TalukaAPI().getAssemblyLeadership(talukaId);
      if (res != null && res['success'] == true) {
        _assemblyLeadership = res['data'] ?? [];
      } else {
        _assemblyLeadership = [];
      }

      // Fetch Area Circle Roles under Taluka
      final areaRes = await MeetingAPI().getAllWardPositionsUsers(talukaId);
      if (areaRes != null && areaRes['success'] == true) {
        _areaCircleLeadership = areaRes['data'] ?? [];
      } else {
        _areaCircleLeadership = [];
      }
    } catch (e) {
      debugPrint('Error loading leadership: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showAssignRoleSheet(String roleTitle, dynamic roleId, String type) {
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
                          "Assign \$roleTitle",
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
                              final String initials = member.name.isNotEmpty
                                  ? (member.name.split(' ').length > 1
                                        ? '\${member.name.split('
                                                  ')[0][0]}\${member.name.split('
                                                  ')[1][0]}'
                                              .toUpperCase()
                                        : member.name[0].toUpperCase())
                                  : '?';
                              final bool isPrime = member.isPrime ?? false;
                              final MaterialColor avatarColor = Colors.teal;

                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  _assignRole(
                                    member,
                                    roleId is int
                                        ? roleId
                                        : int.tryParse(roleId.toString()) ?? 0,
                                    type,
                                    roleTitle,
                                  );
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 8,
                                    left: 16,
                                    right: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              if (member.profileImage == null || member.profileImage!.isEmpty) {
                                                return CircleAvatar(radius: 20, backgroundColor: avatarColor.shade50, child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold)));
                                              } else if (member.profileImage!.startsWith('data:')) {
                                                return CircleAvatar(radius: 20, backgroundImage: MemoryImage(base64Decode(member.profileImage!.split(',').last)));
                                              } else {
                                                return ClipOval(
                                                  child: Image.network(
                                                    member.profileImage!,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => CircleAvatar(radius: 20, backgroundColor: avatarColor.shade50, child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold))),
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
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.amber,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.star,
                                                  color:
                                                      theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey.shade900
                                                      : theme
                                                            .colorScheme
                                                            .surface,
                                                  size: 10,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              member.email,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey.shade300,
                                        size: 14,
                                      ),
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
      final payload = <String, dynamic>{
        "userId": selectedMember.userId,
        "roleId": roleId,
        "type": type,
        "talukaId": _talukaId,
      };

      if (type == 'assembly_president') {
        payload["talukaHeadId"] = _currentUser?.userId ?? '';
      } else {
        payload["presidentUserId"] = _currentUser?.userId ?? '';
      }

      final res = await RoleAPI().assignRole(payload);
      if (res != null && res['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("\$roleTitle assigned successfully!")),
          );
        }
        await _loadLeadership(_talukaId);
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
        ).showSnackBar(SnackBar(content: Text("Error: \$e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _officeBearers => [
    {"title": "President", "roleId": 15, "type": "assembly_president"},
    {
      "title": "Vice President",
      "roleId": 16,
      "type": "assembly_vice_president",
    },
    {
      "title": "General Secretary",
      "roleId": 17,
      "type": "assembly_general_secretary",
    },
    {
      "title": "Treasurer",
      "roleId": 18,
      "type": "assembly_treasurer",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    UserModel? findMemberByRole(String typeSubstring) {
      final leadership = _assemblyLeadership.firstWhere(
        (l) =>
            l['assignment'] != null &&
            l['assignment']['assignmentType'] == typeSubstring,
        orElse: () => null,
      );

      if (leadership != null) {
        final holder = leadership['holder'];
        if (holder != null && holder['user'] != null) {
          return UserModel.fromJson({
            'userId': holder['user']['userId'],
            'name': holder['user']['name'],
            'email': holder['user']['email'],
            'mobileNumber': holder['user']['mobileNumber'],
            'roles': [],
            'profile': holder['profile'],
          });
        }
      }
      return null;
    }

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
          widget.assemblyName.trim().isNotEmpty ? "${widget.assemblyName} Roles" : "Roles",
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
                    "Select Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_talukaId.isNotEmpty && _selectedDistrictId == null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Auto-loaded based on your assigned Assembly",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _talukaId = '';
                                _selectedDistrictId = null;
                                _selectedTalukaId = null;
                                _assemblyLeadership = [];
                              });
                            },
                            child: const Text("Change"),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // District Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("Select District"),
                          value: _selectedDistrictId,
                          items: _districts.map((d) {
                            return DropdownMenuItem<String>(
                              value: d['districtId']?.toString(),
                              child: Text(
                                d['districtName']?.toString() ?? 'Unknown',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDistrictId = val;
                                _selectedDistrictName = _districts.firstWhere(
                                  (d) => d['districtId']?.toString() == val,
                                )['districtName'];
                              });
                              _loadTalukas(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Taluka Dropdown
                    if (_talukas.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Select Assembly / Taluka"),
                            value: _selectedTalukaId,
                            items: _talukas.map((t) {
                              return DropdownMenuItem<String>(
                                value: t['talukaId']?.toString(),
                                child: Text(
                                  t['talukaName']?.toString() ?? 'Unknown',
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedTalukaId = val;
                                  _talukaId = val;
                                  _selectedTalukaName = _talukas.firstWhere(
                                    (t) => t['talukaId']?.toString() == val,
                                  )['talukaName'];
                                });
                                _loadLeadership(val);
                              }
                            },
                          ),
                        ),
                      ),

                    if (_talukas.isEmpty && _selectedDistrictId != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "No assemblies found for this district.",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  if (_talukaId.isNotEmpty) ...[
                    const Text(
                      "Office Bearers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamically map through the assignable roles structure
                    ..._officeBearers.map((roleDef) {
                      final assignee = findMemberByRole(roleDef['type']);
                      
                      // Determine if current user can assign this role
                      bool canAssign = false;
                      if (roleDef['type'] == 'assembly_president') {
                        canAssign = _isTalukaHead;
                      } else {
                        canAssign = _isTalukaHead || _isAssemblyPresident;
                      }

                      return _buildRoleRow(
                        context,
                        roleDef['title'],
                        assignee,
                        canAssign
                            ? (assignee == null ? "Assign" : "Change")
                            : null,
                        badgeColor: Colors.indigo,
                        isUnassigned: assignee == null,
                        onTap: canAssign
                            ? () => _showAssignRoleSheet(
                                roleDef['title'],
                                roleDef['roleId'],
                                roleDef['type'],
                              )
                            : null,
                      );
                    }),

                    const SizedBox(height: 24),

                    const Text(
                      "Area Roles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (_areaCircleLeadership.isEmpty)
                      const Text("No Area Circle roles found.", style: TextStyle(color: Colors.grey))
                    else
                      SizedBox(
                        height: 380, // Approximate height to fit 4 roles
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _areaCircleLeadership.length,
                          itemBuilder: (context, index) {
                            final wardData = _areaCircleLeadership[index];
                            final wardName = wardData['wardName'] ?? 'Unknown Ward';
                            final wardNumber = wardData['wardNumber'] ?? '';
                            final leadership = wardData['leadership'] ?? {};

                            // Helper to extract member info
                            Map<String, dynamic>? getMember(String key) {
                              return leadership[key] != null ? leadership[key] as Map<String, dynamic> : null;
                            }

                            final cp = getMember('circlePresident');
                            final vp = getMember('vicePresident');
                            final gs = getMember('generalSecretary');
                            final tr = getMember('treasurer');

                            return Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.teal.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_city, color: Colors.teal.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "$wardName ${wardNumber.isNotEmpty ? '($wardNumber)' : ''}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          _buildRoleRow(context, "President", null, null, fallbackName: cp?['name'], isUnassigned: cp == null),
                                          _buildRoleRow(context, "Vice President", null, null, fallbackName: vp?['name'], isUnassigned: vp == null),
                                          _buildRoleRow(context, "General Secretary", null, null, fallbackName: gs?['name'], isUnassigned: gs == null),
                                          _buildRoleRow(context, "Treasurer", null, null, fallbackName: tr?['name'], isUnassigned: tr == null),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        "Networking posts from the \${_selectedTalukaName ?? 'Assembly'} Org Chart",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
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


