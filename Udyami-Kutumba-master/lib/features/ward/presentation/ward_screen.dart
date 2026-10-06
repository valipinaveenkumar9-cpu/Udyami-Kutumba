import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/location/location_api.dart';
import '../../../core/api/area/dashboard_api.dart';
import '../../../core/api/directory/directory_api.dart';
import '../../../core/api/area/taluka_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/ward_member_model.dart';
import '../../../core/models/ward_model.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../dashboard/presentation/communications_management_dashboard_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../dashboard/presentation/job_management_dashboard_screen.dart';
import '../../dashboard/presentation/members_list_screen.dart';
import '../../dashboard/presentation/news_management_dashboard_screen.dart';
import 'member_map_screen.dart';
import '../../dashboard/presentation/ucn_dashboard_screen.dart';
import '../../dashboard/presentation/manage_roles_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'area_chart_screen.dart';

class WardFilterScreen extends StatefulWidget {
  const WardFilterScreen({super.key});

  @override
  State<WardFilterScreen> createState() => _WardFilterScreenState();
}

class _WardFilterScreenState extends State<WardFilterScreen> {
  final WardAPI _wardAPI = WardAPI();
  final LocationAPI _locationAPI = LocationAPI();
  bool _isLoading = true;
  List<WardModel> _allWards = [];

  List<Map<String, dynamic>> _apiDistricts = [];
  List<Map<String, dynamic>> _apiTalukas = [];

  bool _isLoadingMembers = false;
  List<WardMemberModel> _wardMembers = [];

  // Dropdown options
  List<String> _states = ['Karnataka'];
  List<String> _districts = [];
  List<String> _talukas = [];
  List<WardModel> _wards = [];

  // Mapping cache
  List<UserModel> _allRoleUsers = [];
  final Map<String, String> _wardIdToHeadIdMap = {};

  // Selected values
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedWardId;
  String? _registeredWardId;
  String? _registeredState;
  String? _registeredDistrict;
  String? _registeredTaluka;

  // RBAC Variables
  bool _isDistrictHead = false;
  bool _isTalukaHead = false;
  bool _isWardHead = false;

  bool _isSuperAdmin = false;
  bool _isChannelPartner = false;
  bool _isCircleLeader = false;
  bool _isSectorHead = false;
  bool _isUcnMember = false;

  bool _isStateLocked = false;
  bool _isDistrictLocked = false;
  bool _isTalukaLocked = false;
  bool _isWardLocked = false;

  @override
  void initState() {
    super.initState();
    _initData();
    SessionManager.profileUpdateNotifier.addListener(_onProfileUpdated);
  }

  Future<void> _initData() async {
    final totalSw = Stopwatch()..start();
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _fetchDistricts(),
      _fetchWards(),
      _fetchUserProfile(),
      _fetchAllRoleUsers(),
    ]);

    if (_registeredWardId != null &&
        _registeredWardId!.isNotEmpty &&
        _registeredWardId!.length < 30) {
      try {
        final sw1 = Stopwatch()..start();
        final allWardsRes = await WardAPI().getAllWards(
          wardName: _registeredWardId,
        );
        print('DEV DEBUG - API Load Time - WardAPI.getAllWards(wardName: $_registeredWardId) network call took ${(sw1.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        if (allWardsRes != null && allWardsRes['success'] == true) {
          final List wardsList = allWardsRes['data'] ?? [];
          if (wardsList.isNotEmpty) {
            final wardData = wardsList.first;
            _registeredWardId =
                wardData['wardId']?.toString() ?? _registeredWardId;

            if (_allWards.isEmpty) {
              _allWards.add(
                WardModel.fromJson(wardData as Map<String, dynamic>),
              );
            }
          }
        }
        sw1.stop();
        print('DEV DEBUG - API Load Time - WardAPI.getAllWards(wardName: $_registeredWardId) total took ${(sw1.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      } catch (e) {
        print("DEV DEBUG - Failed to resolve _registeredWardId to UUID: $e");
      }
    } else if (_registeredWardId != null && _allWards.isNotEmpty) {
      try {
        final ward = _allWards.firstWhere(
          (w) =>
              w.wardId == _registeredWardId || w.wardName == _registeredWardId,
        );
        _registeredWardId = ward.wardId;
      } catch (_) {}
    }

    _applyRoleBasedLocks();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      totalSw.stop();
      print('DEV DEBUG - API Load Time - _initData total flow till UI displayed took ${(totalSw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    }
  }

  void _onProfileUpdated() {
    print("DEV DEBUG - WardScreen: Profile update detected, refreshing...");
    _initData();
  }

  @override
  void dispose() {
    SessionManager.profileUpdateNotifier.removeListener(_onProfileUpdated);
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    final sw = Stopwatch()..start();
    try {
      final user = SessionManager.user;
      if (user == null || user['userId'] == null) {
        print(
          "DEV DEBUG - _fetchUserProfile: No user found in SessionManager.",
        );
        return;
      }
      final userId = user['userId'].toString();

      // Parse user roles
      final userModel = UserModel.fromJson(user);
      _isDistrictHead = userModel.roles.any(
        (r) => r.roleName.toLowerCase().contains('district'),
      );
      _isTalukaHead = userModel.roles.any(
        (r) =>
            r.roleName.toLowerCase().contains('taluka') ||
            r.roleName.toLowerCase().contains('taluk'),
      );
      _isWardHead = userModel.roles.any(
        (r) =>
            r.roleName.toLowerCase().contains('ward_head') ||
            r.roleName.toLowerCase().contains('ward_chairman'),
      );
      _isSuperAdmin = userModel.roles.any(
        (r) => r.roleName.toLowerCase() == 'super_admin',
      );
      _isChannelPartner = userModel.roles.any(
        (r) => r.roleName.toLowerCase() == 'channel_partner',
      );
      _isCircleLeader = userModel.roles.any(
        (r) => r.roleName.toLowerCase() == 'circle_leader',
      );
      _isSectorHead = userModel.roles.any(
        (r) => r.roleName.toLowerCase() == 'sector_head',
      );
      _isUcnMember = userModel.roles.any(
        (r) => r.roleName.toLowerCase() == 'ucn_member',
      );

      final profileAPI = ProfileAPI();
      final response = await profileAPI.getUserProfileById(userId);
      print('DEV DEBUG - API Load Time - _fetchUserProfile(userId: $userId) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      if (response != null && response['success'] == true) {
        print(
          "DEV DEBUG - _fetchUserProfile: Fetched profile data successfully.",
        );
        final profileData = response['data']?['profile'] ?? response['data'];

        dynamic wData = profileData?['ward'];
        final wardId = wData is Map ? (wData['_id'] ?? wData['wardId']) : wData;

        final state = profileData?['state'];

        dynamic dData = profileData?['district'];
        final district = dData is Map
            ? dData['districtName']
            : (dData ??
                  profileData?['districtName'] ??
                  user?['districtName'] ??
                  user?['district']);

        dynamic tData = profileData?['taluka'];
        final taluka =
            profileData?['assembly'] ??
            (tData is Map ? tData['talukaName'] : tData) ??
            user?['talukaName'] ??
            user?['taluka'];

        if (mounted) {
          setState(() {
            if (wardId != null && wardId.toString().isNotEmpty) {
              print(
                "DEV DEBUG - _fetchUserProfile: Found user's registered ward ID: $wardId",
              );
              _registeredWardId = wardId.toString();
            } else {
              print(
                "DEV DEBUG - _fetchUserProfile: No registered ward found in user profile.",
              );
            }
            if (state != null) _registeredState = state.toString();
            if (district != null) _registeredDistrict = district.toString();
            if (taluka != null) _registeredTaluka = taluka.toString();
          });
        }
      } else {
        print(
          "DEV DEBUG - _fetchUserProfile: Failed to fetch profile data. Response: $response",
        );
      }
      sw.stop();
      print('DEV DEBUG - API Load Time - _fetchUserProfile(userId: $userId) total (including parsing/setState) took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    } catch (e) {
      print("DEV DEBUG - Error fetching profile: $e");
    }
  }

  void _applyRoleBasedLocks() {
    if (!mounted) return;

    setState(() {
      if (_isSuperAdmin) {
        // State Head: Locked to State
        _isStateLocked = true;
        _selectedState = _registeredState ?? 'Karnataka';
        _isDistrictLocked = false;
        _isTalukaLocked = false;
        _isWardLocked = false;
        _districts =
            _apiDistricts
                .map((d) => d['districtName']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
      } else if (_isChannelPartner ||
          _isCircleLeader ||
          _isSectorHead ||
          _isUcnMember) {
        _isStateLocked = false;
        _isDistrictLocked = false;
        _isTalukaLocked = false;
        _isWardLocked = false;
        _districts =
            _apiDistricts
                .map((d) => d['districtName']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
      } else if (_isDistrictHead) {
        // District Head: Locked to District
        _isStateLocked = true;
        _isDistrictLocked = true;
        _isTalukaLocked = false;
        _isWardLocked = false;

        if (_registeredDistrict != null) {
          _selectedState = _registeredState ?? 'Karnataka';
          _districts =
              _apiDistricts
                  .map((d) => d['districtName']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

          _selectedDistrict = _registeredDistrict;
          if (_apiTalukas.isNotEmpty) {
            _talukas =
                _apiTalukas
                    .map((t) => t['talukaName']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
          } else {
            _talukas =
                _allWards
                    .where(
                      (w) =>
                          w.state == _selectedState &&
                          w.district == _selectedDistrict,
                    )
                    .map((w) => w.taluka)
                    .toSet()
                    .toList()
                  ..sort();
          }

          if (_selectedTaluka != null) {
            _wards =
                _allWards
                    .where(
                      (w) =>
                          w.state == _selectedState &&
                          w.district == _selectedDistrict &&
                          w.taluka == _selectedTaluka,
                    )
                    .toList()
                  ..sort(
                    (a, b) => (int.tryParse(a.wardNumber) ?? 0).compareTo(
                      int.tryParse(b.wardNumber) ?? 0,
                    ),
                  );
          } else {
            _wards =
                _allWards
                    .where(
                      (w) =>
                          w.state == _selectedState &&
                          w.district == _selectedDistrict,
                    )
                    .toList()
                  ..sort(
                    (a, b) => (int.tryParse(a.wardNumber) ?? 0).compareTo(
                      int.tryParse(b.wardNumber) ?? 0,
                    ),
                  );
          }
        } else {
          _selectedState = _registeredState ?? 'Karnataka';
          _isDistrictLocked = false;
          _districts =
              _apiDistricts
                  .map((d) => d['districtName']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
        }
      } else if (_isTalukaHead) {
        // Taluka Head: Locked to Taluka
        _isStateLocked = true;
        _isDistrictLocked = true;
        _isTalukaLocked = true;
        _isWardLocked = false;

        if (_registeredDistrict != null && _registeredTaluka != null) {
          _selectedState = _registeredState ?? 'Karnataka';
          _districts =
              _apiDistricts
                  .map((d) => d['districtName']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

          _selectedDistrict = _registeredDistrict;
          if (_apiTalukas.isNotEmpty) {
            _talukas =
                _apiTalukas
                    .map((t) => t['talukaName']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
          } else {
            _talukas =
                _allWards
                    .where(
                      (w) =>
                          w.state == _selectedState &&
                          w.district == _selectedDistrict,
                    )
                    .map((w) => w.taluka)
                    .toSet()
                    .toList()
                  ..sort();
          }

          _selectedTaluka = _registeredTaluka;
          _wards =
              _allWards
                  .where(
                    (w) =>
                        w.state == _selectedState &&
                        w.district == _selectedDistrict &&
                        w.taluka.toLowerCase().trim() ==
                            _selectedTaluka!.toLowerCase().trim(),
                  )
                  .toList()
                ..sort((a, b) => a.wardName.compareTo(b.wardName));
        } else {
          _selectedState = _registeredState ?? 'Karnataka';
          _isDistrictLocked = false;
          _isTalukaLocked = false;
          _districts =
              _apiDistricts
                  .map((d) => d['districtName']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
        }
      } else {
        // Ward Head or Normal Member: Locked to Registered Ward
        _isStateLocked = true;
        _isDistrictLocked = true;
        _isTalukaLocked = true;
        _isWardLocked = true;

        if (_registeredWardId != null) {
          WardModel? match;
          try {
            match = _allWards.firstWhere((w) => w.wardId == _registeredWardId);
          } catch (_) {}

          if (match != null) {
            _selectedState = match.state;
            _districts =
                _apiDistricts
                    .map((d) => d['districtName']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();

            _selectedDistrict = match.district;
            if (_apiTalukas.isNotEmpty) {
              _talukas =
                  _apiTalukas
                      .map((t) => t['talukaName']?.toString() ?? '')
                      .where((s) => s.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
            } else {
              _talukas =
                  _allWards
                      .where(
                        (w) =>
                            w.state == _selectedState &&
                            w.district == _selectedDistrict,
                      )
                      .map((w) => w.taluka)
                      .toSet()
                      .toList()
                    ..sort();
            }

            _selectedTaluka = match.taluka;
            _wards =
                _allWards
                    .where(
                      (w) =>
                          w.state == _selectedState &&
                          w.district == _selectedDistrict &&
                          w.taluka == _selectedTaluka,
                    )
                    .toList()
                  ..sort((a, b) => a.wardName.compareTo(b.wardName));

            if (_isWardHead) {
              _selectedWardId = _registeredWardId;
              _fetchWardMembers(_selectedWardId!);
            }
          }
        } else if (_isWardHead) {
          _selectedState = _registeredState ?? 'Karnataka';
          _isDistrictLocked = false;
          _isTalukaLocked = false;
          _isWardLocked = false;
          _districts =
              _apiDistricts
                  .map((d) => d['districtName']?.toString() ?? '')
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
        }
      }
    });
  }

  Future<void> _fetchDistricts() async {
    final sw = Stopwatch()..start();
    try {
      final response = await _locationAPI.getAllDistricts();
      print('DEV DEBUG - API Load Time - _fetchDistricts network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      if (response != null && response['success'] == true) {
        final List rawData = response['data'] ?? [];
        _apiDistricts = rawData.cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            _districts =
                _apiDistricts
                    .map((d) => d['districtName']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();
          });
        }
      }
      sw.stop();
      print('DEV DEBUG - API Load Time - _fetchDistricts total (including parsing/setState) took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    } catch (e) {
      print("DEV DEBUG - Failed to fetch districts: $e");
    }
  }

  Future<void> _fetchWards() async {
    final sw = Stopwatch()..start();
    final response = await _wardAPI.getAllWards();
    print('DEV DEBUG - API Load Time - _fetchWards network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    if (response != null && response['success'] == true) {
      final List rawData = response['data'] ?? [];
      _allWards = rawData
          .map((w) => WardModel.fromJson(w as Map<String, dynamic>))
          .toList();

      // Debug print taluka-based wards
      final taluka = _selectedTaluka ?? _registeredTaluka ?? '';
      final talukaWards = taluka.isNotEmpty
          ? _allWards
                .where(
                  (w) =>
                      w.taluka.toLowerCase().trim() ==
                      taluka.toLowerCase().trim(),
                )
                .toList()
          : _allWards;
      print(
        'DEV DEBUG - Total wards fetched: ${_allWards.length} | Taluka "$taluka" wards: ${talukaWards.length}',
      );
      for (var i = 0; i < talukaWards.length; i++) {
        final ward = talukaWards[i];
        print(
          'DEV DEBUG - $taluka\'s Ward - ${ward.wardName} (ID: ${ward.wardId})',
        );
      }

      // Run comprehensive background diagnostic to print all 22 wards
      // _debugAllWards();
    }
    sw.stop();
    print('DEV DEBUG - API Load Time - _fetchWards total (including parsing) took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
  }

  Future<void> _fetchAllRoleUsers() async {
    final sw = Stopwatch()..start();
    try {
      final usersResponse = await _wardAPI.getAllRoleUsers();
      print('DEV DEBUG - API Load Time - _fetchAllRoleUsers network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      if (usersResponse != null && usersResponse['success'] == true) {
        final List rawUsers = usersResponse['data'] ?? [];
        _allRoleUsers = rawUsers
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();

        // Pre-populate ward map to show ward heads in lists without clicking
        for (var user in _allRoleUsers) {
          for (var role in user.roles) {
            if ((role.roleName.toLowerCase() == 'ward_chairman' ||
                    role.roleName.toLowerCase() == 'ward_head') &&
                role.wardId != null) {
              _wardIdToHeadIdMap[role.wardId!] = user.userId;
            }
          }
        }
      }
      sw.stop();
      print('DEV DEBUG - API Load Time - _fetchAllRoleUsers total (including parsing) took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    } catch (e) {
      print("DEV DEBUG - Failed to fetch all role users: $e");
    }
  }

  String? _extractWardIdFromResponse(dynamic locRes) {
    if (locRes == null || locRes is! Map) return null;
    final data = locRes['data'];
    if (data is Map) {
      if (data['wardDetails'] is Map) {
        final id = data['wardDetails']['wardId'] ?? data['wardDetails']['id'];
        if (id != null) return id.toString();
      }
      if (data['ward'] is Map) {
        final id = data['ward']['wardId'] ?? data['ward']['id'];
        if (id != null) return id.toString();
      }
      if (data['wardId'] != null) {
        return data['wardId'].toString();
      }
    }
    if (locRes['wardDetails'] is Map) {
      final id = locRes['wardDetails']['wardId'] ?? locRes['wardDetails']['id'];
      if (id != null) return id.toString();
    }
    if (locRes['ward'] is Map) {
      final id = locRes['ward']['wardId'] ?? locRes['ward']['id'];
      if (id != null) return id.toString();
    }
    return null;
  }

  Future<void> _debugAllWards() async {
    print('\n\n======================================================');
    print('DEV DEBUG - STARTING COMPREHENSIVE WARD DIAGNOSTIC RUN');
    print('======================================================');

    // First, make sure we have all role users
    if (_allRoleUsers.isEmpty) {
      final usersResponse = await _wardAPI.getAllRoleUsers();
      if (usersResponse != null && usersResponse['success'] == true) {
        final List rawUsers = usersResponse['data'] ?? [];
        _allRoleUsers = rawUsers
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
      }
    }

    final wardChairmen = _allRoleUsers.where((u) {
      return u.roles.any(
        (r) =>
            r.roleName.toLowerCase() == 'ward_chairman' ||
            r.roleName.toLowerCase() == 'ward_head',
      );
    }).toList();

    print(
      'DEV DEBUG - Found ${wardChairmen.length} users with Chairman/Head roles.',
    );

    // Build map for ALL chairmen
    for (var chairman in wardChairmen) {
      try {
        // _debugAllWards is just a debug function. Since we don't know the wardId here, we skip fetching for this debug log.
      } catch (_) {}
    }

    print(
      'DEV DEBUG - Successfully mapped ${_wardIdToHeadIdMap.length} Wards to a Head/Chairman.',
    );

    for (var ward in _allWards) {
      print(
        '\n--- CHECKING WARD: ${ward.wardName} (No. ${ward.wardNumber}) ---',
      );
      final headId = _wardIdToHeadIdMap[ward.wardId];
      if (headId == null) {
        print(
          '  -> NO WARD HEAD ASSIGNED IN DB (Therefore, 0 members possible).',
        );
      } else {
        print('  -> WARD HEAD ID: $headId');
        try {
          final response = await _wardAPI.getWardMembers(headId, ward.wardId);
          if (response != null && response['success'] == true) {
            final rawData = response['data'] ?? {};
            if (rawData is Map && rawData['members'] is Map) {
              final Map membersMap = rawData['members'];
              if (membersMap.isEmpty) {
                print(
                  '  -> API RESPONSE SUCCESS, BUT "members" JSON IS EMPTY {}. (0 members)',
                );
              } else {
                int totalMembers = 0;
                print('  -> API RETURNED MEMBERS DATA:');
                for (var entry in membersMap.entries) {
                  final role = entry.key;
                  final list = entry.value;
                  if (list is List) {
                    print('     - Role: "$role" has ${list.length} members.');
                    totalMembers += list.length;
                    for (var m in list) {
                      print(
                        '         * Name: ${m['name']}, MemberID: ${m['memberId']}',
                      );
                    }
                  }
                }
                print('  -> TOTAL WARD MEMBERS PARSED: $totalMembers');
              }
            } else {
              print(
                '  -> UNEXPECTED API RESPONSE FORMAT: ${rawData['members']}',
              );
            }
          } else {
            print('  -> API CALL FAILED OR RETURNED SUCCESS:FALSE');
          }
        } catch (e) {
          print('  -> EXCEPTION CALLING API: $e');
        }
      }
    }

    print('======================================================');
    print('DEV DEBUG - END COMPREHENSIVE WARD DIAGNOSTIC RUN');
    print('======================================================\n\n');
  }

  void _onStateChanged(String? state) {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _selectedTaluka = null;
      _selectedWardId = null;
      _wardMembers = [];

      _districts = _apiDistricts
          .map((d) => d['districtName']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      _districts.sort();

      _talukas = [];
      _wards = [];
    });
  }

  Future<void> _onDistrictChanged(String? district) async {
    setState(() {
      _selectedDistrict = district;
      _selectedTaluka = null;
      _selectedWardId = null;
      _wardMembers = [];
      _talukas = [];
      _wards = [];
    });

    if (district != null) {
      final districtMap = _apiDistricts.firstWhere(
        (d) => d['districtName'] == district,
        orElse: () => {},
      );
      final districtId = districtMap['districtId']?.toString();

      if (districtId != null && districtId.isNotEmpty) {
        try {
          final sw = Stopwatch()..start();
          final response = await _locationAPI.getAllDistricts(districtId: districtId);
          print('DEV DEBUG - API Load Time - _onDistrictChanged(_locationAPI.getAllDistricts(districtId: $districtId)) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
          if (response != null && response['success'] == true) {
            final List rawData = response['data'] ?? [];
            _apiTalukas = rawData.cast<Map<String, dynamic>>();
            if (mounted) {
              setState(() {
                _talukas =
                    _apiTalukas
                        .map((t) => t['talukaName']?.toString() ?? '')
                        .where((s) => s.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();
              });
            }
          }
          sw.stop();
          print('DEV DEBUG - API Load Time - _onDistrictChanged(_locationAPI.getAllDistricts(districtId: $districtId)) total took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        } catch (e) {
          print("DEV DEBUG - Failed to fetch talukas: $e");
        }
      }

      // Fallback in case API fails or returns nothing
      if (_talukas.isEmpty && mounted) {
        setState(() {
          final cmpState = _selectedState?.toLowerCase().trim();
          final cmpDist = district.toLowerCase().trim();
          _talukas = _allWards
              .where(
                (w) =>
                    w.state.toLowerCase().trim() == cmpState &&
                    w.district.toLowerCase().trim() == cmpDist,
              )
              .map((w) => w.taluka)
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList();
          _talukas.sort();
        });
      }
    }
  }

  Future<void> _onTalukaChanged(String? taluka) async {
    setState(() {
      _selectedTaluka = taluka;
      _selectedWardId = null;
      _wardMembers = [];
      _wards = [];
    });

    if (taluka != null) {
      final query = taluka.toLowerCase().trim();
      final talukaData = _apiTalukas.firstWhere(
        (t) =>
            (t['talukaName']?.toString().toLowerCase().trim() ?? '') == query,
        orElse: () => {},
      );

      if (talukaData.containsKey('wards') && talukaData['wards'] is List) {
        final List<dynamic> wardsList = talukaData['wards'];
        setState(() {
          _wards = wardsList.map((w) {
            return WardModel(
              wardId: w['wardId']?.toString() ?? w['id']?.toString() ?? '',
              wardName:
                  w['wardName']?.toString() ?? w['name']?.toString() ?? '',
              wardNumber: w['wardNumber']?.toString() ?? '',
              taluka: taluka,
              district: _selectedDistrict ?? '',
              state: _selectedState ?? '',
            );
          }).toList();
          _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
        });
      } else if (talukaData.containsKey('talukaId')) {
        final talukaId = talukaData['talukaId']?.toString();
        if (talukaId != null && talukaId.isNotEmpty) {
          try {
            final sw = Stopwatch()..start();
            final response = await DashboardAPI().fetchWardsByTaluka(talukaId);
            print('DEV DEBUG - API Load Time - _onTalukaChanged(DashboardAPI().fetchWardsByTaluka(talukaId: $talukaId)) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
            if (response != null && response['success'] == true) {
              final List rawData = response['data'] ?? [];
              if (rawData.isNotEmpty) {
                setState(() {
                  _wards = rawData.map((w) {
                    return WardModel.fromJson(w as Map<String, dynamic>);
                  }).toList();
                  _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
                });
              } else {
                // API returned 0 wards, fallback to _allWards string matching
                setState(() {
                  _wards = _allWards
                      .where((w) => w.taluka.toLowerCase().trim() == query)
                      .toList();
                  _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
                });
              }
            }
            sw.stop();
            print('DEV DEBUG - API Load Time - _onTalukaChanged(DashboardAPI().fetchWardsByTaluka(talukaId: $talukaId)) total took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
          } catch (e) {
            print("DEV DEBUG - Failed to fetch wards by taluka: $e");
            setState(() {
              _wards = _allWards
                  .where((w) => w.taluka.toLowerCase().trim() == query)
                  .toList();
              _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
            });
          }
        }
      } else {
        setState(() {
          _wards = _allWards
              .where((w) => w.taluka.toLowerCase().trim() == query)
              .toList();
          _wards.sort((a, b) => a.wardName.compareTo(b.wardName));
        });
      }

      // Preload taluka chairmen in background to populate _wardIdToHeadIdMap
      _resolveWardHeadViaTaluka(WardModel(
        wardId: '',
        wardName: '',
        district: _selectedDistrict ?? '',
        taluka: taluka,
        state: _selectedState ?? '',
        wardNumber: '',
        talukaId: talukaData['talukaId']?.toString(),
      ));
    }
  }

  Future<String?> _resolveWardHeadViaTaluka(WardModel ward) async {
    String? talukaId = ward.talukaId;
    if (talukaId == null || talukaId.isEmpty) {
      try {
        final match = _allWards.firstWhere(
          (w) =>
              w.taluka.toLowerCase().trim() == ward.taluka.toLowerCase().trim() &&
              w.talukaId != null &&
              w.talukaId!.isNotEmpty,
        );
        talukaId = match.talukaId;
      } catch (_) {}
    }

    if (talukaId == null || talukaId.isEmpty) {
      try {
        final tMatch = _apiTalukas.firstWhere(
          (t) =>
              (t['talukaName'] ?? '').toString().toLowerCase().trim() ==
              ward.taluka.toLowerCase().trim(),
          orElse: () => {},
        );
        talukaId = tMatch['talukaId']?.toString();
      } catch (_) {}
    }

    if (talukaId != null && talukaId.isNotEmpty) {
      try {
        final token = SessionManager.token;
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };
        final sw = Stopwatch()..start();
        final res = await http.get(
          Uri.parse('https://backend.udyamikutumba.com/talukas/getAllWardChaimansBy/$talukaId'),
          headers: headers,
        );
        sw.stop();
        print('DEV DEBUG - API Load Time - http.get(getAllWardChaimansBy/$talukaId) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          print('DEV DEBUG - API Load Time - http.get(getAllWardChaimansBy/$talukaId) total (including parsing) took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
          final List<dynamic> chairmenList = (decoded is Map && decoded['data'] is List)
              ? decoded['data']
              : (decoded is List ? decoded : []);

          for (var item in chairmenList) {
            if (item is Map) {
              final wId = (item['wardId'] ?? item['id'])?.toString();
              final wName = (item['wardName'] ?? item['ward_name'])?.toString().toLowerCase().trim();
              String? hId;

              if (item['wardChart'] is Map) {
                final wc = item['wardChart'];
                hId = wc['wardHeadId']?.toString() ??
                    wc['wardHead']?['userId']?.toString() ??
                    wc['wardHead']?['id']?.toString();
                if (hId == null && wc['members'] is Map) {
                  final list = wc['members']['WardChairman'] ?? wc['members']['wardChairman'];
                  if (list is List && list.isNotEmpty && list[0] is Map) {
                    hId = list[0]['userId']?.toString() ?? list[0]['memberId']?.toString();
                  }
                }
              }
              if (hId == null && item['wardHead'] is Map) {
                hId = item['wardHead']['userId']?.toString() ?? item['wardHead']['id']?.toString();
              }

              if (hId != null && hId.isNotEmpty) {
                if (wId != null && wId.isNotEmpty) {
                  _wardIdToHeadIdMap[wId] = hId;
                }
                if (wName != null && wName.isNotEmpty) {
                  for (var aw in _allWards) {
                    if (aw.wardName.toLowerCase().trim() == wName &&
                        aw.taluka.toLowerCase().trim() == ward.taluka.toLowerCase().trim()) {
                      _wardIdToHeadIdMap[aw.wardId] = hId;
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        print('DEV DEBUG - _resolveWardHeadViaTaluka error: $e');
      }
    }
    return _wardIdToHeadIdMap[ward.wardId];
  }

  Future<String?> _findWardHeadIdForWard(String targetWardId) async {
    print(
      'DEV DEBUG - _findWardHeadIdForWard: Looking up wardHeadId for wardId: $targetWardId',
    );
    if (_wardIdToHeadIdMap.containsKey(targetWardId)) {
      print(
        'DEV DEBUG - _findWardHeadIdForWard: Found existing mapping in cache: ${_wardIdToHeadIdMap[targetWardId]}',
      );
      return _wardIdToHeadIdMap[targetWardId];
    }

    try {
      final ward = _allWards.firstWhere(
        (w) => w.wardId == targetWardId,
        orElse: () => _wards.firstWhere(
          (w) => w.wardId == targetWardId,
          orElse: () => WardModel(
            wardId: targetWardId,
            wardName: '',
            district: '',
            taluka: _selectedTaluka ?? '',
            state: '',
            wardNumber: '',
          ),
        ),
      );
      if (ward.taluka.isNotEmpty) {
        final resolved = await _resolveWardHeadViaTaluka(ward);
        if (resolved != null && resolved.isNotEmpty) {
          print('DEV DEBUG - _findWardHeadIdForWard: Resolved via getAllWardChaimansBy: $resolved');
          return resolved;
        }
      }
    } catch (_) {}

    if (_allRoleUsers.isEmpty) {
      print(
        'DEV DEBUG - _findWardHeadIdForWard: _allRoleUsers is empty, fetching from API...',
      );
      final sw = Stopwatch()..start();
      final usersResponse = await _wardAPI.getAllRoleUsers();
      print('DEV DEBUG - API Load Time - _wardAPI.getAllRoleUsers() [in _findWardHeadIdForWard] network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      if (usersResponse != null && usersResponse['success'] == true) {
        final List rawUsers = usersResponse['data'] ?? [];
        _allRoleUsers = rawUsers
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
        sw.stop();
        print('DEV DEBUG - API Load Time - _wardAPI.getAllRoleUsers() [in _findWardHeadIdForWard] total took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        print(
          'DEV DEBUG - _findWardHeadIdForWard: Fetched ${_allRoleUsers.length} total users.',
        );
      }
    }

    final wardChairmen = _allRoleUsers.where((u) {
      return u.roles.any(
        (r) =>
            r.roleName.toLowerCase() == 'ward_chairman' ||
            r.roleName.toLowerCase() == 'ward_head',
      );
    }).toList();

    final unmappedChairmen = wardChairmen
        .where((c) => !_wardIdToHeadIdMap.containsValue(c.userId))
        .toList();
    print(
      'DEV DEBUG - _findWardHeadIdForWard: Found ${wardChairmen.length} ward chairmen in total, ${unmappedChairmen.length} are unmapped.',
    );

    for (var chairman in unmappedChairmen) {
      try {
        print(
          'DEV DEBUG - _findWardHeadIdForWard: Checking assigned ward for chairman ${chairman.userId}',
        );
        final swLoc = Stopwatch()..start();
        final locRes = await _wardAPI.getLocationByWardHeadId(
          chairman.userId,
          targetWardId,
        );
        print('DEV DEBUG - API Load Time - _wardAPI.getLocationByWardHeadId(chairman.userId: ${chairman.userId}, targetWardId: $targetWardId) network call took ${(swLoc.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        if (locRes != null && locRes['success'] == true) {
          final mappedWardId = _extractWardIdFromResponse(locRes);
          swLoc.stop();
          print('DEV DEBUG - API Load Time - _wardAPI.getLocationByWardHeadId(chairman.userId: ${chairman.userId}, targetWardId: $targetWardId) total took ${(swLoc.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
          if (mappedWardId != null) {
            print(
              'DEV DEBUG - _findWardHeadIdForWard: Chairman ${chairman.userId} is assigned to wardId: $mappedWardId',
            );
            _wardIdToHeadIdMap[mappedWardId] = chairman.userId;
            if (mappedWardId == targetWardId) {
              print(
                'DEV DEBUG - _findWardHeadIdForWard: MATCH FOUND! Returning wardHeadId: ${chairman.userId}',
              );
              return chairman.userId;
            }
          }
        }
      } catch (e) {
        print(
          'DEV DEBUG - _findWardHeadIdForWard: Error resolving ward location for chairman: $e',
        );
      }
    }

    // Help the user identify which wards ACTUALLY have heads mapped
    final availableWards = _wardIdToHeadIdMap.keys.map((wId) {
      final ward = _allWards.firstWhere(
        (w) => w.wardId == wId,
        orElse: () => WardModel(
          wardId: wId,
          wardName: 'Unknown',
          district: '',
          taluka: '',
          state: '',
          wardNumber: '',
        ),
      );
      return '${ward.wardName} (No. ${ward.wardNumber})';
    }).toList();

    print(
      'DEV DEBUG - _findWardHeadIdForWard: Finished checking all chairmen, NO MATCH FOUND for wardId: $targetWardId',
    );
    print(
      'DEV DEBUG - >>> ATTENTION: The ONLY wards in your database that currently have an assigned Ward Head are:\n  - ${availableWards.join('\n  - ')}\nDEV DEBUG - >>> Please select one of these wards in the dropdown!',
    );

    // Let's also fetch and print the exact member counts for these available wards to help the user!
    print(
      'DEV DEBUG - >>> Fetching member counts for all assigned wards to verify backend data...',
    );
    for (var entry in _wardIdToHeadIdMap.entries) {
      final wId = entry.key;
      final headId = entry.value;
      final ward = _allWards.firstWhere(
        (w) => w.wardId == wId,
        orElse: () => WardModel(
          wardId: wId,
          wardName: 'Unknown',
          district: '',
          taluka: '',
          state: '',
          wardNumber: '',
        ),
      );

      try {
        final swRes = Stopwatch()..start();
        final res = await _wardAPI.getWardMembers(headId, wId);
        print('DEV DEBUG - API Load Time - _wardAPI.getWardMembers(headId: $headId, wId: $wId) network call took ${(swRes.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        if (res != null && res['success'] == true) {
          final dynamic rawData = res['data'] ?? {};
          List<dynamic> rawList = [];
          if (rawData is Map) {
            final dynamic possibleMembers =
                rawData['members'] ?? rawData['wardMembers'];
            if (possibleMembers is List)
              rawList = possibleMembers;
            else if (possibleMembers is Map)
              rawList = possibleMembers.values.toList();
          } else if (rawData is List) {
            rawList = rawData;
          }
          swRes.stop();
          print('DEV DEBUG - API Load Time - _wardAPI.getWardMembers(headId: $headId, wId: $wId) total took ${(swRes.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
          print(
            'DEV DEBUG - [Ward: ${ward.wardName} (No. ${ward.wardNumber})] -> API returned ${rawList.length} member groups/roles.',
          );
        } else {
          print(
            'DEV DEBUG - [Ward: ${ward.wardName} (No. ${ward.wardNumber})] -> API failed or returned success:false.',
          );
        }
      } catch (e) {
        print(
          'DEV DEBUG - [Ward: ${ward.wardName} (No. ${ward.wardNumber})] -> API threw exception: $e',
        );
      }
    }

    return null;
  }

  Future<void> _openWardAreaChart(WardModel ward) async {
    String? resolvedId = _wardIdToHeadIdMap[ward.wardId];
    if (resolvedId == null) {
      resolvedId = await _resolveWardHeadViaTaluka(ward);
    }
    if (resolvedId == null) {
      resolvedId = await _findWardHeadIdForWard(ward.wardId);
    }
    if (!mounted) return;

    void navigateToChart() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AreaChartScreen(
            ward: ward,
            showPdf: _isSuperAdmin ||
                _isChannelPartner ||
                _isCircleLeader ||
                _isSectorHead ||
                _isUcnMember ||
                _isDistrictHead ||
                _isTalukaHead ||
                _isWardHead,
            resolvedWardHeadId: resolvedId,
          ),
        ),
      );
    }

    if (resolvedId == null || resolvedId.isEmpty) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.info_outline, color: Colors.orange, size: 36),
          title: const Text(
            'No Ward Chairman Assigned',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            'No Ward Chairman is currently assigned to ${ward.wardName}.\n\nYou can still view the default Area Chart template for this taluka/constituency.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                navigateToChart();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Chart'),
            ),
          ],
        ),
      );
    } else {
      navigateToChart();
    }
  }

  bool _isEmptyMembersResponse(dynamic response) {
    if (response == null || response is! Map) return true;
    final data = response['data'];
    if (data == null) return true;
    if (data is List && data.isEmpty) return true;
    if (data is Map) {
      final members = data['members'] ?? data['wardMembers'];
      if (members is Map && members.isEmpty) return true;
      if (members is List && members.isEmpty) return true;
      if (data.isEmpty) return true;
    }
    return false;
  }

  List<WardMemberModel> _parseMembersData(
    dynamic rawData, {
    String? wardName,
    String? wardNumber,
  }) {
    List<WardMemberModel> parsedMembers = [];
    if (rawData == null) return parsedMembers;

    if (rawData is Map) {
      // Try to extract ward info directly from the data container if not provided
      wardName ??=
          (rawData['wardDetails'] as Map?)?['wardName']?.toString() ??
          rawData['ward']?.toString();
      wardNumber ??= (rawData['wardDetails'] as Map?)?['wardNumber']
          ?.toString();

      dynamic membersContainer = rawData['members'] ?? rawData['wardMembers'];
      if (membersContainer == null) {
        membersContainer = rawData;
      }

      if (membersContainer is Map) {
        for (var entry in membersContainer.entries) {
          final roleKey = entry.key.toString();
          final membersList = entry.value;
          if (membersList is List) {
            for (var m in membersList) {
              if (m is Map) {
                final mWardName = m['wardName']?.toString() ?? wardName;
                final mWardNumber = m['wardNumber']?.toString() ?? wardNumber;
                parsedMembers.add(
                  WardMemberModel.fromJson(
                    Map<String, dynamic>.from(m),
                    roleKey,
                    wardName: mWardName,
                    wardNumber: mWardNumber,
                  ),
                );
              }
            }
          } else if (membersList is Map) {
            parsedMembers.add(
              WardMemberModel.fromJson(
                Map<String, dynamic>.from(membersList),
                roleKey,
                wardName: wardName,
                wardNumber: wardNumber,
              ),
            );
          }
        }
      } else if (membersContainer is List) {
        for (var m in membersContainer) {
          if (m is Map) {
            final roleKey =
                m['roleName'] ?? m['role'] ?? m['userType'] ?? 'Member';
            final mWardName = m['wardName']?.toString() ?? wardName;
            final mWardNumber = m['wardNumber']?.toString() ?? wardNumber;
            parsedMembers.add(
              WardMemberModel.fromJson(
                Map<String, dynamic>.from(m),
                roleKey.toString(),
                wardName: mWardName,
                wardNumber: mWardNumber,
              ),
            );
          }
        }
      }
    } else if (rawData is List) {
      for (var m in rawData) {
        if (m is Map) {
          final roleKey =
              m['roleName'] ?? m['role'] ?? m['userType'] ?? 'Member';
          final mWardName = m['wardName']?.toString() ?? wardName;
          final mWardNumber = m['wardNumber']?.toString() ?? wardNumber;
          parsedMembers.add(
            WardMemberModel.fromJson(
              Map<String, dynamic>.from(m),
              roleKey.toString(),
              wardName: mWardName,
              wardNumber: mWardNumber,
            ),
          );
        }
      }
    }

    return parsedMembers;
  }

  Future<void> _fetchWardMembers(String wardId) async {
    print(
      'DEV DEBUG - _fetchWardMembers: Started fetching members for wardId: $wardId',
    );
    setState(() {
      _isLoadingMembers = true;
      _wardMembers = [];
    });

    try {
      print('DEV DEBUG - _fetchWardMembers: Resolving wardHeadId...');
      String? targetId = await _findWardHeadIdForWard(wardId);

      if (targetId == null) {
        print(
          'DEV DEBUG - _fetchWardMembers: wardHeadId resolution returned null. Falling back to direct wardId: $wardId',
        );
        targetId = wardId;
      }

      print(
        'DEV DEBUG - _fetchWardMembers: Fetching ward chart data using targetId: $targetId',
      );
      final sw = Stopwatch()..start();
      dynamic response = await _wardAPI.getWardMembers(targetId, wardId);
      print('DEV DEBUG - API Load Time - _wardAPI.getWardMembers(headId: $targetId, wardId: $wardId) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      
      print(
        'DEV DEBUG - _fetchWardMembers: getWardMembers($targetId, $wardId) response: $response',
      );

      // If targetId was wardHeadId and response was empty or unsuccessful, try direct wardId!
      if ((response == null ||
              response['success'] != true ||
              _isEmptyMembersResponse(response)) &&
          targetId != wardId) {
        print(
          'DEV DEBUG - _fetchWardMembers: Ward head query yielded no members. Trying fallback with direct wardId: $wardId',
        );
        final swFallback = Stopwatch()..start();
        final fallbackRes = await _wardAPI.getWardMembers(wardId, wardId);
        print('DEV DEBUG - API Load Time - _wardAPI.getWardMembers(headId: $wardId, wardId: $wardId) [fallback] network call took ${(swFallback.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        print(
          'DEV DEBUG - _fetchWardMembers: getWardMembers($wardId, $wardId) fallback response: $fallbackRes',
        );
        if (fallbackRes != null && fallbackRes['success'] == true) {
          response = fallbackRes;
        }
      }

      if (response != null && response['success'] == true) {
        if (mounted) {
          setState(() {
            final dynamic rawData = response['data'] ?? response;
            // Extract the ward name & number from the API response's wardDetails
            String? respWardName;
            String? respWardNumber;
            if (rawData is Map) {
              final wd = rawData['wardDetails'];
              if (wd is Map) {
                respWardName = wd['wardName']?.toString();
                respWardNumber = wd['wardNumber']?.toString();
              }
              // Also try top-level wardDetails key or ward string
              respWardName ??= rawData['ward']?.toString();
            }
            // Fallback: use the currently selected ward from _allWards
            if (respWardNumber == null && _selectedWardId != null) {
              final selWard = _allWards.firstWhere(
                (w) => w.wardId == _selectedWardId,
                orElse: () => WardModel(
                  wardId: '',
                  wardName: '',
                  district: '',
                  taluka: '',
                  state: '',
                  wardNumber: '',
                ),
              );
              respWardName ??= selWard.wardName;
              respWardNumber = selWard.wardNumber;
            }
            _wardMembers = _parseMembersData(
              rawData,
              wardName: respWardName,
              wardNumber: respWardNumber,
            );
            _isLoadingMembers = false;
            print(
              'DEV DEBUG - _fetchWardMembers: Successfully fetched and parsed ${_wardMembers.length} members for wardId $wardId.',
            );
          });
          sw.stop();
          print('DEV DEBUG - API Load Time - _wardAPI.getWardMembers(headId: $targetId, wardId: $wardId) total (including parsing/setState) took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
        }
      } else {
        print(
          'DEV DEBUG - _fetchWardMembers: API response unsuccessful. Response: $response',
        );
        if (mounted) {
          setState(() {
            _isLoadingMembers = false;
          });
        }
      }
    } catch (e) {
      print(
        'DEV DEBUG - _fetchWardMembers: Exception occurred while fetching members: $e',
      );
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? Colors.black
          : theme.colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.location_city_rounded,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Areas',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        if (_isSuperAdmin ||
                            _isDistrictHead ||
                            _isTalukaHead ||
                            _isWardHead)
                          IconButton(
                            icon: Icon(Icons.filter_list_rounded),
                            color: theme.colorScheme.primary,
                            tooltip: 'Filter Areas',
                            onPressed: _showFilterBottomSheet,
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (_isSuperAdmin ||
                        _isChannelPartner ||
                        _isCircleLeader ||
                        _isSectorHead ||
                        _isUcnMember ||
                        _isDistrictHead ||
                        _isTalukaHead ||
                        _isWardHead) ...[
                      const SizedBox(height: 12),
                      // Active Filters Horizontal Scroll
                      _buildActiveFilterChips(),
                      const SizedBox(height: 16),
                    ],

                    // Ward Details & Action Buttons UI
                    if (_selectedWardId != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Area Members',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Row(
                            children: [
                              // Add Member (Icon-Only Button as requested)
                              InkWell(
                                onTap: _showAddMemberBottomSheet,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.transparent
                                            : Colors.grey.shade100,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // View Chart Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final wardIndex = _allWards.indexWhere(
                                    (w) => w.wardId == _selectedWardId,
                                  );
                                  if (wardIndex != -1) {
                                    await _openWardAreaChart(_allWards[wardIndex]);
                                  }
                                },
                                icon: Icon(Icons.bar_chart_rounded, size: 16),
                                label: Text(
                                  'View Chart',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Details Button
                              OutlinedButton.icon(
                                onPressed: () => _showWardDetailsBottomSheet(),
                                icon: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildWardMembers(theme),
                    ] else ...[
                      if ((_isSuperAdmin ||
                              _isChannelPartner ||
                              _isCircleLeader ||
                              _isSectorHead ||
                              _isUcnMember) &&
                          _selectedDistrict != null &&
                          _selectedTaluka == null)
                        _buildDistrictTalukasList(theme)
                      else if ((_isSuperAdmin ||
                              _isChannelPartner ||
                              _isCircleLeader ||
                              _isSectorHead ||
                              _isUcnMember) &&
                          _selectedTaluka != null)
                        _buildFilteredWardsList(theme)
                      else if (_isDistrictHead &&
                          _selectedDistrict != null &&
                          _selectedTaluka == null)
                        _buildDistrictTalukasList(theme)
                      else if ((_isDistrictHead && _selectedDistrict != null) ||
                          (_isTalukaHead && _selectedTaluka != null))
                        _buildFilteredWardsList(theme)
                      else if (_registeredWardId != null &&
                          !_isSuperAdmin &&
                          !_isDistrictHead &&
                          !_isTalukaHead &&
                          !_isWardHead &&
                          _allWards.any((w) => w.wardId == _registeredWardId))
                        _buildRegisteredWardDetails(
                          _allWards.firstWhere(
                            (w) => w.wardId == _registeredWardId,
                          ),
                        )
                      else if (_isDistrictHead ||
                          _isTalukaHead ||
                          _isWardHead ||
                          _isSuperAdmin ||
                          _isChannelPartner ||
                          _isCircleLeader ||
                          _isSectorHead ||
                          _isUcnMember)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.manage_search_rounded,
                                size: 64,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select an Area',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use the filter icon above to select an area to view.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade900
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.transparent
                                      : Colors.grey.shade100,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_city_rounded,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Profile Update Required',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Please link a ward to your profile to view your ward\'s members and structure.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilteredWardsList(ThemeData theme) {
    if (_wards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No areas found.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final title = _isDistrictHead && _selectedTaluka == null
        ? 'Areas in $_selectedDistrict'
        : 'Areas in $_selectedTaluka';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _wards.length,
          itemBuilder: (context, index) {
            final ward = _wards[index];
            String? wardHeadName;
            try {
              final headId = _wardIdToHeadIdMap[ward.wardId];
              if (headId != null) {
                final head = _allRoleUsers.firstWhere(
                  (u) => u.userId == headId,
                );
                wardHeadName = head.name;
              }
            } catch (_) {}

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  ward.wardName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area No: ${ward.wardNumber}${_isDistrictHead ? ' • ${ward.taluka}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (wardHeadName != null)
                      Text(
                        'Ward Head: $wardHeadName',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.primary,
                ),
                onTap: () {
                  setState(() {
                    _selectedWardId = ward.wardId;
                  });
                  _fetchWardMembers(ward.wardId);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDistrictTalukasList(ThemeData theme) {
    if (_talukas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No talukas found.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Talukas in $_selectedDistrict',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _talukas.length,
          itemBuilder: (context, index) {
            final taluka = _talukas[index];
            final talukaWards = _allWards
                .where(
                  (w) =>
                      w.state == _selectedState &&
                      w.district == _selectedDistrict &&
                      w.taluka == taluka,
                )
                .toList();

            String? talukaHeadName;
            if (talukaWards.isNotEmpty && talukaWards.first.talukaId != null) {
              final String tId = talukaWards.first.talukaId!;
              try {
                final head = _allRoleUsers.firstWhere(
                  (u) => u.roles.any(
                    (r) =>
                        r.roleName.toLowerCase().contains('taluk') &&
                        r.talukaId == tId,
                  ),
                );
                talukaHeadName = head.name;
              } catch (_) {}
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.maps_home_work_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  taluka,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${talukaWards.length} Areas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (talukaHeadName != null)
                      Text(
                        'Taluka Head: $talukaHeadName',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.primary,
                ),
                onTap: () {
                  _onTalukaChanged(
                    taluka,
                  ); // Selects Taluka and reveals Areas List
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegisteredWardDetails(WardModel ward) {
    print(
      'DEV DEBUG - WardScreen UI: Displaying registered ward details for ward: ${ward.wardName} (${ward.wardId})',
    );
    final theme = Theme.of(context);

    // If simple member (not a head or management role), show embedded Area Chart directly
    if (!_isDistrictHead &&
        !_isTalukaHead &&
        !_isWardHead &&
        !_isSuperAdmin &&
        !_isChannelPartner &&
        !_isCircleLeader &&
        !_isSectorHead &&
        !_isUcnMember) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
        child: AreaChartScreen(
          ward: ward,
          showPdf: false,
          isEmbedded: true,
          resolvedWardHeadId: _wardIdToHeadIdMap[ward.wardId],
          onDetailsTap: () => _showWardDetailsBottomSheet(ward),
        ),
      );
    }

    // For District/Taluka/Ward heads, show the summary card with 'View Full Chart' button
    final properties = ward.geoJson?['properties'] ?? {};
    final areaSqm = properties['area_sqm']?.toString() ?? 'N/A';
    final perimeter = properties['perimeter_m']?.toString() ?? 'N/A';
    final lgdCode = properties['lgd_code']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${ward.wardName} Details',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showWardDetailsBottomSheet(ward),
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: const Text(
                  'Details',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            Icons.numbers_rounded,
            'Area Number',
            ward.wardNumber,
            theme,
          ),
          _buildDetailRow(Icons.map_rounded, 'State', ward.state, theme),
          _buildDetailRow(
            Icons.location_on_rounded,
            'Taluka',
            ward.taluka,
            theme,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openWardAreaChart(ward),
              icon: Icon(
                Icons.bar_chart_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              label: Text(
                'View Full Ward Chart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    int selectedTab = 0; // 0: State, 1: District, 2: Taluka, 3: Ward
    if (_selectedState != null) selectedTab = 1;
    if (_selectedDistrict != null) selectedTab = 2;
    if (_selectedTaluka != null) selectedTab = 3;

    // Fast forward selectedTab to the first unlocked option
    if (_isWardLocked) {
      selectedTab = 3;
    } else if (_isTalukaLocked) {
      selectedTab = 3; // Show areas in the locked taluka
    } else if (_isDistrictLocked) {
      selectedTab = 2;
    } else if (_isStateLocked) {
      selectedTab = 1;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            bool hasValueForTab(int index) {
              if (index == 0) return _selectedState != null;
              if (index == 1) return _selectedDistrict != null;
              if (index == 2) return _selectedTaluka != null;
              if (index == 3) return _selectedWardId != null;
              return false;
            }

            Widget buildTab(int index, String title, bool enabled) {
              final isSelected = selectedTab == index;
              return InkWell(
                onTap: enabled
                    ? () {
                        setModalState(() => selectedTab = index);
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: enabled
                                ? (isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.38),
                          ),
                        ),
                      ),
                      if (!enabled)
                        Icon(
                          Icons.lock_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                          size: 14,
                        )
                      else if (hasValueForTab(index) && !isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            }

            Widget buildOptionsList() {
              List<dynamic> items = [];
              String? selectedValue;
              Function(dynamic) onSelect = (val) {};

              if (selectedTab == 0) {
                items = _states;
                selectedValue = _selectedState;
                onSelect = (val) {
                  this.setState(() {
                    _onStateChanged(val as String);
                  });
                  setModalState(() {
                    if (val != null) selectedTab = 1;
                  });
                };
              } else if (selectedTab == 1) {
                items = _districts;
                selectedValue = _selectedDistrict;
                onSelect = (val) async {
                  await _onDistrictChanged(val as String);
                  setModalState(() {
                    if (val != null) selectedTab = 2;
                  });
                };
              } else if (selectedTab == 2) {
                items = _talukas;
                selectedValue = _selectedTaluka;
                onSelect = (val) async {
                  await _onTalukaChanged(val as String);
                  setModalState(() {
                    if (val != null) selectedTab = 3;
                  });
                };
              } else if (selectedTab == 3) {
                items = _wards;
                selectedValue = _selectedWardId;
                onSelect = (val) {
                  this.setState(() {
                    _selectedWardId = (val as WardModel).wardId;
                    _fetchWardMembers(val.wardId);
                  });
                  Navigator.pop(context);
                };
              }

              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'No options available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  String label;
                  String val;
                  if (item is WardModel) {
                    label = '${item.wardName} (No. ${item.wardNumber})';
                    val = item.wardId;
                  } else {
                    label = item.toString();
                    val = item.toString();
                  }

                  final isSelected = val == selectedValue;

                  return InkWell(
                    onTap: () => onSelect(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Areas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 120,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildTab(0, 'State', !_isStateLocked),
                                buildTab(
                                  1,
                                  'District',
                                  _selectedState != null && !_isDistrictLocked,
                                ),
                                buildTab(
                                  2,
                                  'Taluka',
                                  _selectedDistrict != null && !_isTalukaLocked,
                                ),
                                buildTab(
                                  3,
                                  'Area',
                                  _selectedTaluka != null && !_isWardLocked,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, color: Colors.grey.shade200),
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: buildOptionsList(),
                          ),
                        ),
                      ],
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

  void _showWardDetailsBottomSheet([WardModel? wardParam]) {
    WardModel? ward = wardParam;
    if (ward == null) {
      final wardIndex = _allWards.indexWhere(
        (w) => w.wardId == _selectedWardId,
      );
      if (wardIndex == -1) return;
      ward = _allWards[wardIndex];
    }

    final WardModel finalWard = ward;

    final properties = finalWard.geoJson?['properties'] ?? {};
    final areaSqm = properties['area_sqm']?.toString() ?? 'N/A';
    final perimeter = properties['perimeter_m']?.toString() ?? 'N/A';
    final lgdCode = properties['lgd_code']?.toString() ?? 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 24,
            top: 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${finalWard.wardName} Details',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.location_city_rounded,
                'Area Name',
                finalWard.wardName,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.numbers_rounded,
                'Area Number',
                finalWard.wardNumber,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.map_rounded,
                'State',
                finalWard.state,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.map_outlined,
                'District',
                finalWard.district,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.location_on_rounded,
                'Taluka',
                finalWard.taluka,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.square_foot_rounded,
                'Area (sqm)',
                areaSqm,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.straighten_rounded,
                'Perimeter (m)',
                perimeter,
                Theme.of(context),
              ),
              _buildDetailRow(
                Icons.code_rounded,
                'LGD Code',
                lgdCode,
                Theme.of(context),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMemberBottomSheet() async {
    if (_selectedWardId == null) return;

    final wardIndex = _allWards.indexWhere((w) => w.wardId == _selectedWardId);
    if (wardIndex == -1) return;
    final currentWard = _allWards[wardIndex];

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();

    String selectedUserType = 'Chairman';
    bool isSubmitting = false;

    final rolesMap = {
      'Chairman': 'Area Chairman',
      'Official': 'Constituency Official',
      'Patron': 'Udyami Patron',
      'Advisory': 'Advisory Board Member',
      'Mentor': 'Mentor',
      'President': 'President',
      'Vice-President': 'Vice-President',
      'General Secretary': 'General Secretary',
      'Treasurer': 'Treasurer',
      'Sector': 'Economic Sector Lead',
      'UMS': 'UMS Role Manager',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Ward Member',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentWard.wardName} (No. ${currentWard.wardNumber})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedUserType,
                        decoration: InputDecoration(
                          labelText: 'Member Role / Type',
                          prefixIcon: Icon(Icons.badge_outlined),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: rolesMap.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedUserType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: nameController,
                        readOnly: true,
                        onTap: () {
                          _showUserSearchDialog(
                            setModalState,
                            nameController,
                            mobileController,
                            emailController,
                            companyController,
                            currentWard.wardId,
                          );
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Registered User *',
                          prefixIcon: Icon(Icons.person_outline),
                          suffixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please select a user'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number *',
                          prefixIcon: Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? 'Enter valid 10-digit mobile number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          prefixIcon: Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter valid email address'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: companyController,
                        decoration: InputDecoration(
                          labelText: 'Company / Business Name',
                          prefixIcon: Icon(Icons.business_outlined),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                setModalState(() {
                                  isSubmitting = true;
                                });

                                try {
                                  String? headId = await _findWardHeadIdForWard(
                                    currentWard.wardId,
                                  );
                                  if (headId == null) {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'This ward does not have an assigned Ward Head user in DB yet. Please select Ward 22, 14, or 5.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  final memberObj = {
                                    'userType': selectedUserType,
                                    'name': nameController.text.trim(),
                                    'mobileNumber': mobileController.text
                                        .trim(),
                                    'email': emailController.text.trim(),
                                    'companyName': companyController.text
                                        .trim(),
                                  };

                                  final res = await _wardAPI
                                      .createWardChartData(
                                        wardHeadId: headId,
                                        wardId: currentWard.wardId,
                                        ward: currentWard.wardName,
                                        members: [memberObj],
                                      );

                                  if (mounted) {
                                    if (res != null &&
                                        res['success'] == true &&
                                        res['statusCode'] != 409) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            res['message'] ??
                                                'Member added successfully!',
                                          ),
                                          backgroundColor:
                                              Colors.green.shade700,
                                        ),
                                      );
                                      _fetchWardMembers(currentWard.wardId);
                                    } else {
                                      setModalState(() {
                                        isSubmitting = false;
                                      });
                                      final rawMsg =
                                          res?['message'] ??
                                          res?['error'] ??
                                          'Failed to add member.';
                                      String displayMsg = rawMsg.toString();
                                      if (displayMsg.toLowerCase().contains(
                                            'already exists',
                                          ) ||
                                          res?['statusCode'] == 409) {
                                        if (!displayMsg.toLowerCase().contains(
                                          'try another',
                                        )) {
                                          displayMsg =
                                              '$displayMsg Please try using another mobile number or email address.';
                                        }
                                      }
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(displayMsg),
                                          backgroundColor: Colors.red.shade700,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    isSubmitting = false;
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text('Exception: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.surface,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit & Add Member',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveFilterChips() {
    List<Widget> chips = [];

    if (_selectedState != null) {
      chips.add(
        _buildChip(
          'State: $_selectedState',
          _isStateLocked
              ? null
              : () {
                  setState(() {
                    _selectedState = null;
                    _selectedDistrict = null;
                    _selectedTaluka = null;
                    _selectedWardId = null;
                    _wardMembers = [];
                  });
                },
        ),
      );
    }

    if (_selectedDistrict != null) {
      chips.add(
        _buildChip(
          'District: $_selectedDistrict',
          _isDistrictLocked
              ? null
              : () {
                  setState(() {
                    _selectedDistrict = null;
                    _selectedTaluka = null;
                    _selectedWardId = null;
                    _wardMembers = [];
                  });
                },
        ),
      );
    }

    if (_selectedTaluka != null) {
      chips.add(
        _buildChip(
          'Taluka: $_selectedTaluka',
          _isTalukaLocked
              ? null
              : () {
                  setState(() {
                    _selectedTaluka = null;
                    _selectedWardId = null;
                    _wardMembers = [];
                  });
                },
        ),
      );
    }

    if (_selectedWardId != null) {
      final wardIndex = _allWards.indexWhere(
        (w) => w.wardId == _selectedWardId,
      );
      if (wardIndex != -1) {
        final ward = _allWards[wardIndex];
        chips.add(
          _buildChip(
            'Ward: ${ward.wardName}',
            _isWardLocked
                ? null
                : () {
                    setState(() {
                      _selectedWardId = null;
                      _wardMembers = [];
                    });
                  },
          ),
        );
      }
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(right: 8), child: c),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback? onDeleted) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDeleted,
              borderRadius: BorderRadius.circular(10),
              child: Icon(Icons.close_rounded, size: 14, color: primaryColor),
            ),
          ] else ...[
            const SizedBox(width: 4),
            Icon(
              Icons.lock_rounded,
              size: 12,
              color: primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardMembers(ThemeData theme) {
    if (_isLoadingMembers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_wardMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Center(
          child: Text(
            'No members found for this ward.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Group members by role based on the map keys from the API
    final List<WardMemberModel> presidents = [];
    final List<WardMemberModel> vicePresidents = [];
    final List<WardMemberModel> otherRoles = [];
    final List<WardMemberModel> regularMembers = [];

    for (var member in _wardMembers) {
      final roleKey = member.role.toLowerCase();

      if (roleKey.contains('chairman') ||
          roleKey.contains('president') && !roleKey.contains('vice')) {
        presidents.add(member);
      } else if (roleKey.contains('vice president') ||
          roleKey.contains('head')) {
        vicePresidents.add(member);
      } else if (roleKey == 'member') {
        regularMembers.add(member);
      } else {
        otherRoles.add(member);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (presidents.isNotEmpty)
          _buildRoleGroup('President (Ward Chairman)', presidents, theme),
        if (vicePresidents.isNotEmpty)
          _buildRoleGroup(
            'Vice-Presidents (Ward Heads)',
            vicePresidents,
            theme,
          ),
        if (otherRoles.isNotEmpty)
          _buildRoleGroup('Other Leadership', otherRoles, theme),
        if (regularMembers.isNotEmpty)
          _buildRoleGroup('Members / Partners', regularMembers, theme),
      ],
    );
  }

  Widget _buildRoleGroup(
    String title,
    List<WardMemberModel> members,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 14,
            bottom: 10,
            left: 2,
            right: 4,
          ),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        ...members.map((member) => _buildMemberCard(member, theme)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMemberCard(WardMemberModel member, ThemeData theme) {
    String name = member.name.trim();
    final imageUrl = member.profileImage ?? '';

    String displayRole = member.role
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (str) =>
              str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : '',
        )
        .join(' ');

    if (name.isEmpty) {
      name = 'Area ' + displayRole;
    }

    String planText = 'Basic';
    Color planColor = Colors.grey;
    if (member.isPatron) {
      planText = 'Patron';
      planColor = Colors.purple;
    } else if (member.isPrime) {
      planText = 'Prime';
      planColor = Colors.amber.shade700;
    }

    ImageProvider? imageProvider;
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:')) {
        try {
          final base64String = imageUrl.split(',').last;
          final bytes = const Base64Decoder().convert(base64String);
          imageProvider = MemoryImage(bytes);
        } catch (e) {}
      } else {
        imageProvider = NetworkImage(imageUrl);
      }
    }

    Widget avatarChild;
    if (imageProvider is MemoryImage) {
      avatarChild = ClipOval(
        child: Image.memory(
          imageProvider.bytes,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stk) => Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    } else if (imageProvider is NetworkImage) {
      avatarChild = ClipOval(
        child: Image.network(
          imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stk) => Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    } else {
      avatarChild = Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: avatarChild,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayRole,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: planColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              planText,
                              style: TextStyle(
                                color: planColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (member.mobileNumber != null && member.mobileNumber!.isNotEmpty)
              _buildProfileDetailRow(
                Icons.phone,
                'Phone',
                member.mobileNumber!,
                theme,
              ),
            if (member.email != null && member.email!.isNotEmpty)
              _buildProfileDetailRow(
                Icons.email,
                'Email',
                member.email!,
                theme,
              ),
            if (member.companyName != null && member.companyName!.isNotEmpty)
              _buildProfileDetailRow(
                Icons.business,
                'Company',
                member.companyName!,
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserSearchDialog(
    StateSetter setModalState,
    TextEditingController nameController,
    TextEditingController mobileController,
    TextEditingController emailController,
    TextEditingController companyController,
    String wardId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (searchContext) {
        return _UserSearchBottomSheet(
          wardId: wardId,
          onUserSelected: (user) {
            setModalState(() {
              nameController.text = user['name']?.toString() ?? '';
              mobileController.text = user['mobileNumber']?.toString() ?? '';
              emailController.text = user['email']?.toString() ?? '';

              String company = '';
              if (user['profile'] != null &&
                  user['profile']['businessDetails'] != null) {
                company =
                    user['profile']['businessDetails']['businessName']
                        ?.toString() ??
                    '';
              }
              companyController.text = company;
            });
            Navigator.pop(searchContext);
          },
        );
      },
    );
  }
}

class _UserSearchBottomSheet extends StatefulWidget {
  final String wardId;
  final Function(Map<String, dynamic>) onUserSelected;

  const _UserSearchBottomSheet({
    required this.wardId,
    required this.onUserSelected,
  });

  @override
  _UserSearchBottomSheetState createState() => _UserSearchBottomSheetState();
}

class _UserSearchBottomSheetState extends State<_UserSearchBottomSheet> {
  final DirectoryAPI _directoryAPI = DirectoryAPI();
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final sw = Stopwatch()..start();
      final members = await _directoryAPI.searchMembers('', '');
      print('DEV DEBUG - API Load Time - _directoryAPI.searchMembers() network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');

      final wardUsers = members.where((u) {
        if (u['profile'] == null) return false;
        return u['profile']['ward'] == widget.wardId;
      }).toList();

      if (mounted) {
        setState(() {
          _allUsers = wardUsers;
          _filteredUsers = wardUsers;
          _isLoading = false;
        });
        sw.stop();
        print('DEV DEBUG - API Load Time - _directoryAPI.searchMembers() total took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final name = (u['name']?.toString() ?? '').toLowerCase();
        final email = (u['email']?.toString() ?? '').toLowerCase();
        final mobile = (u['mobileNumber']?.toString() ?? '').toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            mobile.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Select Registered User',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or phone...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(child: Text('No users found in this ward.'))
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final name = user['name']?.toString() ?? 'Unknown User';
                      final email = user['email']?.toString() ?? '';
                      final mobile = user['mobileNumber']?.toString() ?? '';

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.2),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (mobile.isNotEmpty)
                                Text(
                                  '📱 $mobile',
                                  style: TextStyle(fontSize: 12),
                                ),
                              if (email.isNotEmpty)
                                Text(
                                  '✉️ $email',
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          onTap: () => widget.onUserSelected(user),
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

class WebPlaceholderScreen extends StatelessWidget {
  final String title;
  const WebPlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title feature coming soon',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class WardScreen extends StatefulWidget {
  const WardScreen({super.key});
  @override
  State<WardScreen> createState() => _WardScreenState();
}

class _WardScreenState extends State<WardScreen> {
  List<Map<String, dynamic>> _getMenusForRole(String role) {
    final Map<String, List<Map<String, dynamic>>> allMenus = {
      'super_admin': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'District Head', 'icon': Icons.person},
        {'name': 'Taluka Head', 'icon': Icons.person},
        {'name': 'Ward / Hobli Head', 'icon': Icons.person},
        {'name': 'Send Messages', 'icon': Icons.message},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'UBN', 'icon': Icons.business},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
        {'name': 'Manage Membership', 'icon': Icons.card_membership},
        {'name': 'Registrations', 'icon': Icons.how_to_reg},
        {'name': 'Job Management', 'icon': Icons.work},
        {'name': 'News Management', 'icon': Icons.article},
        {'name': 'Manage Roles', 'icon': Icons.security},
        {'name': 'Create Ward / Hobli', 'icon': Icons.add_location},
        {'name': 'Channel Partners Onboard', 'icon': Icons.handshake},
      ],
      'ward_chairman': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
        {'name': 'Channel Partner', 'icon': Icons.handshake},
        {'name': 'Route Tracking', 'icon': Icons.route},
        {'name': 'Get Forms', 'icon': Icons.assignment},
        {'name': 'Submissions List', 'icon': Icons.list_alt},
        {'name': 'Applications', 'icon': Icons.description},
        {'name': 'Partner Enrollment', 'icon': Icons.person_add},
        {'name': 'Channel Partners Survey List', 'icon': Icons.poll},
        {'name': 'Manage Roles', 'icon': Icons.security},
      ],
      'ward_head': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
        {'name': 'Manage Roles', 'icon': Icons.security},
      ],
      'district_head': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'Taluk Head', 'icon': Icons.person},
        {'name': 'Ward / Hobli Head', 'icon': Icons.person},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
        {'name': 'UBN', 'icon': Icons.business},
        {'name': 'Manage Roles', 'icon': Icons.security},
      ],
      'taluka_head': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
        {'name': 'UBN', 'icon': Icons.business},
        {'name': 'Manage Roles', 'icon': Icons.security},
      ],
      'channel_partner': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'Udyami Database', 'icon': Icons.storage},
        {'name': 'Roles', 'icon': Icons.security},
        {'name': 'Channel Partners', 'icon': Icons.handshake},
        {'name': 'Lead Management', 'icon': Icons.leaderboard},
        {'name': 'Send Messages', 'icon': Icons.message},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
        {'name': 'UBN', 'icon': Icons.business},
        {'name': 'Programmes Hub', 'icon': Icons.hub},
        {'name': 'Training & Jobs', 'icon': Icons.work},
        {'name': 'Social Media Overview', 'icon': Icons.language},
        {'name': 'Job Management', 'icon': Icons.work_outline},
      ],
      'member': [
        {'name': 'Dashboard', 'icon': Icons.dashboard},
        {'name': 'Send Messages', 'icon': Icons.message},
        {'name': 'Member Map', 'icon': Icons.map},
        {'name': 'Area Chart', 'icon': Icons.account_tree},
      ],
    };

    role = role.toLowerCase();

    // Check exact matches or fallbacks
    if (allMenus.containsKey(role)) return allMenus[role]!;

    if (role.contains('super_admin')) return allMenus['super_admin']!;
    if (role.contains('district')) return allMenus['district_head']!;
    if (role.contains('taluka') || role.contains('taluk'))
      return allMenus['taluka_head']!;
    if (role.contains('ward_chairman') || role.contains('ward_head'))
      return allMenus['ward_chairman']!;
    if (role.contains('channel_partner')) return allMenus['channel_partner']!;

    return allMenus['member']!;
  }

  @override
  Widget build(BuildContext context) {
    String highestRole = 'member';
    try {
      final user = SessionManager.user;
      if (user != null) {
        final userModel = UserModel.fromJson(user);
        if (userModel.roles.isNotEmpty) {
          highestRole = userModel.roles.first.roleName;

          for (final r in userModel.roles) {
            final rl = r.roleName.toLowerCase();
            if (rl == 'super_admin') {
              highestRole = rl;
              break;
            }
            if (rl.contains('district')) {
              highestRole = rl;
            }
            if (rl.contains('taluka') && !highestRole.contains('district')) {
              highestRole = rl;
            }
            if ((rl.contains('ward_chairman') || rl.contains('ward_head')) &&
                !highestRole.contains('taluka') &&
                !highestRole.contains('district')) {
              highestRole = rl;
            }
          }
        }
      }
    } catch (_) {}

    final items = _getMenusForRole(highestRole);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (item['name'] == 'Area Chart' ||
                  item['name'] == 'Ward Chart') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WardFilterScreen()),
                );
              } else if (item['name'] == 'UCN') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UcnDashboardScreen()),
                );
              } else if (item['name'] == 'Manage Roles') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRolesScreen()),
                );
              } else if (item['name'] == 'Member Map') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemberMapScreen()),
                );
              } else if (item['name'] == 'Send Messages') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CommunicationsManagementDashboardScreen(),
                  ),
                );
              } else if (item['name'] == 'Job Management') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JobManagementDashboardScreen(),
                  ),
                );
              } else if (item['name'] == 'News Management') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewsManagementDashboardScreen(),
                  ),
                );
              } else if (item['name'] == 'Create Ward / Hobli') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'This action is only available in the Web Login.',
                    ),
                  ),
                );
              } else if (item['name'] == 'Channel Partners Onboard') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'This action is only available in the Web Login.',
                    ),
                  ),
                );
              } else if (item['name'] == 'Dashboard') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              } else if (item['name'] == 'District Head') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MembersListScreen(
                      role: 'DISTRICT_HEAD',
                      title: 'District Head List',
                      subtitle: 'All districts · State-level representatives',
                      type: 'district',
                    ),
                  ),
                );
              } else if (item['name'] == 'Taluka Head') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MembersListScreen(
                      role: 'TALUKA_HEAD',
                      title: 'Taluk Head List',
                      subtitle: 'All taluks · District-level representatives',
                      type: 'taluk',
                    ),
                  ),
                );
              } else if (item['name'] == 'Ward / Hobli Head') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MembersListScreen(
                      role: 'WARD_CHAIRMAN',
                      title: 'Ward / Hobli Head List',
                      subtitle:
                          'All wards & hoblis · Taluk-level representatives',
                      type: 'ward',
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebPlaceholderScreen(title: item['name']),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 40, color: const Color(0xFFC8102E)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
