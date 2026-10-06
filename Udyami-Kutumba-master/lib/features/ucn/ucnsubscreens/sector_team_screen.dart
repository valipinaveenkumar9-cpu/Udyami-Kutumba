import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import '../../../core/api/directory/directory_api.dart';

import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/api/ubn/sector_api.dart';
import '../../directory/presentation/member_detail_screen.dart';

class SectorTeamScreen extends StatefulWidget {
  final String? sectorName;

  const SectorTeamScreen({super.key, this.sectorName});

  @override
  State<SectorTeamScreen> createState() => _SectorTeamScreenState();
}

class _SectorTeamScreenState extends State<SectorTeamScreen> {
  final DirectoryAPI _directoryAPI = DirectoryAPI();
  bool _isLoading = true;
  List<dynamic> _members = [];
  List<dynamic> _allFetchedMembers = [];

  late String _effectiveSectorName;

  // Filters
  List<String> _sectors = [];
  bool _isLoadingSectors = true;
  String _selectedRoleFilter = "All"; // "All", "Circle Roles", "Designations"

  @override
  void initState() {
    super.initState();
    _resolveSectorName();
    _fetchSectors();
    _fetchMembers();
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
      if (mounted) setState(() => _isLoadingSectors = false);
      print("Error fetching sectors: $e");
    }
  }


  void _resolveSectorName() {
    if (widget.sectorName != null && widget.sectorName!.isNotEmpty) {
      _effectiveSectorName = widget.sectorName!;
      return;
    }
    
    _effectiveSectorName = "All"; // Fallback
    try {
      final user = SessionManager.user;
      if (user != null && user['profile'] != null) {
        final profileData = ProfileDataModel.fromJson(user['profile']);
        if (profileData.hasBusiness && profileData.businessDetails != null) {
          final bType = profileData.businessDetails!.businessType;
          if (bType != null && bType.isNotEmpty) {
            final parts = bType.split(RegExp(r'[|-]')).map((e) => e.trim()).toList();
            if (parts.isNotEmpty && parts[0].isNotEmpty) {
              _effectiveSectorName = parts[0];
            }
          }
        }
      }
    } catch (e) {
      print("Error resolving sector name: $e");
    }
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      // Pass the sectorName to filter members belonging to this sector
      final members = await _directoryAPI.searchMembers('', _effectiveSectorName);
      if (mounted) {
        setState(() {
          _allFetchedMembers = members;
          _applyLocalFilters();
        });
      }
    } catch (e) {
      print("Error fetching sector members: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyLocalFilters() {
    var filtered = List<dynamic>.from(_allFetchedMembers);

    if (_selectedRoleFilter != 'All') {
      filtered = filtered.where((m) {
        final roles = m['roles'] as List<dynamic>? ?? [];
        final userRoles = m['userRoles'] as List<dynamic>? ?? [];
        
        bool hasCircleRole() {
           for (var r in roles) {
              String n = r.toString().toLowerCase();
              if (n.contains('president') || n.contains('secretary') || n.contains('treasurer') || n.contains('chairman') || n.contains('circle_leader')) return true;
           }
           for (var ur in userRoles) {
              if (ur is Map && ur['role'] is Map) {
                 String n = ur['role']['roleName']?.toString().toLowerCase() ?? '';
                 if (n.contains('president') || n.contains('secretary') || n.contains('treasurer') || n.contains('chairman') || n.contains('circle_leader')) return true;
              }
           }
           return false;
        }
        
        bool hasDesignationRole() {
           for (var r in roles) {
              String n = r.toString().toLowerCase();
              if (!(n.contains('president') || n.contains('secretary') || n.contains('treasurer') || n.contains('chairman') || n.contains('circle_leader') || n == 'member' || n == 'user' || n.isEmpty)) return true;
           }
           for (var ur in userRoles) {
              if (ur is Map && ur['role'] is Map) {
                 String n = ur['role']['roleName']?.toString().toLowerCase() ?? '';
                 if (!(n.contains('president') || n.contains('secretary') || n.contains('treasurer') || n.contains('chairman') || n.contains('circle_leader') || n == 'member' || n == 'user' || n.isEmpty)) return true;
              }
           }
           return false;
        }

        if (_selectedRoleFilter == "Circle Roles") return hasCircleRole();
        if (_selectedRoleFilter == "Designations") return hasDesignationRole();
        
        return true;
      }).toList();
    }

    _members = filtered;
  }


  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
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
          "Sector Team",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Sector Team Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.teal.shade800 : Colors.teal,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _effectiveSectorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${_members.length} members · You exchange the most leads here",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Role Filter
                  Text("Role Filter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "Circle Roles", "Designations"].map((role) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRoleFilter = role;
                              _applyLocalFilters();
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: _buildPill(role, isSelected: _selectedRoleFilter == role, isDark: isDark),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sector Filter
                  Text("Sector Filter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _isLoadingSectors
                        ? const Padding(padding: EdgeInsets.only(left: 10), child: CircularProgressIndicator())
                        : Row(
                            children: _sectors.map((sector) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _effectiveSectorName = sector;
                                  });
                                  _fetchMembers();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: _buildPill(sector, isSelected: _effectiveSectorName == sector, isDark: isDark),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 25),

                  /// Members Heading

                  Text(
                    "Team Members",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_members.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No members found in this sector.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ..._members.map((member) {
                      final name = member['name']?.toString() ?? 'Unknown Member';
                      final profile = member['profile'];
                      String category = "Not Updated";
                      if (profile != null && profile['businessDetails'] != null) {
                         final bType = profile['businessDetails']['businessType']?.toString() ?? '';
                         if (bType.isNotEmpty) {
                            final parts = bType.split(RegExp(r'[|-]')).map((e) => e.trim()).toList();
                            if (parts.length > 1) {
                               category = parts[1];
                            } else {
                               category = parts[0];
                            }
                         }
                      }
                      String badgeText = "";
                      if (member['roles'] != null) {
                         for (var r in member['roles']) {
                            String n = r.toString();
                            if (n.toLowerCase() != 'user' && n.toLowerCase() != 'member' && n.isNotEmpty) {
                               badgeText = n;
                               break;
                            }
                         }
                      }
                      if (badgeText.isEmpty && member['userRoles'] != null) {
                         for (var ur in member['userRoles']) {
                            if (ur is Map && ur['role'] is Map) {
                               String n = ur['role']['roleName']?.toString() ?? '';
                               if (n.toLowerCase() != 'user' && n.toLowerCase() != 'member' && n.isNotEmpty) {
                                  badgeText = n;
                                  break;
                               }
                            }
                         }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _memberTile(
                          context,
                          member: member,
                          initials: _getInitials(name),
                          name: name,
                          category: category,
                          badgeText: badgeText,
                          color: Colors.teal,
                          isDark: isDark,
                        ),
                      );
                    }),

                  const SizedBox(height: 25),

                  Center(
                    child: Text(
                      "Sector Teams group members who refer each other most",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _memberTile(BuildContext context, {
    required Map<String, dynamic> member,
    required String initials,
    required String name,
    required String category,
    required String badgeText,
    required Color color,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemberDetailScreen(
              member: member,
              initials: initials,
              name: name,
              shortTitle: category,
              fullSectorInfo: _effectiveSectorName,
              avatarColor: color is MaterialColor ? color : Colors.teal,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.15),
            child: Text(
              initials,
              style: TextStyle(
                color: isDark ? (color is MaterialColor ? color.shade300 : color) : color,
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
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText.length > 15 ? '${badgeText.substring(0, 15)}...' : badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  category,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: isDark ? Colors.grey.shade600 : Colors.grey,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPill(String text, {required bool isSelected, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}