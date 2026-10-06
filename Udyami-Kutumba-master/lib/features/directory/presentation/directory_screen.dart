import 'dart:async';
import 'package:flutter/material.dart';
import 'member_detail_screen.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/api/auth/auth_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/utils/session_manager.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final DirectoryAPI _directoryAPI = DirectoryAPI();
  final TextEditingController _searchController = TextEditingController();

  String _selectedSector = 'All';
  String _selectedRoleFilter = 'All';
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = false;
  Timer? _debounce;

  List<String> _sectors = ['All'];
  bool _isLoadingSectors = true;

  bool _isAreaSelected = false;
  String _wardId = "";
  String _wardName = "Area";

  @override
  void initState() {
    super.initState();
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initData() async {
    try {
      final currentUser = SessionManager.user;
      if (currentUser != null) {
        final userModel = UserModel.fromJson(currentUser);
        final roleWithWard = userModel.roles.firstWhere(
          (r) => r.wardId != null && r.wardId!.isNotEmpty,
          orElse: () => RoleModel(roleId: 0, roleName: ''),
        );
        if (roleWithWard.wardId != null && roleWithWard.wardId!.isNotEmpty) {
          _wardId = roleWithWard.wardId!;
        } else {
          final profileRes = await ProfileAPI().getUserProfileById(
            userModel.userId,
          );
          if (profileRes != null && profileRes['success'] == true) {
            final wardName = profileRes['data']?['profile']?['ward'];
            if (wardName != null && wardName.toString().isNotEmpty) {
              _wardName = wardName.toString();
              final allWardsRes = await WardAPI().getAllWards(
                wardName: _wardName,
              );
              if (allWardsRes != null && allWardsRes['success'] == true) {
                final List wards = allWardsRes['data'] ?? [];
                if (wards.isNotEmpty) {
                  _wardId = wards[0]['wardId'];
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("DEV DEBUG - DirectoryScreen Error fetching wardId: $e");
    }

    if (_wardId.isEmpty) {
      _wardId = "825a3f8c-f9fa-40d6-a291-61401fe8a7a2"; // Fallback
    }

    _fetchSectors();
    _performSearch();
  }

  Future<void> _fetchSectors() async {
    try {
      final res = await SectorAPI().getAllSectors();
      if (res != null && res['success'] == true && res['data'] != null) {
        if (mounted) {
          setState(() {
            _sectors = ['All'];
            for (var s in res['data']) {
              if (s['sectorName'] != null) {
                _sectors.add(s['sectorName']);
              }
            }
            _isLoadingSectors = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingSectors = false);
      }
    } catch (e) {
      print("DEV DEBUG - DirectoryScreen Error fetching sectors: $e");
      if (mounted) setState(() => _isLoadingSectors = false);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    if (_isAreaSelected && _wardId.isNotEmpty) {
      try {
        final res = await AuthAPI().getUcnMembers(_wardId);
        if (res != null && res['success'] == true) {
          final List membersList = res['data'] ?? [];
          if (mounted) {
            setState(() {
              _members = membersList.map<Map<String, dynamic>>((e) {
                String sector = 'All';
                String businessName = '';
                String businessLocation = '';

                if (e['businessDetails'] != null &&
                    e['businessDetails'] is Map) {
                  sector = e['businessDetails']['businessType'] ?? sector;
                  businessName = e['businessDetails']['businessName'] ?? '';
                  businessLocation = e['officeAddress'] ?? '';
                } else if (e['profile'] != null &&
                    e['profile']['businessDetails'] != null) {
                  sector = e['profile']['businessDetails']['sector'] ?? sector;
                  businessName =
                      e['profile']['businessDetails']['businessName'] ?? '';
                  businessLocation = e['profile']['businessLocation'] ?? '';
                }

                return {
                  'name': e['name']?.toString() ?? 'Unknown',
                  'sector': sector,
                  'businessName': businessName,
                  'businessLocation': businessLocation,
                  'isPrime': e['isPrime'] == true,
                  'isBasic': e['isBasic'] == true,
                  'isPatron': e['isPatron'] == true,
                  'initials': _getInitials(e['name']?.toString() ?? ''),
                  'roles': e['roles'] ?? [],
                  'userRoles': e['userRoles'] ?? [],
                  'profile': e['profile'],
                };
              }).toList();

              if (_selectedRoleFilter != 'All') {
                _members = _members.where((m) {
                  final roles = m['roles'] as List<dynamic>? ?? [];
                  final userRoles = m['userRoles'] as List<dynamic>? ?? [];

                  bool hasCircleRole() {
                    for (var r in roles) {
                      String n = r.toString().toLowerCase();
                      if (n.contains('president') ||
                          n.contains('secretary') ||
                          n.contains('treasurer') ||
                          n.contains('chairman') ||
                          n.contains('circle_leader'))
                        return true;
                    }
                    for (var ur in userRoles) {
                      if (ur is Map && ur['role'] is Map) {
                        String n =
                            ur['role']['roleName']?.toString().toLowerCase() ??
                            '';
                        if (n.contains('president') ||
                            n.contains('secretary') ||
                            n.contains('treasurer') ||
                            n.contains('chairman') ||
                            n.contains('circle_leader'))
                          return true;
                      }
                    }
                    return false;
                  }

                  bool hasDesignationRole() {
                    for (var r in roles) {
                      String n = r.toString().toLowerCase();
                      if (!(n.contains('president') ||
                          n.contains('secretary') ||
                          n.contains('treasurer') ||
                          n.contains('chairman') ||
                          n.contains('circle_leader') ||
                          n == 'member' ||
                          n == 'user' ||
                          n.isEmpty))
                        return true;
                    }
                    for (var ur in userRoles) {
                      if (ur is Map && ur['role'] is Map) {
                        String n =
                            ur['role']['roleName']?.toString().toLowerCase() ??
                            '';
                        if (!(n.contains('president') ||
                            n.contains('secretary') ||
                            n.contains('treasurer') ||
                            n.contains('chairman') ||
                            n.contains('circle_leader') ||
                            n == 'member' ||
                            n == 'user' ||
                            n.isEmpty))
                          return true;
                      }
                    }
                    return false;
                  }

                  if (_selectedRoleFilter == "Circle Roles")
                    return hasCircleRole();
                  if (_selectedRoleFilter == "Designations")
                    return hasDesignationRole();
                  if (_selectedRoleFilter == "Basic")
                    return m['isBasic'] == true;
                  if (_selectedRoleFilter == "Prime")
                    return m['isPrime'] == true;
                  if (_selectedRoleFilter == "Patron")
                    return m['isPatron'] == true;

                  return true;
                }).toList();
              }

              if (_selectedSector != 'All') {
                _members = _members
                    .where((m) => m['sector'] == _selectedSector)
                    .toList();
              }

              if (_searchController.text.isNotEmpty) {
                final query = _searchController.text.toLowerCase();
                _members = _members
                    .where(
                      (m) =>
                          m['name'].toString().toLowerCase().contains(query) ||
                          m['businessName'].toString().toLowerCase().contains(
                            query,
                          ),
                    )
                    .toList();
              }

              print(
                'DEV DEBUG - ui - directory_screen.dart - Parsed ${_members.length} members from AuthAPI for area',
              );
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
        print("DEV DEBUG - directory_screen.dart AuthAPI fetch error: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      final results = await _directoryAPI.searchMembers(
        _searchController.text,
        _selectedSector,
      );

      if (mounted) {
        setState(() {
          _members = results.map<Map<String, dynamic>>((e) {
            String sector = _selectedSector;
            String businessName = '';

            if (e['profile'] != null &&
                e['profile']['businessDetails'] != null) {
              sector = e['profile']['businessDetails']['sector'] ?? sector;
              businessName =
                  e['profile']['businessDetails']['businessName'] ?? '';
            }

            return {
              'name': e['name']?.toString() ?? 'Unknown',
              'sector': sector,
              'businessName': businessName,
              'businessLocation':
                  e['businessLocation']?.toString() ??
                  e['officeLocation']?.toString() ??
                  '',
              'isPrime': e['isPrime'] == true,
              'isBasic': e['isBasic'] == true,
              'isPatron': e['isPatron'] == true,
              'initials': _getInitials(e['name']?.toString() ?? ''),
              'roles': e['roles'] ?? [],
              'userRoles': e['userRoles'] ?? [],
              'profile': e['profile'],
            };
          }).toList();

          if (_selectedRoleFilter != 'All') {
            _members = _members.where((m) {
              final roles = m['roles'] as List<dynamic>? ?? [];
              final userRoles = m['userRoles'] as List<dynamic>? ?? [];

              bool hasCircleRole() {
                for (var r in roles) {
                  String n = r.toString().toLowerCase();
                  if (n.contains('president') ||
                      n.contains('secretary') ||
                      n.contains('treasurer') ||
                      n.contains('chairman') ||
                      n.contains('circle_leader'))
                    return true;
                }
                for (var ur in userRoles) {
                  if (ur is Map && ur['role'] is Map) {
                    String n =
                        ur['role']['roleName']?.toString().toLowerCase() ?? '';
                    if (n.contains('president') ||
                        n.contains('secretary') ||
                        n.contains('treasurer') ||
                        n.contains('chairman') ||
                        n.contains('circle_leader'))
                      return true;
                  }
                }
                return false;
              }

              bool hasDesignationRole() {
                for (var r in roles) {
                  String n = r.toString().toLowerCase();
                  if (!(n.contains('president') ||
                      n.contains('secretary') ||
                      n.contains('treasurer') ||
                      n.contains('chairman') ||
                      n.contains('circle_leader') ||
                      n == 'member' ||
                      n == 'user' ||
                      n.isEmpty))
                    return true;
                }
                for (var ur in userRoles) {
                  if (ur is Map && ur['role'] is Map) {
                    String n =
                        ur['role']['roleName']?.toString().toLowerCase() ?? '';
                    if (!(n.contains('president') ||
                        n.contains('secretary') ||
                        n.contains('treasurer') ||
                        n.contains('chairman') ||
                        n.contains('circle_leader') ||
                        n == 'member' ||
                        n == 'user' ||
                        n.isEmpty))
                      return true;
                  }
                }
                return false;
              }

              if (_selectedRoleFilter == "Circle Roles") return hasCircleRole();
              if (_selectedRoleFilter == "Designations")
                return hasDesignationRole();
              if (_selectedRoleFilter == "Basic") return m['isBasic'] == true;
              if (_selectedRoleFilter == "Prime") return m['isPrime'] == true;
              if (_selectedRoleFilter == "Patron") return m['isPatron'] == true;

              return true;
            }).toList();
          }

          print(
            'DEV DEBUG - ui - directory_screen.dart - Parsed ${_members.length} members from search API',
          );
          _isLoading = false;
        });
      }
    }
  }

  void _onSectorSelected(String sector) {
    setState(() {
      _selectedSector = sector;
    });
    _performSearch();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  MaterialColor _getAvatarColor(int index) {
    final colors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.orange,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        title: Text(
          'Directory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _performSearch,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search name or business",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Area Chip Filter
              Text(
                "Area",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isAreaSelected = !_isAreaSelected;
                        });
                        _performSearch();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: _buildPill(
                        _wardName.isNotEmpty ? _wardName : "Area",
                        isSelected: _isAreaSelected,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Role Filter
              Text(
                "Role Filter",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        "All",
                        "Circle Roles",
                        "Designations",
                        "Basic",
                        "Prime",
                        "Patron",
                      ].map((role) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRoleFilter = role;
                            });
                            _performSearch();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: _buildPill(
                            role,
                            isSelected: _selectedRoleFilter == role,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Sector
              Text(
                "Sector",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _isLoadingSectors
                    ? const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: CircularProgressIndicator(),
                      )
                    : Row(
                        children: _sectors.map((sector) {
                          return InkWell(
                            onTap: () => _onSectorSelected(sector),
                            borderRadius: BorderRadius.circular(20),
                            child: _buildPill(
                              sector,
                              isSelected: _selectedSector == sector,
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Sub-sector temporarily hidden as requested
              // Text("Sub-sector → tag", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // const SizedBox(height: 10),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       _buildPill("Design & Architecture", isSelected: true),
              //       _buildPill("Building materials"),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 24),

              // Members Header
              Text(
                "${_members.length} members",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Members List
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_members.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      "No members found",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ..._members.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Map<String, dynamic> user = entry.value;
                  final String initials = user['initials'];
                  final MaterialColor color = _getAvatarColor(index);
                  final bool isPrime = user['isPrime'] ?? false;

                  final String bName = user['businessName'];
                  final String bLoc = user['businessLocation'];
                  final String sector = user['sector'];

                  String subtitle = bName.isNotEmpty ? bName : 'Member';
                  if (isPrime && bName.isEmpty) subtitle = 'Prime Member';

                  String fullSectorInfo = "$sector · $bLoc";
                  if (bName.isNotEmpty)
                    fullSectorInfo = "$bName · $fullSectorInfo";

                  String planType = "Basic";
                  if (isPrime) planType = "Prime";
                  if (user['profile'] != null) {
                    final plan =
                        user['profile']['planType']?.toString().toLowerCase() ??
                        '';
                    final subscription =
                        user['profile']['subscription']
                            ?.toString()
                            .toLowerCase() ??
                        '';
                    if (plan == 'prime' || subscription == 'prime')
                      planType = "Prime";
                    if (plan == 'patron' || subscription == 'patron')
                      planType = "Patron";
                  }

                  String designation = '';
                  final roles = user['roles'] as List<dynamic>? ?? [];
                  final userRoles = user['userRoles'] as List<dynamic>? ?? [];

                  for (var r in roles) {
                    String n = r.toString().toLowerCase();
                    if (n.contains('president') && !n.contains('vice'))
                      designation = 'President';
                    else if (n.contains('vice president') ||
                        n.contains('vice_president'))
                      designation = 'Vice President';
                    else if (n.contains('general_secretary') ||
                        n.contains('general secretary'))
                      designation = 'General Secretary';
                    else if (n.contains('secretary'))
                      designation = 'Secretary';
                    else if (n.contains('treasurer'))
                      designation = 'Treasurer';
                    else if (n.contains('chairman'))
                      designation = 'Chairman';
                    else if (n.contains('circle_leader'))
                      designation = 'Circle Leader';
                    else if (n != 'member' && n != 'user' && n.isNotEmpty) {
                      designation = r.toString();
                      // Capitalize first letter
                      if (designation.isNotEmpty) {
                        designation =
                            designation[0].toUpperCase() +
                            designation.substring(1);
                      }
                    }
                  }
                  if (designation.isEmpty) {
                    for (var ur in userRoles) {
                      if (ur is Map && ur['role'] is Map) {
                        String rawName =
                            ur['role']['roleName']?.toString() ?? '';
                        String n = rawName.toLowerCase();
                        if (n.contains('president') && !n.contains('vice'))
                          designation = 'President';
                        else if (n.contains('vice president') ||
                            n.contains('vice_president'))
                          designation = 'Vice President';
                        else if (n.contains('general_secretary') ||
                            n.contains('general secretary'))
                          designation = 'General Secretary';
                        else if (n.contains('secretary'))
                          designation = 'Secretary';
                        else if (n.contains('treasurer'))
                          designation = 'Treasurer';
                        else if (n.contains('chairman'))
                          designation = 'Chairman';
                        else if (n.contains('circle_leader'))
                          designation = 'Circle Leader';
                        else if (n != 'member' && n != 'user' && n.isNotEmpty) {
                          designation = rawName;
                          // Capitalize
                          if (designation.isNotEmpty) {
                            designation =
                                designation[0].toUpperCase() +
                                designation.substring(1);
                          }
                        }
                      }
                    }
                  }

                  return _buildMemberRow(
                    context,
                    user: user,
                    initials: initials,
                    name: user['name'],
                    subtitle: subtitle,
                    fullSectorInfo: fullSectorInfo,
                    avatarColor: color,
                    isPrime: isPrime,
                    planType: planType,
                    designation: designation,
                  );
                }),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  "336 tags across 18 sectors · tap a member",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildMemberRow(
    BuildContext context, {
    required Map<String, dynamic> user,
    required String initials,
    required String name,
    required String subtitle,
    required String fullSectorInfo,
    required MaterialColor avatarColor,
    bool isPrime = false,
    String planType = "Basic",
    String designation = '',
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemberDetailScreen(
              member: user, // pass full user map
              initials: initials,
              name: name,
              shortTitle: subtitle.split(' · ').first,
              fullSectorInfo: fullSectorInfo,
              avatarColor: avatarColor,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColor.shade100,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: avatarColor.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isPrime)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: planType == "Patron" ? Colors.red : Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Theme.of(context).colorScheme.surface,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (designation.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            designation,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                      if (planType != "Basic") ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: planType == "Patron"
                                ? Colors.red.withOpacity(0.1)
                                : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: planType == "Patron"
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.amber.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            planType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: planType == "Patron"
                                  ? Colors.red.shade700
                                  : Colors.amber.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
  }
}
