import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/api/auth/auth_api.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_model.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  bool _isLoading = true;
  List<dynamic> _members = [];
  bool _isAreaSelected = false;
  String _wardId = "";
  String _wardName = "Area";
  String _selectedRoleFilter = "All";

  List<dynamic> _sectors = [];
  bool _isLoadingSectors = true;
  String _selectedSector = "All";
  String _selectedSubSector = "All";

  @override
  void initState() {
    super.initState();
    _initData();
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
          final profileRes = await ProfileAPI().getUserProfileById(userModel.userId);
          if (profileRes != null && profileRes['success'] == true) {
            final wardName = profileRes['data']?['profile']?['ward'];
            if (wardName != null && wardName.toString().isNotEmpty) {
              _wardName = wardName.toString();
              final allWardsRes = await WardAPI().getAllWards(wardName: _wardName);
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
      _wardId = "825a3f8c-f9fa-40d6-a291-61401fe8a7a2"; // Fallback to provided example
    }

    _fetchSectors();
    _fetchMembers();
  }

  Future<void> _fetchSectors() async {
    try {
      final res = await SectorAPI().getAllSectors();
      if (res != null && res['success'] == true && res['data'] != null) {
        if (mounted) {
          setState(() {
            _sectors = res['data'];
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

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isAreaSelected && _wardId.isNotEmpty) {
        final res = await AuthAPI().getUcnMembers(_wardId);
        if (res != null && res['success'] == true) {
          _members = res['data'] ?? [];
        }
      } else {
        _members = await DirectoryAPI().searchMembers('', '');
      }
    } catch (e) {
      print("DEV DEBUG - DirectoryScreen Error fetching members: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        actions: const [ThemeToggleButton()],
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Directory",
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
                  /// Search Box
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search name or business",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Filters
                  Text(
                    "Area",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAreaSelected = !_isAreaSelected;
                      });
                      _fetchMembers();
                    },
                    child: _chip(context, _wardName.isNotEmpty ? _wardName : "Area", _isAreaSelected),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Role Filter",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "Circle Leader", "Sector Head", "Member"].map((r) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRoleFilter = r;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _chip(context, r, _selectedRoleFilter == r),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Sector
                  Text(
                    "Sector",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingSectors)
                    const Padding(padding: EdgeInsets.only(left: 10), child: CircularProgressIndicator())
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSector = "All";
                                _selectedSubSector = "All";
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _chip(context, "All", _selectedSector == "All"),
                            ),
                          ),
                          ..._sectors.map((sectorObj) {
                            final sectorName = sectorObj['sectorName']?.toString() ?? '';
                            if (sectorName.isEmpty) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSector = sectorName;
                                  _selectedSubSector = "All";
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _chip(context, sectorName, _selectedSector == sectorName),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// Sub Sector
                  if (_selectedSector != "All") ...[
                    Text(
                      "Sub-sector",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _selectedSubSector = "All"),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _chip(context, "All", _selectedSubSector == "All"),
                            ),
                          ),
                          ...(() {
                            final sectorObj = _sectors.firstWhere((s) => s['sectorName'] == _selectedSector, orElse: () => null);
                            if (sectorObj != null && sectorObj['subSectors'] != null) {
                              final subSectors = sectorObj['subSectors'] as List<dynamic>;
                              return subSectors.map((subObj) {
                                final subName = subObj['subSectorName']?.toString() ?? '';
                                if (subName.isEmpty) return const SizedBox.shrink();
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedSubSector = subName),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: _chip(context, subName, _selectedSubSector == subName),
                                  ),
                                );
                              }).toList();
                            }
                            return [const SizedBox.shrink()];
                          })(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  Text(
                    "${_members.length} Members",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  ...(() {
                    var filteredMembers = _members;
                    if (_selectedRoleFilter != "All") {
                      filteredMembers = _members.where((m) {
                        final roles = m['roles'] as List<dynamic>? ?? [];
                        final userRoles = m['userRoles'] as List<dynamic>? ?? [];

                        bool isCircleLeader = roles.contains('circle_leader') || userRoles.any((ur) => (ur is Map && ur['role'] is Map && ur['role']['roleName'] == 'circle_leader'));
                        bool isSectorHead = roles.contains('sector_head') || userRoles.any((ur) => (ur is Map && ur['role'] is Map && ur['role']['roleName'] == 'sector_head'));

                        if (_selectedRoleFilter == "Circle Leader") {
                          return isCircleLeader;
                        } else if (_selectedRoleFilter == "Sector Head") {
                          return isSectorHead;
                        } else if (_selectedRoleFilter == "Member") {
                          return !isCircleLeader && !isSectorHead;
                        }
                        return true;
                      }).toList();
                    }

                    if (_selectedSector != "All") {
                      filteredMembers = filteredMembers.where((m) {
                        String sector = "Member";
                        if (m['businessDetails'] != null && m['businessDetails'] is Map) {
                          sector = m['businessDetails']['businessType'] ?? sector;
                        } else if (m['profile'] != null && m['profile']['businessDetails'] != null) {
                          sector = m['profile']['businessDetails']['sector'] ?? sector;
                        }
                        return sector == _selectedSector;
                      }).toList();
                    }

                    if (filteredMembers.isEmpty) {
                      return [
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text("No members found."),
                          ),
                        )
                      ];
                    }

                    return filteredMembers.map((m) {
                      final String name = m['name'] ?? m['assignedUserName'] ?? 'Unknown';
                      final String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
                      String business = "Member";
                      
                      if (m['businessDetails'] != null && m['businessDetails'] is Map) {
                         business = m['businessDetails']['businessType'] ?? "Member";
                         if (m['businessDetails']['ward'] != null) {
                           business += " · Ward ${m['businessDetails']['ward']}";
                         }
                      } else if (m['profile'] != null && m['profile']['businessDetails'] != null) {
                         business = m['profile']['businessDetails']['sector'] ?? "Member";
                         if (m['profile']['ward'] != null) {
                           business += " · Ward ${m['profile']['ward']}";
                         }
                      }

                      String planType = "Basic";
                      if (m['isPrime'] == true) planType = "Prime";
                      
                      if (m['profile'] != null) {
                         final plan = m['profile']['planType']?.toString().toLowerCase() ?? '';
                         final subscription = m['profile']['subscription']?.toString().toLowerCase() ?? '';
                         if (plan == 'prime' || subscription == 'prime') planType = "Prime";
                         if (plan == 'patron' || subscription == 'patron') planType = "Patron";
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _memberTile(
                          context,
                          initials: initials,
                          color: Colors.purple, // Randomize or set a static color
                          name: name,
                          business: business,
                          planType: planType,
                        ),
                      );
                    });
                  })(),

                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      "Tap a member to view profile",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chip(BuildContext context, String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _memberTile(BuildContext context, {
    required String initials,
    required Color color,
    required String name,
    required String business,
    required String planType,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100),
        boxShadow: [
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
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.15),
            child: Text(
              initials,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
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
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (planType != "Basic") ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: planType == "Patron" ? Colors.red.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: planType == "Patron" ? Colors.red.withOpacity(0.5) : Colors.amber.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          planType,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: planType == "Patron" ? Colors.red.shade700 : Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  business,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}