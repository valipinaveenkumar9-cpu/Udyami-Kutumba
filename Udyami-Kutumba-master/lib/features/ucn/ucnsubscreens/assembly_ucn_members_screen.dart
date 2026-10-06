import 'package:flutter/material.dart';
import 'dart:convert' as dart_convert;
import '../../../core/api/profile/profile_api.dart';
import '../../../core/api/area/taluka_api.dart';
import '../../../core/api/location/location_api.dart';
import '../../../core/api/role/role_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/session_manager.dart';
import 'circle_ucn_members_screen.dart';

class AssemblyUcnMembersScreen extends StatefulWidget {
  const AssemblyUcnMembersScreen({super.key, this.assemblyName = 'Assembly'});
  final String assemblyName;

  @override
  State<AssemblyUcnMembersScreen> createState() => _AssemblyUcnMembersScreenState();
}

class _AssemblyUcnMembersScreenState extends State<AssemblyUcnMembersScreen> {
  final TalukaAPI _talukaApi = TalukaAPI();
  bool _isLoading = true;
  String _talukaId = '';
  UserModel? _currentUser;
  Map<String, dynamic>? _talukaData;
  List<dynamic> _wardsList = [];

  // Dynamic API state for Dropdowns
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _talukas = [];
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedTalukaId;
  String? _selectedTalukaName;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final userJson = SessionManager.user;
    if (userJson != null) {
      debugPrint('DEV DEBUG [RAW SESSION JSON] - ${dart_convert.jsonEncode(userJson)}');
      _currentUser = UserModel.fromJson(userJson);
      try {
        debugPrint('DEV DEBUG [AssemblyUcnMembers] - Checking Roles for Taluka ID');
        for (var role in _currentUser!.roles) {
          debugPrint('DEV DEBUG [AssemblyUcnMembers] - Role: ${role.roleName}, talukaId: ${role.talukaId}');
        }
        
        final roleWithTaluka = _currentUser!.roles.firstWhere(
          (r) => r.talukaId != null && r.talukaId!.isNotEmpty,
          orElse: () => RoleModel(roleId: 0, roleName: ''),
        );
        
        debugPrint('DEV DEBUG [AssemblyUcnMembers] - Found roleWithTaluka talukaId: ${roleWithTaluka.talukaId}');
        
        if (roleWithTaluka.talukaId != null && roleWithTaluka.talukaId!.isNotEmpty) {
          _talukaId = roleWithTaluka.talukaId!;
          _selectedTalukaId = _talukaId;
          debugPrint('DEV DEBUG [AssemblyUcnMembers] - Set _talukaId from roles: $_talukaId');
        } else {
          debugPrint('DEV DEBUG [AssemblyUcnMembers] - No talukaId found in roles, falling back to ProfileAPI...');
          final profileRes = await ProfileAPI().getUserProfileById(_currentUser!.userId);
          if (profileRes != null && profileRes['success'] == true) {
            final profile = profileRes['data']?['profile'] ?? {};
            debugPrint('DEV DEBUG [AssemblyUcnMembers] - Profile Data: $profile');
            
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
                          _selectedDistrictId = distId;
                          _selectedDistrictName = matchDist['districtName']?.toString();
                          // We intentionally set _selectedDistrictId to null afterwards to trigger the green Auto-Load UI!
                          _selectedDistrictId = null; 
                          _selectedTalukaId = _talukaId;
                          found = true;
                          debugPrint('DEV DEBUG [AssemblyUcnMembers] - Successfully resolved _talukaId from ProfileAPI: $_talukaId');
                        }
                      }
                    }
                  }
                }
                
                // If strict matching failed, search all districts
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
                            _selectedDistrictId = dId;
                            _selectedDistrictName = dist['districtName']?.toString();
                            _selectedDistrictId = null; 
                            _selectedTalukaId = _talukaId;
                            found = true;
                            debugPrint('DEV DEBUG [AssemblyUcnMembers] - Resolved _talukaId from cross-district ProfileAPI: $_talukaId');
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
            debugPrint('DEV DEBUG [AssemblyUcnMembers] - Profile empty, falling back to RoleAPI.getAllRoleUsers()...');
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
                  debugPrint('DEV DEBUG [AssemblyUcnMembers] - Successfully resolved _talukaId from RoleAPI: $_talukaId');
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error finding Taluka ID: $e');
      }
    }

    try {
      final distRes = await LocationAPI().getAllDistricts();
      if (distRes != null && distRes['success'] == true) {
        final List rawDistricts = distRes['data'] ?? [];
        _districts = rawDistricts.cast<Map<String, dynamic>>();
      }

      if (_talukaId.isNotEmpty) {
        await _fetchTalukaData();
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTalukas(String districtId) async {
    setState(() => _isLoading = true);
    try {
      final talukaRes = await LocationAPI().getAllDistricts(districtId: districtId);
      if (talukaRes != null && talukaRes['success'] == true) {
        final List rawTalukas = talukaRes['data'] ?? [];
        _talukas = rawTalukas.cast<Map<String, dynamic>>();
        _selectedTalukaId = null;
        _selectedTalukaName = null;
        _talukaId = '';
        _talukaData = null;
        _wardsList = [];
      }
    } catch (e) {
      debugPrint('Error loading talukas: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchTalukaData() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('DEV DEBUG - AssemblyUcnMembersScreen: Fetching data for talukaId: $_talukaId');
      final response = await _talukaApi.getAllUcnMembersUnderTaluka(_talukaId);
      debugPrint('DEV DEBUG - AssemblyUcnMembersScreen: Response: $response');
      if (response != null && response['success'] == true) {
        setState(() {
          _talukaData = response['data'];
          _wardsList = _talukaData?['wards'] ?? [];
        });
        debugPrint('DEV DEBUG - AssemblyUcnMembersScreen: Data parsed, wards count: ${_wardsList.length}');
      } else {
        debugPrint('DEV DEBUG - AssemblyUcnMembersScreen: API returned success=false or null response');
      }
    } catch (e) {
      debugPrint('Error fetching Taluka UCN members: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Assembly data: $e')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.assemblyName.trim().isNotEmpty ? '${widget.assemblyName} Members' : 'Members', style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
              onRefresh: _fetchTalukaData,
              color: Colors.teal,
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildDropdowns(theme),
                  const SizedBox(height: 16),
                  if (_talukaId.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          "Please select.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else if (_talukaData == null)
                    const Center(child: Text("No data found"))
                  else ...[
                    _buildStatsHeader(context),
                    const SizedBox(height: 16),
                    _buildCountCards(context),
                    const SizedBox(height: 16),
                    _buildActivityStats(context),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.location_city, size: 20, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Areas (${_wardsList.length})",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _wardsList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                "No Areas found.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _wardsList.length,
                            itemBuilder: (context, index) {
                              final ward = _wardsList[index];
                              return _buildWardCard(context, ward, isDark);
                            },
                          ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDropdowns(ThemeData theme) {
    debugPrint('DEV DEBUG [AssemblyUcnMembers UI] - _talukaId: "$_talukaId", _selectedDistrictId: "$_selectedDistrictId"');
    
    if (_talukaId.isNotEmpty && _selectedDistrictId == null) {
      return Container(
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
                  _talukaData = null;
                  _wardsList = [];
                });
              },
              child: const Text("Change"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // District Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
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
                  child: Text(d['districtName']?.toString() ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedDistrictId = val;
                    _selectedDistrictName = _districts.firstWhere((d) => d['districtId']?.toString() == val)['districtName'];
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
              color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
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
                    child: Text(t['talukaName']?.toString() ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTalukaId = val;
                      _talukaId = val;
                      _selectedTalukaName = _talukas.firstWhere((t) => t['talukaId']?.toString() == val)['talukaName'];
                    });
                    _fetchTalukaData();
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: "Total Areas",
            value: "${_talukaData?['totalWards'] ?? 0}",
            icon: Icons.map_rounded,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            title: "Total Members",
            value: "${_talukaData?['totalMembers'] ?? 0}",
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
        _buildSmallCountCard("Basic", _talukaData?['basicCount'] ?? 0, Colors.blueGrey),
        _buildSmallCountCard("Prime", _talukaData?['primeCount'] ?? 0, Colors.orange),
        _buildSmallCountCard("Patron", _talukaData?['patronCount'] ?? 0, Colors.purple),
      ],
    );
  }

  Widget _buildActivityStats(BuildContext context) {
    return Column(
      children: [
        _buildTwoColCard("Gratitude Slips", (_talukaData?['totalGratitudeSlips'] ?? 0).toString(), 
                         "Total Amount", "₹${_talukaData?['totalGratitudeAmount'] ?? 0}", 
                         [Colors.green.shade700, Colors.green.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Leads", 
                           "Total", (_talukaData?['totalLeads'] ?? 0).toString(), 
                           [Colors.blue.shade700, Colors.blue.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Face to Face", 
                           "Total", (_talukaData?['totalFaceToFace'] ?? 0).toString(), 
                           [Colors.indigo.shade700, Colors.indigo.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Guests", 
                           "Total", (_talukaData?['totalGuests'] ?? 0).toString(), 
                           [Colors.deepPurple.shade700, Colors.deepPurple.shade500]),
        const SizedBox(height: 16),
        _buildTitleAndStatCard("Attendance", 
                           "Total", (_talukaData?['totalAttendance'] ?? 0).toString(), 
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

  Widget _buildSmallCountCard(String label, int count, Color color) {
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
            Text(count.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }


  Widget _buildWardCard(BuildContext context, dynamic ward, bool isDark) {
    final wardName = ward['wardName']?.toString() ?? 'Unknown Area';
    final wardNumber = ward['wardNumber']?.toString() ?? '';
    final totalMembers = ward['totalMembers'] ?? 0;
    final wardId = ward['wardId']?.toString() ?? '';

    final totalLeads = ward['totalLeads'] ?? 0;
    final totalFaceToFace = ward['totalFaceToFace'] ?? 0;
    final totalGuests = ward['totalGuests'] ?? 0;
    final totalGratitudeSlips = ward['totalGratitudeSlips'] ?? 0;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (wardId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CircleUcnMembersScreen(wardId: wardId),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        wardName.isNotEmpty ? wardName.substring(0, 1).toUpperCase() : 'W',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wardName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (wardNumber.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Area: $wardNumber',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.teal.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '$totalMembers',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWardStatItem("Leads", totalLeads, Icons.leaderboard, Colors.blue),
                  _buildWardStatItem("F2F", totalFaceToFace, Icons.handshake, Colors.indigo),
                  _buildWardStatItem("Guests", totalGuests, Icons.person_add, Colors.deepPurple),
                  _buildWardStatItem("Slips", totalGratitudeSlips, Icons.receipt, Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}


