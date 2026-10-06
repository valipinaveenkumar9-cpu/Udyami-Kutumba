import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/area/ward_api.dart';
import '../../../core/models/ward_model.dart';
import '../../../core/utils/session_manager.dart';

class AssignMemberScreen extends StatefulWidget {
  final WardModel ward;
  final String slotId;
  final String slotLabel;
  final String wardHeadId;
  final Map<String, dynamic>? assignedUser;

  const AssignMemberScreen({
    super.key,
    required this.ward,
    required this.slotId,
    required this.slotLabel,
    required this.wardHeadId,
    this.assignedUser,
  });

  @override
  State<AssignMemberScreen> createState() => _AssignMemberScreenState();
}

class _AssignMemberScreenState extends State<AssignMemberScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  
  List<String> _availableWards = [];
  Map<String, String> _wardNameToId = {};
  String _selectedWardFilter = '';

  bool get _isTalukaLevelSearch => widget.slotId.startsWith('official-') || widget.slotId.startsWith('patron-') || widget.slotId.startsWith('chairman-');

  @override
  void initState() {
    super.initState();
    _wardNameToId[widget.ward.wardName] = widget.ward.wardId;
    _selectedWardFilter = _isTalukaLevelSearch ? 'All Wards' : widget.ward.wardName;
    _fetchWards();
    _searchUsers('');
  }

  Future<void> _fetchWards() async {
    try {
      final res = await WardAPI().getAllWards();
      if (res != null && res['success'] == true) {
        final List data = res['data'] ?? [];
        final filtered = data.where((w) => w['talukaId'] == widget.ward.talukaId).toList();
        
        final Map<String, String> nameToId = {};
        final List<String> names = [];
        for (var w in filtered) {
           final n = w['wardName'] as String;
           final id = w['wardId'] as String;
           nameToId[n] = id;
           if (!names.contains(n)) names.add(n);
        }
        names.sort();

        if (mounted) {
          setState(() {
            _wardNameToId.addAll(nameToId);
            _availableWards = names;
            if (!_availableWards.contains(_selectedWardFilter) && _selectedWardFilter != 'All Wards') {
              _availableWards.add(_selectedWardFilter);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('DEV DEBUG - _fetchWards error: $e');
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() { _isSearching = true; });
    try {
      final token = SessionManager.token;

      // Match the web app exactly (AssignPositionModal + the searchMembers
      // thunk in areaChartSlice.js): candidate search ALWAYS goes through
      // POST /userprofile/search-users for every slot type. The web never
      // branches to ucn-members/getMngtMembers/getAllPatrons/
      // getAllChannelPartners here -- those endpoints return nested
      // "designation holder" records ({assignmentId, designation,
      // holder:{user:{...}}}) meant for the read-only area-chart display,
      // not flat user records, which is why using them here produced
      // "Unknown" names, empty Core Team results, and 400s on assign.
      final ward = _selectedWardFilter == 'All Wards' ? '' : _selectedWardFilter;
      final wardId = ward.isNotEmpty ? _wardNameToId[ward] : '';
      final talukaId = widget.ward.talukaId ?? '';
      final talukaName = widget.ward.taluka;
      final districtId = SessionManager.user?['districtId']?.toString() ?? '';
      final districtName = widget.ward.district;

      final payload = {
        'name': query,
        if (ward.isNotEmpty) 'ward': ward,
        if (wardId != null && wardId.isNotEmpty) 'wardId': wardId,
        if (talukaId.isNotEmpty) 'talukaId': talukaId,
        if (talukaName.isNotEmpty) 'taluka': talukaName,
        if (districtId.isNotEmpty) 'districtId': districtId,
        if (districtName.isNotEmpty) 'district': districtName,
      };

      debugPrint('DEV DEBUG - AssignMemberScreen - Search API POST Request Payload: $payload');

      final res = await http.post(
        Uri.parse('https://backend.udyamikutumba.com/userprofile/search-users'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      debugPrint('DEV DEBUG - AssignMemberScreen - Search API Response Status: ${res.statusCode}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          List<dynamic> fetchedData = data['data'] ?? [];

          // The search-users API sometimes returns nested assignment objects (holder.user)
          // or wrapped user objects depending on the exact payload/role.
          fetchedData = fetchedData.map((item) {
            if (item is Map) {
              if (item.containsKey('holder') && item['holder'] is Map && item['holder']['user'] is Map) {
                final u = Map<String, dynamic>.from(item['holder']['user']);
                u['designation'] = item['designation'];
                u['assignmentId'] = item['assignmentId'];
                u['isAssigned'] = item['isAssigned'] ?? u['isAssigned'];
                // Add assignedTo mapping to match UI logic
                u['assignedWard'] = item['ward']?['wardName'];
                if (item['designation'] != null) {
                  u['positionHolder'] = {
                    'position': {
                      'positionName': item['designation']['designationName']
                    }
                  };
                }
                return u;
              } else if (item.containsKey('user') && item['user'] is Map && !item.containsKey('userId')) {
                 // Only unwrap if 'userId' is not at the root level alongside 'user', avoiding double-unwrapping
                final u = Map<String, dynamic>.from(item['user']);
                u['isAssigned'] = item['isAssigned'] ?? u['isAssigned'];
                return u;
              }
            }
            return item;
          }).toList();

          // Safety net: in case the backend doesn't narrow by `ward`
          // server-side, also filter locally using whatever ward info the
          // response carries. Entries with no ward info at all are kept,
          // since we can't tell either way for them.
          if (ward.isNotEmpty) {
            final wardFilterLower = ward.toLowerCase();
            fetchedData = fetchedData.where((m) {
              final wardVal = m['profile']?['ward'] ?? m['ward'] ?? m['wardName'];
              if (wardVal == null) return true;
              return wardVal.toString().toLowerCase() == wardFilterLower;
            }).toList();
          }

          setState(() { _searchResults = fetchedData; });
          if (_searchResults.isNotEmpty) {
            debugPrint('DEV DEBUG - AssignMemberScreen - First User JSON: ' + jsonEncode(_searchResults.first));
          }
        } else {
          debugPrint('DEV DEBUG - AssignMemberScreen - Search API Failed Body: ${res.body}');
        }
      } else {
        debugPrint('DEV DEBUG - AssignMemberScreen - Search API Failed Body: ${res.body}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
    setState(() { _isSearching = false; });
  }

  Future<void> _assignUser(dynamic user) async {
    try {
      String userType = 'Member';
      if (widget.slotId == 'mla') userType = 'MLA';
      else if (widget.slotId == 'ward-chairman') userType = 'WardChairman';
      else if (widget.slotId.startsWith('official-')) userType = 'Official';
      else if (widget.slotId.startsWith('patron-')) userType = 'Patron';
      else if (widget.slotId.startsWith('chairman-')) userType = 'Chairman';
      else if (widget.slotId.startsWith('advisory-')) userType = 'Advisory';
      else if (widget.slotId.startsWith('mentor-')) userType = 'Mentor';
      else if (widget.slotId.startsWith('core-')) userType = 'CoreTeam';
      else if (widget.slotId.startsWith('sector-')) userType = 'Sector';
      else if (widget.slotId.startsWith('ums-')) userType = 'UMS';

      final currentUser = SessionManager.user;
      final payload = {
        'wardHeadId': widget.wardHeadId,
        'wardId': widget.ward.wardId,
        'ward': widget.ward.wardName,
        'members': [
          {
            'userId': user['userId'],
            'memberId': user['userId'],
            'userType': userType,
            'status': 'Active',
            'name': user['name'],
            'mobileNumber': user['mobileNumber'],
            'email': user['email'],
            'companyName': user['companyName'],
            'profileImage': user['profileImage'],
            'slotId': widget.slotId,
            'slotLabel': widget.slotLabel,
            'isAssigned': true,
            'assignedBy': currentUser?['userId'] ?? currentUser?['memberId'],
          }
        ]
      };
      
      // Additional specific keys mapped as per guide
      if (widget.slotId.startsWith('core-')) {
        String role = 'Member';
        if (widget.slotId.contains('president')) role = 'President';
        else if (widget.slotId.contains('vice')) role = 'Vice-President';
        else if (widget.slotId.contains('secretary')) role = 'General Secretary';
        else if (widget.slotId.contains('treasurer')) role = 'Treasurer';
        (payload['members'] as List)[0]['coreRole'] = role;
      } else if (widget.slotId.startsWith('sector-')) {
        (payload['members'] as List)[0]['sectorKey'] = widget.slotId.replaceFirst('sector-', '');
      } else if (widget.slotId.startsWith('ums-')) {
        (payload['members'] as List)[0]['umsKey'] = widget.slotId.replaceFirst('ums-', '');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.udyamikutumba.com/ward-chart/createWardChartData'),
      );
      
      if (SessionManager.token != null) {
        request.headers['Authorization'] = 'Bearer ${SessionManager.token}';
      }
      
      // Web sends the entire JSON as a string inside the 'data' field of FormData
      request.fields['data'] = jsonEncode(payload);

      debugPrint('DEV DEBUG - AssignMemberScreen - Assign API Request: ${request.fields['data']}');

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      
      debugPrint('DEV DEBUG - AssignMemberScreen - Assign API Response Status: ${res.statusCode} | Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['success'] == true || data['success'] == 'true') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member assigned successfully!')));
            Navigator.pop(context, true); // true indicates refresh needed
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed to assign member.')));
          }
        }
      } else {
        String errMsg = 'Failed: ${res.statusCode} - ${res.reasonPhrase}';
        try {
          final errData = jsonDecode(res.body);
          if (errData is Map && errData['message'] != null) {
            errMsg = errData['message'].toString();
          }
        } catch (_) {}

        if (res.statusCode == 409) {
          // Backend says this user already holds a slot elsewhere; reflect
          // that locally so their button flips to "Assigned" right away.
          final targetId = (user['userId'] ?? user['memberId'])?.toString();
          if (targetId != null && mounted) {
            setState(() {
              _searchResults = _searchResults.map((m) {
                if ((m['userId'] ?? m['memberId'])?.toString() == targetId) {
                  return {...m as Map<String, dynamic>, 'isAssigned': true};
                }
                return m;
              }).toList();
            });
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg)));
        }
      }
    } catch (e) {
      debugPrint('Assign error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error assigning member.')));
      }
    }
  }

  Future<void> _removeMember(String memberId) async {
    try {
      final res = await http.delete(
        Uri.parse('https://backend.udyamikutumba.com/ward-chart/deleteWardChartMember/$memberId'),
        headers: {
          if (SessionManager.token != null) 'Authorization': 'Bearer ${SessionManager.token}',
        },
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member removed successfully!')));
        Navigator.pop(context, true);
      }
    } catch (e) {}
  }

  List<dynamic> get _filteredResults {
    final query = _searchCtrl.text.toLowerCase().trim();
    if (query.isEmpty) return _searchResults;
    return _searchResults.where((m) {
      final name = (m['name'] ?? '').toString().toLowerCase();
      final mobile = (m['mobileNumber'] ?? '').toString().toLowerCase();
      final email = (m['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || mobile.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEV DEBUG - AssignMemberScreen build: _availableWards=$_availableWards, slotId=${widget.slotId}');
    final results = _filteredResults;
    return Scaffold(
      appBar: AppBar(title: Text('Assign: ${widget.slotLabel}')),
      body: Column(
        children: [
          if (widget.assignedUser != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Currently Assigned', style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.assignedUser!['name'] ?? widget.assignedUser!['assignedUserName'] ?? widget.assignedUser!['fullName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (widget.assignedUser!['mobileNumber'] != null)
                          Text(widget.assignedUser!['mobileNumber'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _removeMember(widget.assignedUser!['memberId'] ?? widget.assignedUser!['userId'] ?? ''),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Remove', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  ),
                ],
              ),
            ),
            if (_isTalukaLevelSearch && _availableWards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedWardFilter.isNotEmpty && _availableWards.contains(_selectedWardFilter) 
                      ? _selectedWardFilter 
                      : (_availableWards.contains('All Wards') ? 'All Wards' : null),
                  decoration: InputDecoration(
                    labelText: 'Filter by Ward',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: 'All Wards', child: Text('All Wards')),
                    ..._availableWards.where((w) => w != 'All Wards').map((w) => DropdownMenuItem(value: w, child: Text(w))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedWardFilter = val);
                      _searchUsers(_searchCtrl.text);
                    }
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                setState(() {});
                // Optionally you could add debounce here, but for now we'll trigger on submit to save API calls
              },
              onSubmitted: (val) => _searchUsers(val),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by name or number...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _searchUsers(_searchCtrl.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_isSearching) const LinearProgressIndicator(),
            Expanded(
            child: results.isEmpty && !_isSearching
                ? const Center(child: Text('No members found. Try searching.'))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];
                      
                      // Check if user is already assigned to a ward
                      bool isAssigned = false;
                      String? assignedTo;
                      
                      // Check if they are already assigned to THIS EXACT SLOT
                      if (widget.assignedUser != null) {
                        final currentId = widget.assignedUser!['userId'] ?? widget.assignedUser!['memberId'];
                        final searchId = user['userId'] ?? user['memberId'];
                        if (currentId != null && searchId != null && currentId == searchId) {
                          isAssigned = true;
                          assignedTo = widget.slotLabel;
                          debugPrint('DEV DEBUG - AssignMemberScreen - User ${user['name'] ?? searchId} is ALREADY assigned to THIS EXACT SLOT (${widget.slotLabel})');
                        }
                      }

                      // Search APIs (e.g. ucn-members) now return this flag
                      // directly on each member when they already hold a slot.
                      if (user['isAssigned'] == true && !isAssigned) {
                        isAssigned = true;
                        debugPrint('DEV DEBUG - AssignMemberScreen - User ${user['name'] ?? user['userId']} is marked as isAssigned: true directly from API');
                      }

                      if (user['positionHolder'] != null && user['positionHolder']['position'] != null) {
                        isAssigned = true;
                        assignedTo = user['positionHolder']['position']['positionName'];
                        debugPrint('DEV DEBUG - AssignMemberScreen - User ${user['name'] ?? user['userId']} already assigned to position: $assignedTo');
                      } else if (user['assignedWard'] != null && !isAssigned) {
                        isAssigned = true;
                        assignedTo = user['assignedWard'].toString();
                        debugPrint('DEV DEBUG - AssignMemberScreen - User ${user['name'] ?? user['userId']} already assigned to ward: $assignedTo');
                      } else if (user['wardChartId'] != null && !isAssigned) {
                        isAssigned = true;
                        assignedTo = 'a Ward Chart';
                        debugPrint('DEV DEBUG - AssignMemberScreen - User ${user['name'] ?? user['userId']} already assigned to Ward Chart (wardChartId)');
                      } else if (user['wardCharts'] != null && (user['wardCharts'] as List).isNotEmpty && !isAssigned) {
                        isAssigned = true;
                        assignedTo = 'a Ward Chart';
                        debugPrint('DEV DEBUG - AssignMemberScreen - User ${user['name'] ?? user['userId']} already assigned to Ward Chart (wardCharts array)');
                      }

                      return ListTile(
                        leading: Builder(
                          builder: (context) {
                            final photoUrl = (user['profileImage'] ?? user['photoUrl'] ?? user['businessImage1']) as String?;
                            final name = (user['name'] ?? user['assignedUserName'] ?? user['fullName'] ?? 'Unknown') as String;
                            Widget fallback = Text(name.isNotEmpty && name != 'Unknown' ? name[0].toUpperCase() : '?');
                            
                            if (photoUrl == null || photoUrl.isEmpty) {
                              return CircleAvatar(child: fallback);
                            }
                            
                            ImageProvider? provider;
                            if (photoUrl.startsWith('data:')) {
                              try {
                                final base64String = photoUrl.split(',').last;
                                provider = MemoryImage(const Base64Decoder().convert(base64String));
                              } catch (e) {}
                            } else {
                              provider = NetworkImage(photoUrl);
                            }
                            
                            return CircleAvatar(
                              backgroundImage: provider,
                              child: provider == null ? fallback : null,
                            );
                          },
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text((user['name'] ?? user['assignedUserName'] ?? user['fullName'] ?? 'Unknown'), overflow: TextOverflow.ellipsis)),
                            if (isAssigned) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Assigned', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['mobileNumber'] ?? user['mobile'] ?? ''),
                            if (isAssigned && assignedTo != null)
                              Text(
                                'Already in: $assignedTo',
                                style: TextStyle(fontSize: 11, color: Colors.red.shade400),
                              ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: isAssigned ? null : () => _assignUser(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAssigned ? Colors.grey.shade300 : Theme.of(context).colorScheme.primary,
                            foregroundColor: isAssigned ? Colors.grey.shade600 : Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(isAssigned ? 'Assigned' : 'Assign'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
