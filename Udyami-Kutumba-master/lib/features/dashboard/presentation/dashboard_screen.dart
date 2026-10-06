import 'package:flutter/material.dart';
import '../../../core/api/area/dashboard_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/models/user_model.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/utils/layout_calculator.dart';
import 'manage_roles_screen.dart';
import 'ucn_dashboard_screen.dart';
import 'job_management_dashboard_screen.dart';
import 'news_management_dashboard_screen.dart';
import 'communications_management_dashboard_screen.dart';
import 'admin_quick_action_screens.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardAPI _api = DashboardAPI();
  final ProfileAPI _profileApi = ProfileAPI();

  bool _isLoading = true;
  String _highestRole = 'member';

  String _stateName = '';
  String _districtName = '';
  String _talukaName = '';
  String _wardName = '';

  int _totalUsers = 0;
  int _channelPartners = 0;
  List<dynamic> _cpList = [];
  int _cloudPatra = 0;
  int _cpSubmissions = 0;

  int _wardsCount = 0;
  int _activeWards = 0;
  int _appointedChairmen = 0;
  int _activeTalukas = 0;
  int _allDistrictsCount = 0;
  int _allHeadsCount = 0;
  int _districtHeadsCount = 0;
  int _talukaHeadsCount = 0;
  int _wardChairmenCount = 0;

  int _primeCount = 0;
  int _basicCount = 0;
  int _freeCount = 0;

  List<dynamic> _wardsList = [];
  List<dynamic> _locWards = [];
  List<dynamic> _chairmenList = [];
  List<dynamic> _usersList = [];
  List<dynamic> _districtsList = [];
  List<dynamic> _talukasList = [];
  List<dynamic> _headsList = [];

  String _activeTab = 'Overview & Analytics';
  String _leadershipRoleFilter = 'ALL';
  String _leadershipSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final user = SessionManager.user;
      if (user != null) {
        final userId = user['userId'].toString();

        final userModel = UserModel.fromJson(user);
        print(
          'DEBUG: User Roles found: \${userModel.roles.map((r) => r.roleName).toList()}',
        );
        if (userModel.roles.isNotEmpty) {
          _highestRole = userModel.roles.first.roleName.toLowerCase();
          for (final r in userModel.roles) {
            final rl = r.roleName.toLowerCase();
            if (rl == 'super_admin') {
              _highestRole = rl;
              break;
            }
            if (rl.contains('state') && _highestRole != 'super_admin') {
              _highestRole = rl;
            }
            if (rl.contains('district') &&
                !['super_admin', 'state'].contains(_highestRole)) {
              _highestRole = rl;
            }
            if ((rl.contains('taluka') || rl.contains('taluk')) &&
                !['super_admin', 'state', 'district'].contains(_highestRole)) {
              _highestRole = 'taluka_head';
            }
            if ((rl.contains('ward_chairman') || rl.contains('ward_head')) &&
                ![
                  'super_admin',
                  'state',
                  'district',
                  'taluka_head',
                ].contains(_highestRole)) {
              _highestRole = 'ward_chairman';
            }
          }
        }

        String? wardId;
        String? talukaId;
        String? districtId;
        print('DEBUG: Determined Highest Role: \$_highestRole');

        if (_highestRole == 'super_admin' || _highestRole.contains('state')) {
          _activeTab = 'Overview & Strategic Analytics';
        }

        final profileRes = await _profileApi.getUserProfileById(userId);
        if (profileRes != null && profileRes['success'] == true) {
          final rawData = profileRes['data'];
          final data =
              rawData?['user']?['profile'] ??
                  rawData?['profile'] ??
                  rawData?['user'] ??
                  rawData ??
                  {};

          if (data['ward'] != null) {
            if (data['ward'] is Map) {
              wardId =
                  data['ward']['_id']?.toString() ??
                      data['ward']['wardId']?.toString();
              _wardName = data['ward']['wardName']?.toString() ?? '';
            } else {
              _wardName = data['ward'].toString();
            }
          }
          if (data['taluka'] != null) {
            if (data['taluka'] is Map) {
              _talukaName = data['taluka']['talukaName']?.toString() ?? '';
              talukaId =
                  data['taluka']['_id']?.toString() ??
                      data['taluka']['talukaId']?.toString();
            } else {
              _talukaName = data['taluka'].toString();
            }
          }
          if (data['district'] != null) {
            if (data['district'] is Map) {
              _districtName =
                  data['district']['districtName']?.toString() ?? '';
              districtId =
                  data['district']['_id']?.toString() ??
                      data['district']['districtId']?.toString();
            } else {
              _districtName = data['district'].toString();
            }
          } else if (data['districtName'] != null) {
            _districtName = data['districtName'].toString();
          }
          _stateName = data['state']?.toString() ?? '';
        }

        if (_wardName.isEmpty && user['ward'] != null)
          _wardName = user['ward']['wardName']?.toString() ?? '';
        if (wardId == null && user['ward'] != null)
          wardId = user['ward']['wardId']?.toString();

        if (_talukaName.isEmpty && user['taluka'] != null)
          _talukaName =
              user['taluka']['talukaName']?.toString() ??
                  user['taluka'].toString();
        if (talukaId == null && user['taluka'] != null)
          talukaId =
              user['taluka']['talukaId']?.toString() ??
                  user['taluka']['_id']?.toString();

        if (_districtName.isEmpty && user['district'] != null) {
          _districtName = user['district'] is Map
              ? (user['district']['districtName']?.toString() ?? '')
              : user['district'].toString();
        }
        if (_districtName.isEmpty && user['districtName'] != null) {
          _districtName = user['districtName'].toString();
        }
        if (districtId == null && user['district'] != null) {
          districtId = user['district'] is Map
              ? (user['district']['districtId']?.toString() ??
              user['district']['_id']?.toString())
              : null;
        }
        if (districtId == null && user['districtId'] != null) {
          districtId = user['districtId'].toString();
        }

        // Fallback: check user roles assignment directly if APIs failed
        final rawRolesList = user['roles'] ?? user['userRoles'];
        if (rawRolesList != null && rawRolesList is List) {
          for (var r in rawRolesList) {
            if (r is Map) {
              Map? assignment;
              if (r['assignment'] is Map) {
                assignment = r['assignment'];
              } else if (r['role'] is Map && r['role']['assignment'] is Map) {
                assignment = r['role']['assignment'];
              }

              if (assignment != null) {
                if (_districtName.isEmpty &&
                    assignment['districtName'] != null) {
                  _districtName = assignment['districtName'].toString();
                }
                if (districtId == null && assignment['districtId'] != null) {
                  districtId = assignment['districtId'].toString();
                }
                if (_talukaName.isEmpty && assignment['talukaName'] != null) {
                  _talukaName = assignment['talukaName'].toString();
                }
                if (talukaId == null && assignment['talukaId'] != null) {
                  talukaId = assignment['talukaId'].toString();
                }
              } else {
                // If assignment is flattened into the role directly
                final roleMap = (r['role'] is Map) ? r['role'] : r;
                if (_districtName.isEmpty && roleMap['districtName'] != null) {
                  _districtName = roleMap['districtName'].toString();
                }
                if (districtId == null && roleMap['districtId'] != null) {
                  districtId = roleMap['districtId'].toString();
                }
              }
            }
          }
        }

        print(
          'DEBUG: Resolved Location -> Ward: $_wardName ($wardId), Taluka: $_talukaName ($talukaId), District: $_districtName ($districtId)',
        );

        // ALWAYS fetch location data to get rich charts (wards array with totalMembers)
        try {
          final locRes = await _api.getLocationByWardHeadId(userId);
          if (locRes != null &&
              (locRes['success'] == true || locRes['data'] != null)) {
            final locData = locRes['data'] ?? locRes;
            if (locData is Map &&
                locData['wards'] != null &&
                locData['wards'] is List) {
              _locWards = locData['wards'] as List;
            } else if (locData is List) {
              _locWards = locData;
            }
            Map<String, dynamic>? source;
            if (locData is Map) {
              source = locData as Map<String, dynamic>;
              if (source['taluka'] == null &&
                  source['district'] == null &&
                  source['wards'] != null &&
                  source['wards'] is List &&
                  (source['wards'] as List).isNotEmpty) {
                source =
                (source['wards'] as List).first as Map<String, dynamic>;
              }
            } else if (locData is List && locData.isNotEmpty) {
              source = locData.first as Map<String, dynamic>;
            }
            if (source != null) {
              if (wardId == null)
                wardId =
                    source['ward']?['_id']?.toString() ??
                        source['ward']?['wardId']?.toString();
              if (_wardName.isEmpty)
                _wardName =
                    source['ward']?['wardName']?.toString() ??
                        source['wardName']?.toString() ??
                        '';
              if (talukaId == null)
                talukaId =
                    source['taluka']?['_id']?.toString() ??
                        source['taluka']?['talukaId']?.toString() ??
                        source['ward']?['talukaId']?.toString();
              if (_talukaName.isEmpty)
                _talukaName =
                    source['taluka']?['talukaName']?.toString() ??
                        source['ward']?['talukaName']?.toString() ??
                        source['talukaName']?.toString() ??
                        '';
              if (districtId == null)
                districtId =
                    source['district']?['_id']?.toString() ??
                        source['district']?['districtId']?.toString() ??
                        source['ward']?['districtId']?.toString();
              if (_districtName.isEmpty)
                _districtName =
                    source['district']?['districtName']?.toString() ??
                        source['ward']?['districtName']?.toString() ??
                        source['districtName']?.toString() ??
                        '';
            }

            // Debug prints for dashboard overview - taluka-based wards
            // Extract taluka name from ward data if _talukaName is still empty
            String resolvedTaluka = _talukaName;
            if (resolvedTaluka.isEmpty && _locWards.isNotEmpty) {
              final firstWard = _locWards.first;
              if (firstWard is Map) {
                resolvedTaluka =
                    firstWard['taluka']?['talukaName']?.toString() ??
                        firstWard['talukaName']?.toString() ??
                        '';
              }
            }
            // Filter wards belonging to this taluka
            final talukaWards = _locWards.where((w) {
              if (w is! Map) return false;
              final wTaluka =
                  w['taluka']?['talukaName']?.toString() ??
                      w['talukaName']?.toString() ??
                      w['taluka']?.toString() ??
                      '';
              return wTaluka == resolvedTaluka || resolvedTaluka.isEmpty;
            }).toList();
            print(
              'DEV DEBUG - Total wards fetched for dashboard: ${talukaWards.length} - Thaulk name - $resolvedTaluka',
            );
            int overallLayoutCount = 0;
            int overallTotalMembers = 0;
            for (var w in talukaWards) {
              if (w is Map) {
                // Raw debug: print all keys and totalMembers/layoutCount paths for first ward
                if (talukaWards.indexOf(w) == 0) {
                  print(
                    'DEV DEBUG - RAW ward entry keys: ${(w as Map).keys.toList()}',
                  );
                  if (w['ward'] is Map)
                    print(
                      'DEV DEBUG - RAW ward.ward keys: ${(w['ward'] as Map).keys.toList()}',
                    );
                  if (w['wardChart'] is Map)
                    print(
                      'DEV DEBUG - RAW ward.wardChart keys: ${(w['wardChart'] as Map).keys.toList()}',
                    );
                  print(
                    'DEV DEBUG - RAW paths: w[totalMembers]=${w['totalMembers']}, w[totalWardChartMembers]=${w['totalWardChartMembers']}, w[ward][totalMembers]=${w['ward']?['totalMembers']}, w[ward][layoutCount]=${w['ward']?['layoutCount']}, w[wardChart][totalMembers]=${w['wardChart']?['totalMembers']}',
                  );
                }
                final wardName =
                    w['ward']?['wardName']?.toString() ??
                        w['wardName']?.toString() ??
                        '';
                final lc = w['layoutCount'] ?? w['ward']?['layoutCount'];
                final tm =
                    w['totalWardChartMembers'] ??
                        w['totalMembers'] ??
                        w['ward']?['totalMembers'] ??
                        w['wardChart']?['totalMembers'];

                // Use dynamic layout calculation if available
                final config = w['ward']?['layoutConfig'] ?? w['layoutConfig'];
                int finalLc = 103;
                if (config != null) {
                  finalLc = LayoutCalculator.calculateTotalLayoutCards(
                    config,
                    wardLength: talukaWards.length,
                  );
                } else {
                  final lcVal = (lc is int)
                      ? lc
                      : int.tryParse(lc?.toString() ?? '');
                  finalLc = (lcVal != null && lcVal > 0) ? lcVal : 103;
                }

                final tmVal = (tm is int)
                    ? tm
                    : int.tryParse(tm?.toString() ?? '') ?? 0;
                overallLayoutCount += finalLc;
                overallTotalMembers += tmVal;
                print(
                  'DEV DEBUG - $resolvedTaluka\'s Ward - $wardName (ward overview) - count $tmVal/$finalLc',
                );
              }
            }
            print(
              'DEV DEBUG - Taluka "$resolvedTaluka" wards count: ${talukaWards.length}',
            );
            print(
              'DEV DEBUG - Overall layout count across wards: $overallLayoutCount',
            );
            print(
              'DEV DEBUG - Overall total members across wards: $overallTotalMembers',
            );
          }
        } catch (_) {}

        if (_highestRole == 'super_admin' || _highestRole.contains('state')) {
          print('DEBUG: [Super Admin / State] Triggering APIs...');
          try {
            final usersRes = await _api.fetchUsersSuperAdmin();
            _totalUsers = _countUsersSafe(usersRes);
            _usersList = _extractList(usersRes, 'users');
            print(
              'DEV DEBUG - SuperAdmin users array extracted length: ${_usersList.length}',
            );

            _calculatePlans(_usersList);
          } catch (_) {}

          try {
            // Fetch exact heads just like the web dashboard
            final districtHeads = _extractList(
              await _api.fetchHeadsByRole('district_head'),
              'data',
            );
            final talukaHeads = _extractList(
              await _api.fetchHeadsByRole('taluka_head'),
              'data',
            );
            final wardChairmen = _extractList(
              await _api.fetchHeadsByRole('ward_chairman'),
              'data',
            );

            _districtHeadsCount = districtHeads.length;
            _talukaHeadsCount = talukaHeads.length;
            _wardChairmenCount = wardChairmen.length;

            final allHeads = [
              ...districtHeads,
              ...talukaHeads,
              ...wardChairmen,
            ];

            // Map the heads properly for the Simple List
            _headsList = allHeads.map((h) {
              String extractedRole = 'Leadership';
              if (h['roleName'] != null) {
                extractedRole = h['roleName'].toString();
              } else if (h['roles'] != null &&
                  h['roles'] is List &&
                  (h['roles'] as List).isNotEmpty) {
                extractedRole =
                    h['roles'][0]['roleName']?.toString() ?? 'Leadership';
              }

              return {
                'firstName':
                h['name'] ??
                    h['fullName'] ??
                    h['firstName'] ??
                    h['userName'] ??
                    'Unknown',
                'email':
                h['email'] ?? h['emailAddress'] ?? h['mobileNumber'] ?? '—',
                'roleName': extractedRole,
                'mobileNumber': h['mobileNumber'] ?? h['mobile'] ?? '—',
              };
            }).toList();

            _allHeadsCount = _headsList.length;
            print(
              'DEV DEBUG - SuperAdmin heads explicitly fetched length: $_allHeadsCount',
            );
          } catch (_) {}
          try {
            final cpRes = await _api.fetchChannelPartners();
            _cpList = _extractList(cpRes, 'data');
            _channelPartners = _countData(cpRes);
            print(
              'DEV DEBUG - SuperAdmin CP extracted length: ${_cpList.length}',
            );
          } catch (_) {}
          try {
            final distRes = await _api.fetchAllDistricts();
            _districtsList = _extractList(distRes, 'data');
            _allDistrictsCount = _districtsList.length;
            print(
              'DEV DEBUG - SuperAdmin Districts extracted length: $_allDistrictsCount',
            );
          } catch (_) {}
          print(
            'DEBUG: [Super Admin] ===== FULL DASHBOARD DATA DUMP =====',
          );
          print(
            'DEBUG: [Super Admin] Total Users: $_totalUsers (Prime: $_primeCount, Basic: $_basicCount, Free: $_freeCount)',
          );
          print(
            'DEBUG: [Super Admin] Channel Partners: $_channelPartners (raw list length: ${_cpList.length})',
          );
          print(
            'DEBUG: [Super Admin] District Heads: $_districtHeadsCount | Taluka Heads: $_talukaHeadsCount | Ward Chairmen: $_wardChairmenCount',
          );
          print(
            'DEBUG: [Super Admin] Combined Heads List (district+taluka+ward): $_allHeadsCount',
          );
          print(
            'DEBUG: [Super Admin] Total Districts: $_allDistrictsCount',
          );
          print(
            'DEBUG: [Super Admin] ===== END DASHBOARD DATA DUMP =====',
          );
        } else if (_highestRole.contains('district')) {
          // Authoritative resolution of the District Head's own administered
          // district via the position-hierarchy endpoint (mirrors the web
          // dashboard). The generic profile 'district' field represents the
          // member's own address and can be empty/stale for appointed heads,
          // which previously left districtId/_districtName unresolved and made
          // every district-scoped card below fail silently (showing 0, or, for
          // Ward Chairmen, falling back to unfiltered/admin-wide data).
          if (districtId == null ||
              districtId.isEmpty ||
              _districtName.isEmpty) {
            try {
              final posId =
                  user['position']?['positionId']?.toString() ?? userId;
              final hierRes = await _api.fetchWardHierarchy(posId);
              if (hierRes != null &&
                  (hierRes['success'] == true || hierRes['data'] != null)) {
                final hData = hierRes['data'] ?? hierRes;
                final distMap = hData is Map ? hData['district'] : null;
                if (distMap is Map) {
                  districtId ??=
                      distMap['districtId']?.toString() ??
                          distMap['_id']?.toString();
                  if (_districtName.isEmpty) {
                    _districtName = distMap['districtName']?.toString() ?? '';
                  }
                }
              }
            } catch (_) {}
            print(
              'DEBUG: [District Head] Hierarchy fallback resolved -> District: $_districtName (ID: $districtId)',
            );
          }

          if (districtId == null && _districtName.isNotEmpty) {
            try {
              final allDists = await _api.fetchAllDistricts();
              final list = _extractList(allDists, 'data');
              final found = list.firstWhere(
                    (d) =>
                d['districtName']?.toString().toLowerCase() ==
                    _districtName.toLowerCase(),
                orElse: () => null,
              );
              if (found != null) {
                districtId =
                    found['_id']?.toString() ?? found['districtId']?.toString();
              }
            } catch (_) {}
          }

          if (_districtName.isEmpty) {
            print(
              'DEBUG: [District Head] _districtName is STILL empty. Attempting to fetch DISTRICT_HEAD role list to find my own assignment...',
            );
            try {
              final dHeadRes = await _api.fetchHeadsByRole('DISTRICT_HEAD');
              final allDHeads = _extractList(dHeadRes, 'data');
              final myAssignment = allDHeads.firstWhere(
                    (c) => c['userId']?.toString() == userId,
                orElse: () => null,
              );
              if (myAssignment != null && myAssignment is Map) {
                _districtName = myAssignment['districtName']?.toString() ?? '';
                districtId =
                    myAssignment['districtId']?.toString() ?? districtId;
                print(
                  'DEBUG: [District Head] Self-discovery successful! Found my district: $_districtName (ID: $districtId)',
                );
              } else {
                print(
                  'DEBUG: [District Head] Self-discovery failed. Could not find $userId in DISTRICT_HEAD list.',
                );
              }
            } catch (e) {
              print('DEBUG: [District Head] fetch DISTRICT_HEAD error: $e');
            }
          }

          print(
            'DEBUG: [District Head] Triggering APIs for District: ${_districtName} (ID: ${districtId})...',
          );
          if (_districtName.isNotEmpty) {
            try {
              final usersRes = await _api.fetchUsersByDistrict(_districtName);
              print(
                'DEBUG: [District Head] fetchUsersByDistrict response length: ${_extractList(usersRes, 'users').length}',
              );
              _usersList = _extractList(usersRes, 'users');
              _totalUsers = _countUsersSafe(usersRes);
            } catch (e) {
              print('DEBUG: [District Head] fetchUsersByDistrict error: $e');
            }
          }

          if (districtId != null && _usersList.isEmpty) {
            print(
              'DEBUG: [District Head] fetchUsersByDistrict failed or empty. Trying searchMembers...',
            );
            try {
              final searchRes = await _api.searchMembers({
                'districtId': districtId,
              });
              final sList = _extractList(searchRes, 'data');
              print(
                'DEBUG: [District Head] searchMembers response length: ${sList.length}',
              );
              if (sList.isNotEmpty) {
                _usersList = sList;
                _totalUsers = _usersList.length;
              }
            } catch (e) {
              print('DEBUG: [District Head] searchMembers error: $e');
            }
          }

          // Fallback to fetching all users and filtering (matches web app's combinedDistrictMembers Source 3)
          if (_usersList.isEmpty) {
            print('DEBUG: [District Head] Using getAllUsers fallback...');
            try {
              final allUsersRes = await _api.fetchUsersSuperAdmin();
              final allUsersList = _extractList(allUsersRes, 'users');
              print(
                'DEBUG: [District Head] getAllUsers returned length: ${allUsersList.length}',
              );
              if (allUsersList.isNotEmpty) {
                _usersList = allUsersList.where((u) {
                  final uDist =
                      u['district']?.toString() ??
                          u['districtName']?.toString() ??
                          '';
                  if (uDist.isEmpty) return false;
                  return uDist.toLowerCase().contains(
                    _districtName.toLowerCase(),
                  ) ||
                      _districtName.toLowerCase().contains(uDist.toLowerCase());
                }).toList();
                _totalUsers = _usersList.length;
                print(
                  'DEBUG: [District Head] Extracted $_totalUsers matching district "$_districtName"',
                );
              }
            } catch (e) {
              print('DEBUG: [District Head] getAllUsers error: $e');
            }
          }

          _calculatePlans(_usersList);

          // Fallback to fetching all users and filtering
          if (_usersList.isEmpty) {
            print('DEBUG: [District Head] Using getAllUsers fallback...');
            try {
              final allUsersRes = await _api.fetchUsersSuperAdmin();
              final allUsersList = _extractList(allUsersRes, 'users');

              final matchingUsers = allUsersList.where((u) {
                final udName = (u['districtName']?.toString() ?? '')
                    .toLowerCase()
                    .replaceAll(' ', '');
                final dName = _districtName.toLowerCase().replaceAll(' ', '');
                return udName.isNotEmpty && udName == dName;
              }).toList();

              if (matchingUsers.isNotEmpty) {
                _usersList = matchingUsers;
                _calculatePlans(_usersList);
              }
            } catch (_) {}
          }

          try {
            // Position-based (authoritative): /auth/getAllUsers exposes each
            // user's real assignment via `positions[].district/.taluka/.ward`
            // - confirmed against a live record ("cp rajamahal" ->
            // positions[0].district.districtName == "Bengaluru Urban"), which
            // businessLocation/officeLocation/profile.district do NOT reflect.
            final allUsersRes = await _api.fetchUsersSuperAdmin();
            final allUsersForCp = _extractList(allUsersRes, 'users');
            print(
              'DEBUG: [District Head] fetchUsersSuperAdmin (for CP position lookup) returned ${allUsersForCp.length} user(s) total.',
            );
            final Map<String, dynamic> mergedCps = {};
            for (final u in allUsersForCp) {
              if (u is! Map) continue;
              if (_hasChannelPartnerPosition(
                u,
                levelKey: 'district',
                id: districtId,
                name: _districtName,
              )) {
                final id = u['userId']?.toString();
                if (id != null) mergedCps[id] = Map<String, dynamic>.from(u);
              }
            }
            final positionBasedCount = mergedCps.length;

            // Legacy (kept, not removed - still displayed properly for Super
            // Admin, and kept here as supplementary/"else" data): the old
            // /auth/getAllChannelPartners endpoint doesn't reliably filter by
            // district, so a legacy record is only merged in when its OWN
            // profile district field explicitly confirms this district -
            // this is what stops the old "same CP shows under every
            // district" bug from coming back.
            int legacyAddedCount = 0;
            try {
              final cpRes = await _api.fetchChannelPartners();
              final legacyCps = _extractList(cpRes, 'data');
              final dName = _districtName.toLowerCase().replaceAll(' ', '');
              for (final cp in legacyCps) {
                if (cp is! Map) continue;
                final id = cp['userId']?.toString();
                if (id == null || mergedCps.containsKey(id)) continue;
                final cpProfile = cp['profile'] ?? cp;
                final legacyDistrict =
                (cpProfile['district']?.toString() ??
                    cpProfile['districtName']?.toString() ??
                    '')
                    .toLowerCase()
                    .replaceAll(' ', '');
                if (legacyDistrict.isNotEmpty &&
                    (dName.contains(legacyDistrict) ||
                        legacyDistrict.contains(dName))) {
                  mergedCps[id] = Map<String, dynamic>.from(cp);
                  legacyAddedCount++;
                }
              }
            } catch (_) {}

            _cpList = mergedCps.values.toList();
            _channelPartners = _cpList.length;
            print(
              'DEBUG: [District Head] CP merged result for "$_districtName" -> position-based: $positionBasedCount, legacy-confirmed-added: $legacyAddedCount, total: $_channelPartners',
            );
          } catch (_) {}

          try {
            List distData = [];
            if (districtId != null && districtId.isNotEmpty) {
              print(
                'DEBUG: [District Head] Fetching Talukas by districtId: $districtId',
              );
              final distRes = await _api.fetchTalukasByDistrict(districtId);
              distData = _extractList(distRes, 'data');
            } else if (_districtName.isNotEmpty) {
              print(
                'DEBUG: [District Head] Fetching all districts to find talukas for $_districtName...',
              );
              final distRes = await _api.fetchAllDistricts();
              final allData = _extractList(distRes, 'data');
              final found = allData.firstWhere(
                    (d) =>
                d['districtName']?.toString().toLowerCase() ==
                    _districtName.toLowerCase(),
                orElse: () => null,
              );
              if (found != null) {
                distData = [found];
              }
            }
            if (distData.isNotEmpty && distData[0]['talukas'] != null) {
              _talukasList = distData[0]['talukas'] as List;
            } else {
              _talukasList = distData;
            }
            _activeTalukas = _talukasList.length;
            print(
              'DEBUG: [District Head] Active Talukas extracted: $_activeTalukas',
            );
          } catch (e) {
            print('DEBUG: [District Head] fetch talukas error: $e');
          }

          try {
            final thRes = await _api.fetchHeadsByRole('TALUKA_HEAD');
            final allTalukaHeads = _extractList(thRes, 'data');
            final thList = allTalukaHeads.where((c) {
              if (c['districtName']?.toString().toLowerCase() ==
                  _districtName.toLowerCase())
                return true;
              if (districtId != null &&
                  c['districtId']?.toString() == districtId)
                return true;
              return false;
            }).toList();
            _talukaHeadsCount = thList.length;
            print(
              'DEBUG: [District Head] Taluka Heads fetched: $_talukaHeadsCount (out of ${allTalukaHeads.length})',
            );
          } catch (e) {
            print('DEBUG: [District Head] fetch TALUKA_HEAD error: $e');
          }
          try {
            final Map<String, Map<String, dynamic>> chairmenMap = {};
            String keyFor(Map c) {
              final id = c['userId'] ?? c['_id'] ?? c['wardChairmanUserId'];
              if (id != null) return id.toString();
              final ward = c['wardName'] ?? c['ward']?['wardName'] ?? '';
              final name = c['name'] ?? c['fullName'] ?? '';
              return '${ward}_${name}';
            }

            // Primary source: district-scoped ward-chairmen endpoint - the same
            // one the web dashboard calls, passed the district's own id (this
            // endpoint also accepts a district id, not only a taluka id).
            if (districtId != null && districtId.isNotEmpty) {
              try {
                final distChRes = await _api.fetchWardChairmenBy(districtId);
                final distChList = _extractList(distChRes, 'data');
                for (final e in distChList) {
                  if (e is! Map) continue;
                  final head = e['wardChart'] != null
                      ? e['wardChart']['wardHead']
                      : (e['wardChairman'] ?? e['wardHead']);
                  final entry = <String, dynamic>{
                    'name': head != null
                        ? (head['firstName'] ??
                        head['name'] ??
                        'Unknown Chairman')
                        : (e['name'] ?? 'Unknown Chairman'),
                    'email': head != null
                        ? (head['email'] ?? head['mobileNumber'] ?? '')
                        : (e['email'] ?? ''),
                    'userId':
                    head?['userId'] ??
                        e['wardChairmanUserId'] ??
                        e['userId'],
                    'wardName': e['ward']?['wardName'] ?? e['wardName'],
                  };
                  chairmenMap[keyFor(entry)] = entry;
                }
              } catch (_) {}
            }

            try {
              final thRes = await _api.fetchHeadsByRole('TALUKA_HEAD');
              final allTalukaHeads = _extractList(thRes, 'data');
              final thList = allTalukaHeads.where((c) {
                if (c['districtName']?.toString().toLowerCase() ==
                    _districtName.toLowerCase())
                  return true;
                if (districtId != null &&
                    c['districtId']?.toString() == districtId)
                  return true;
                return false;
              }).toList();
              _talukaHeadsCount = thList.length;
            } catch (_) {}

            try {
              final chRes = await _api.fetchHeadsByRole('WARD_CHAIRMAN');
              final allChairmen = _extractList(chRes, 'data');
              final matchingRoleChairmen = allChairmen.where((c) {
                if (c['districtName']?.toString().toLowerCase() ==
                    _districtName.toLowerCase())
                  return true;
                if (districtId != null &&
                    c['districtId']?.toString() == districtId)
                  return true;

                final roles = c['roles'] ?? c['userRoles'];
                if (roles is List) {
                  for (var r in roles) {
                    if (r is Map &&
                        r['role'] is Map &&
                        r['role']['assignment'] is Map) {
                      final assign = r['role']['assignment'];
                      if ((districtId != null &&
                          assign['districtId'] == districtId) ||
                          (assign['districtName']?.toString().toLowerCase() ==
                              _districtName.toLowerCase()))
                        return true;
                    }
                  }
                }
                return false;
              }).toList();

              if (matchingRoleChairmen.isEmpty) {
                print(
                  'DEBUG: [District Head] No chairmen matched district filter for "$_districtName" (0 out of ${allChairmen.length}). '
                  'FIX APPLIED: no longer falling back to the full global WARD_CHAIRMAN list -> showing 0 for this district '
                  '(matches web app behavior) instead of the Super Admin/global count.',
                );
              } else {
                for (var c in matchingRoleChairmen) {
                  if (c is Map)
                    chairmenMap[keyFor(c)] = Map<String, dynamic>.from(c);
                }
              }

              _chairmenList = chairmenMap.values.toList();
              _appointedChairmen = _chairmenList.length;
              print(
                'DEBUG: [District Head] Ward Chairmen fetched: $_appointedChairmen (merged from APIs)',
              );

              _wardsCount = 0;
              for (var t in _talukasList) {
                if (t is Map && t['wardCount'] != null) {
                  _wardsCount += (int.tryParse(t['wardCount'].toString()) ?? 0);
                }
              }
              print(
                'DEBUG: [District Head] Total Wards calculated: $_wardsCount',
              );
            } catch (e) {
              print('DEBUG: [District Head] fetch WARD_CHAIRMAN error: $e');
            }
          } catch (_) {}
          print(
            'DEBUG: [District Head] ===== FULL DASHBOARD DATA DUMP =====',
          );
          print(
            'DEBUG: [District Head] District: $_districtName (ID: $districtId)',
          );
          print(
            'DEBUG: [District Head] Total Users: $_totalUsers (Prime: $_primeCount, Basic: $_basicCount, Free: $_freeCount)',
          );
          print(
            'DEBUG: [District Head] Channel Partners: $_channelPartners',
          );
          print(
            'DEBUG: [District Head] Active Talukas: $_activeTalukas | Taluka Heads: $_talukaHeadsCount',
          );
          print(
            'DEBUG: [District Head] Ward Chairmen (appointed/shown): $_appointedChairmen | Total Wards: $_wardsCount',
          );
          print(
            'DEBUG: [District Head] ===== END DASHBOARD DATA DUMP =====',
          );
        } else if (_highestRole == 'taluka_head') {
          print(
            'DEBUG: [Taluka Head] Triggering APIs for Taluka: ${_talukaName} (ID: ${talukaId})...',
          );
          if (_talukaName.isNotEmpty) {
            try {
              final usersRes = await _api.fetchUsersByTaluka(_talukaName);
              _usersList = _extractList(usersRes, 'users');
              _totalUsers = _countUsersSafe(usersRes);
            } catch (_) {}
          }
          if (talukaId != null) {
            try {
              final searchRes = await _api.searchMembers({
                'talukaId': talukaId,
              });
              final sList = _extractList(searchRes, 'data');
              if (sList.isNotEmpty) {
                Map<String, dynamic> merged = {};
                for (var u in _usersList) {
                  if (u['userId'] != null) merged[u['userId'].toString()] = u;
                }
                for (var u in sList) {
                  if (u['userId'] != null) merged[u['userId'].toString()] = u;
                }
                _usersList = merged.values.toList();
                if (_usersList.length > _totalUsers)
                  _totalUsers = _usersList.length;
              }
            } catch (_) {}
          }

          _calculatePlans(_usersList);
          try {
            // Same fix as District Head: use /auth/getAllUsers positions
            // data (authoritative) to scope channel partners to this taluka,
            // then merge in any legacy /auth/getAllChannelPartners record
            // only when its own profile taluka field confirms the match (the
            // legacy call is kept, not removed, as supplementary data).
            final allUsersRes = await _api.fetchUsersSuperAdmin();
            final allUsersForCp = _extractList(allUsersRes, 'users');
            print(
              'DEBUG: [Taluka Head] fetchUsersSuperAdmin (for CP position lookup) returned ${allUsersForCp.length} user(s) total.',
            );
            final Map<String, dynamic> mergedCps = {};
            for (final u in allUsersForCp) {
              if (u is! Map) continue;
              if (_hasChannelPartnerPosition(
                u,
                levelKey: 'taluka',
                id: talukaId,
                name: _talukaName,
              )) {
                final id = u['userId']?.toString();
                if (id != null) mergedCps[id] = Map<String, dynamic>.from(u);
              }
            }
            final positionBasedCount = mergedCps.length;

            int legacyAddedCount = 0;
            try {
              final cpRes = await _api.fetchChannelPartners();
              final legacyCps = _extractList(cpRes, 'data');
              final tName = _talukaName.toLowerCase().replaceAll(' ', '');
              for (final cp in legacyCps) {
                if (cp is! Map) continue;
                final id = cp['userId']?.toString();
                if (id == null || mergedCps.containsKey(id)) continue;
                final cpProfile = cp['profile'] ?? cp;
                final legacyTaluka =
                (cpProfile['taluka']?.toString() ??
                    cpProfile['talukaName']?.toString() ??
                    '')
                    .toLowerCase()
                    .replaceAll(' ', '');
                if (legacyTaluka.isNotEmpty &&
                    (tName.contains(legacyTaluka) ||
                        legacyTaluka.contains(tName))) {
                  mergedCps[id] = Map<String, dynamic>.from(cp);
                  legacyAddedCount++;
                }
              }
            } catch (_) {}

            _cpList = mergedCps.values.toList();
            _channelPartners = _cpList.length;
            print(
              'DEBUG: [Taluka Head] CP merged result for "$_talukaName" -> position-based: $positionBasedCount, legacy-confirmed-added: $legacyAddedCount, total: $_channelPartners',
            );
          } catch (_) {}
          if (talukaId != null && talukaId.isNotEmpty) {
            try {
              if (_locWards.isNotEmpty) {
                _wardsList = _locWards.map((e) {
                  final wardInfo = e['ward'] ?? {};
                  return {
                    'wardNumber': wardInfo['wardNumber'],
                    'wardName': wardInfo['wardName'],
                    'constituency':
                    wardInfo['constituencyName'] ?? wardInfo['talukaName'],
                    'totalMembers':
                    e['totalWardChartMembers'] ?? e['totalMembers'] ?? 0,
                    'layoutCount': LayoutCalculator.calculateTotalLayoutCards(
                      wardInfo['layoutConfig'],
                      wardLength: _wardsList.length,
                    ),
                  };
                }).toList();
              } else {
                final wardRes = await _api.fetchWardsByTaluka(talukaId);
                _wardsList = _extractList(wardRes, 'data');
              }

              _wardsCount = _wardsList.length;
              _activeWards = 0;
              for (var w in _wardsList) {
                int built = 0;
                if (w['booths_built'] != null)
                  built = int.tryParse(w['booths_built'].toString()) ?? 0;
                if (w['totalMembers'] != null)
                  built = int.tryParse(w['totalMembers'].toString()) ?? 0;
                if (built > 0) _activeWards++;
              }
            } catch (_) {}
            try {
              final chRes = await _api.fetchWardChairmenBy(talukaId);
              _chairmenList = _extractList(chRes, 'data').map((e) {
                final head = e['wardChart'] != null
                    ? e['wardChart']['wardHead']
                    : null;
                return {
                  'name': head != null
                      ? (head['firstName'] ??
                      head['name'] ??
                      'Unknown Chairman')
                      : 'Unknown Chairman',
                  'email': head != null
                      ? (head['email'] ?? head['mobileNumber'] ?? '')
                      : '',
                };
              }).toList();
              _appointedChairmen = _chairmenList.length;
            } catch (_) {}
          }
          print(
            'DEBUG: [Taluka Head] ===== FULL DASHBOARD DATA DUMP =====',
          );
          print(
            'DEBUG: [Taluka Head] Taluka: $_talukaName (ID: $talukaId)',
          );
          print(
            'DEBUG: [Taluka Head] Total Users: $_totalUsers (Prime: $_primeCount, Basic: $_basicCount, Free: $_freeCount)',
          );
          print(
            'DEBUG: [Taluka Head] Channel Partners: $_channelPartners (NOTE: fetched with no taluka/district filter param - backend limitation, may include CPs outside this taluka)',
          );
          print(
            'DEBUG: [Taluka Head] Wards: $_wardsCount | Active Wards: $_activeWards',
          );
          print(
            'DEBUG: [Taluka Head] Ward Chairmen (appointed/shown): $_appointedChairmen',
          );
          print(
            'DEBUG: [Taluka Head] ===== END DASHBOARD DATA DUMP =====',
          );
        } else if (_highestRole == 'ward_chairman') {
          print(
            'DEBUG: [Ward Chairman] Triggering APIs for Ward: ${_wardName} (ID: ${wardId})...',
          );
          if (_wardName.isNotEmpty) {
            try {
              final usersRes = await _api.fetchUsersByWard(_wardName);
              _usersList = _extractList(usersRes, 'users');
              _totalUsers = _countUsersSafe(usersRes);
            } catch (_) {}
          }
          if (wardId != null && _totalUsers == 0) {
            try {
              final searchRes = await _api.searchMembers({'wardId': wardId});
              final sList = _extractList(searchRes, 'data');
              if (sList.isNotEmpty) {
                _usersList = sList;
                _totalUsers = _usersList.length;
              }
            } catch (_) {}
          }
          _calculatePlans(_usersList);

          if (wardId != null && wardId.isNotEmpty) {
            try {
              // The ward-scoped call already filters correctly on the
              // backend when given a real wardId (confirmed: querying
              // /auth/getAllChannelPartners?wardId=... returns properly
              // ward-filtered results) - keep it as the primary source.
              final cpRes = await _api.fetchChannelPartners(wardId: wardId);
              final legacyCps = _extractList(cpRes, 'data');
              final Map<String, dynamic> mergedCps = {};
              for (final cp in legacyCps) {
                if (cp is! Map) continue;
                final id = cp['userId']?.toString();
                if (id != null) mergedCps[id] = Map<String, dynamic>.from(cp);
              }
              final legacyCount = mergedCps.length;

              // Safety net: also merge in any channel_partner from
              // /auth/getAllUsers whose `positions` assignment matches this
              // exact ward, in case a CP is missing from the legacy endpoint.
              int positionAddedCount = 0;
              try {
                final allUsersRes = await _api.fetchUsersSuperAdmin();
                final allUsersForCp = _extractList(allUsersRes, 'users');
                for (final u in allUsersForCp) {
                  if (u is! Map) continue;
                  final id = u['userId']?.toString();
                  if (id == null || mergedCps.containsKey(id)) continue;
                  if (_hasChannelPartnerPosition(
                    u,
                    levelKey: 'ward',
                    id: wardId,
                    name: _wardName,
                  )) {
                    mergedCps[id] = Map<String, dynamic>.from(u);
                    positionAddedCount++;
                  }
                }
              } catch (_) {}

              _cpList = mergedCps.values.toList();
              _channelPartners = _cpList.length;
              print(
                'DEBUG: [Ward Chairman] CP merged result for ward "$_wardName" -> ward-scoped (legacy): $legacyCount, position-based-added: $positionAddedCount, total: $_channelPartners',
              );
            } catch (_) {}
            try {
              _cloudPatra = _countData(
                await _api.fetchCloudPatraApplicationsByWard(wardId),
                key: 'applications',
              );
            } catch (_) {}
          }
          try {
            _cpSubmissions = _countData(
              await _api.fetchCpSubmissions(userId),
              key: 'submissions',
            );
          } catch (_) {}
          print(
            'DEBUG: [Ward Chairman] Data Fetched -> Users: ${_totalUsers}, Cloud Patra: ${_cloudPatra}, Submissions: ${_cpSubmissions}, CPs: ${_channelPartners}',
          );
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _calculatePlans(List<dynamic> users) {
    _primeCount = 0;
    _basicCount = 0;
    _freeCount = 0;
    for (var u in users) {
      if (u['isPrime'] == true) {
        _primeCount++;
      } else if (u['isBasic'] == true) {
        _basicCount++;
      } else {
        _freeCount++;
      }
    }
  }

  int _countUsersSafe(dynamic response) {
    if (response == null) return 0;
    if (response['totalUsers'] != null)
      return int.tryParse(response['totalUsers'].toString()) ?? 0;
    if (response['total'] != null)
      return int.tryParse(response['total'].toString()) ?? 0;
    if (response['data'] != null && response['data'] is Map) {
      if (response['data']['totalUsers'] != null)
        return int.tryParse(response['data']['totalUsers'].toString()) ?? 0;
      if (response['data']['total'] != null)
        return int.tryParse(response['data']['total'].toString()) ?? 0;
    }
    return _extractList(response, 'users').length;
  }

  List<dynamic> _extractList(dynamic response, String key) {
    if (response == null) return [];
    if (response[key] != null && response[key] is List)
      return response[key] as List;
    if (response['data'] != null) {
      if (response['data'] is List) return response['data'] as List;
      if (response['data'] is Map &&
          response['data'][key] != null &&
          response['data'][key] is List)
        return response['data'][key] as List;
      if (key == 'users' &&
          response['data'] is Map &&
          response['data']['data'] is List)
        return response['data']['data'] as List;
    }
    if (response is List) return response;
    return [];
  }

  int _countData(dynamic response, {String? key}) {
    return _extractList(response, key ?? 'data').length;
  }

  // Checks whether a /auth/getAllUsers user record (a) holds the
  // channel_partner role and (b) has a `positions` entry assigned to the
  // given location. This is the authoritative assignment data - see the
  // confirmed /auth/getAllUsers sample for "cp rajamahal": its
  // positions[0].district/.taluka/.ward hold the REAL assigned location,
  // while businessLocation/officeLocation and profile.district do not.
  // levelKey is 'district', 'taluka', or 'ward' (matches the position's
  // nested map key and its `<levelKey>Id` / `<levelKey>Name` sub-fields).
  bool _hasChannelPartnerPosition(
      dynamic user, {
        required String levelKey,
        String? id,
        String? name,
      }) {
    if (user is! Map) return false;
    final roles = user['userRoles'];
    final isCp = roles is List &&
        roles.any(
              (r) =>
          r is Map &&
              (r['role']?['roleName']?.toString().toLowerCase() ==
                  'channel_partner'),
        );
    if (!isCp) return false;
    final positions = user['positions'];
    if (positions is! List) return false;
    final normName = (name ?? '').toLowerCase().replaceAll(' ', '');
    for (final p in positions) {
      if (p is! Map) continue;
      final loc = p[levelKey];
      if (loc is! Map) continue;
      final locId = loc['${levelKey}Id']?.toString();
      final locName =
      (loc['${levelKey}Name']?.toString() ?? '').toLowerCase().replaceAll(
        ' ',
        '',
      );
      if (id != null && locId != null && locId == id) return true;
      if (normName.isNotEmpty &&
          locName.isNotEmpty &&
          (normName.contains(locName) || locName.contains(normName))) {
        return true;
      }
    }
    return false;
  }

  Widget _buildStatCard(
      String title,
      String subtitle,
      int value,
      IconData icon,
      Color color,
      Color pillBg,
      Color pillText,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const Spacer(),
          if (subtitle.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: pillBg.withValues(alpha: 0.5)),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: pillText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    List<Map<String, dynamic>> tabs = [];
    if (_highestRole == 'super_admin' || _highestRole.contains('state')) {
      tabs = [
        {'name': 'Overview & Strategic Analytics', 'icon': Icons.bar_chart},
        {'name': 'Districts Hierarchy', 'icon': Icons.location_city},
        {'name': 'Leadership Directory', 'icon': Icons.badge},
        {'name': 'Platform Members', 'icon': Icons.people},
        {'name': 'Channel Partners', 'icon': Icons.business},
        {
          'name': 'Governance & Quick Actions',
          'icon': Icons.admin_panel_settings,
        },
      ];
    } else if (_highestRole.contains('district')) {
      tabs = [
        {'name': 'Overview & Analytics', 'icon': Icons.bar_chart},
        {'name': 'Talukas ($_activeTalukas)', 'icon': Icons.flag},
        {'name': 'Ward Chairmen ($_appointedChairmen)', 'icon': Icons.shield},
        {
          'name': 'Channel Partners ($_channelPartners)',
          'icon': Icons.business,
        },
        {'name': 'Members ($_totalUsers)', 'icon': Icons.people},
      ];
    } else {
      tabs = [
        {'name': 'Overview & Analytics', 'icon': Icons.bar_chart},
        {'name': 'Wards ($_wardsCount)', 'icon': Icons.public},
        {'name': 'Ward Chairmen ($_appointedChairmen)', 'icon': Icons.shield},
        {
          'name': 'Channel Partners ($_channelPartners)',
          'icon': Icons.business,
        },
        {'name': 'Members ($_totalUsers)', 'icon': Icons.people},
      ];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((t) {
          final isActive = _activeTab == t['name'].toString().split(' (')[0];
          return GestureDetector(
            onTap: () => setState(
                  () => _activeTab = t['name'].toString().split(' (')[0],
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? Colors.purple.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? Colors.purple.shade600
                      : Colors.grey.shade200,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    t['icon'] as IconData,
                    size: 16,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t['name'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWardsOverview() {
    if (_wardsList.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Wards Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _wardsList.length,
          itemBuilder: (context, index) {
            final w = _wardsList[index];
            final wardNum = w['ward_number'] ?? w['wardNumber'] ?? '';
            final wName = w['ward_name'] ?? w['wardName'] ?? 'Ward';
            final constituency =
                w['constituency'] ?? w['talukaName'] ?? _talukaName;

            int built = 0;
            if (w['booths_built'] != null)
              built = int.tryParse(w['booths_built'].toString()) ?? 0;
            if (w['totalMembers'] != null)
              built = int.tryParse(w['totalMembers'].toString()) ?? 0;

            int total = 103;
            if (w['layoutConfig'] != null) {
              total = LayoutCalculator.calculateTotalLayoutCards(
                w['layoutConfig'],
                wardLength: _wardsList.length,
              );
            } else if (w['layoutCount'] != null) {
              total = int.tryParse(w['layoutCount'].toString()) ?? 103;
            } else if (w['booths_total'] != null) {
              total = int.tryParse(w['booths_total'].toString()) ?? 103;
            }
            if (total == 0) total = 103;

            final pct = total > 0 ? (built / total * 100).toInt() : 0;
            final isComplete = built >= total && total > 0;
            final isEmpty = built == 0;

            Color statusColor = isEmpty
                ? Colors.grey
                : (isComplete ? Colors.green : Colors.blue);
            String statusText = isEmpty
                ? 'Empty'
                : (isComplete ? 'Completed' : 'In Progress');

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ward $wardNum',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    wName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    constituency,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$built/$total',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$pct% complete',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Member Plans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Plan tier breakdown',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPlanCircle('Prime', _primeCount, Colors.purple),
                  _buildPlanCircle('Basic', _basicCount, Colors.blue),
                  _buildPlanCircle('Free', _freeCount, Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
        if (_highestRole == 'taluka_head') _buildWardsOverview(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlanCircle(String name, int count, Color color) {
    int total = _totalUsers > 0 ? _totalUsers : 1;
    int pct = (count / total * 100).toInt();
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: count / total,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade100,
                color: color,
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          count.toString(),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  String _getRoleDisplayName() {
    switch (_highestRole) {
      case 'super_admin':
        return 'Global Headquarters';
      case 'state_head':
        return 'State Head Dashboard';
      case 'district_head':
        return 'District Head Dashboard';
      case 'taluka_head':
        return 'Taluka Head Dashboard';
      case 'ward_chairman':
        return 'Ward Chairman Dashboard';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];

    if (_highestRole == 'super_admin' || _highestRole.contains('state')) {
      cards.add(
        _buildStatCard(
          'Total System Members',
          '$_primeCount Prime · $_basicCount Basic',
          _totalUsers,
          Icons.people,
          Colors.blue,
          Colors.blue.shade50,
          Colors.blue.shade700,
        ),
      );
      int pct = _allDistrictsCount > 0
          ? ((_districtHeadsCount / _allDistrictsCount) * 100).toInt()
          : 0;
      cards.add(
        _buildStatCard(
          'Districts Coverage',
          '$pct% Assigned',
          _allDistrictsCount,
          Icons.public,
          Colors.green,
          Colors.green.shade50,
          Colors.green.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Active Taluka Heads',
          'Across Districts',
          _talukaHeadsCount,
          Icons.flag,
          Colors.purple,
          Colors.purple.shade50,
          Colors.purple.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Active Ward Chairmen',
          'Ward Leadership',
          _wardChairmenCount,
          Icons.shield,
          Colors.amber.shade700,
          Colors.amber.shade50,
          Colors.amber.shade800,
        ),
      );
    } else if (_highestRole.contains('district')) {
      cards.add(
        _buildStatCard(
          'Total District Members',
          '$_primeCount Prime · $_basicCount Basic',
          _totalUsers,
          Icons.people,
          Colors.blue,
          Colors.blue.shade50,
          Colors.blue.shade700,
        ),
      );
      final coveragePct = _activeTalukas > 0
          ? ((_talukaHeadsCount / _activeTalukas) * 100).round()
          : 0;
      cards.add(
        _buildStatCard(
          'Active Talukas',
          '$_talukaHeadsCount / $_activeTalukas\n$coveragePct% Coverage',
          _talukaHeadsCount,
          Icons.flag,
          Colors.green,
          Colors.green.shade50,
          Colors.green.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Ward Chairmen Assigned',
          '${_appointedChairmen} Chairmen\n${_wardsCount} Total Wards',
          _appointedChairmen,
          Icons.shield,
          Colors.purple,
          Colors.purple.shade50,
          Colors.purple.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Channel Partners',
          '$_channelPartners active CPs across wards',
          _channelPartners,
          Icons.business_center,
          Colors.teal,
          Colors.teal.shade50,
          Colors.teal.shade700,
        ),
      );
    } else if (_highestRole == 'taluka_head') {
      cards.add(
        _buildStatCard(
          'Total Taluka Members',
          '$_primeCount Prime · $_basicCount Basic · $_freeCount Free',
          _totalUsers,
          Icons.people,
          Colors.blue,
          Colors.blue.shade50,
          Colors.blue.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Wards Under Taluka',
          '$_wardsCount Active · 0 Chairmen Vacant',
          _wardsCount,
          Icons.location_on,
          Colors.green,
          Colors.green.shade50,
          Colors.green.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Appointed Ward Chairmen',
          '${_appointedChairmen} active chairmen',
          _appointedChairmen,
          Icons.shield,
          Colors.purple,
          Colors.purple.shade50,
          Colors.purple.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Channel Partners',
          '$_channelPartners active CPs across wards',
          _channelPartners,
          Icons.business_center,
          Colors.teal,
          Colors.teal.shade50,
          Colors.teal.shade700,
        ),
      );
    } else if (_highestRole == 'ward_chairman') {
      cards.add(
        _buildStatCard(
          'Total Ward Members',
          'Registered citizens',
          _totalUsers,
          Icons.people,
          Colors.blue,
          Colors.blue.shade50,
          Colors.blue.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Channel Partners',
          'Active CPs in ward',
          _channelPartners,
          Icons.business_center,
          Colors.teal,
          Colors.teal.shade50,
          Colors.teal.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'CP Applications',
          'Pending review',
          _cpSubmissions,
          Icons.inbox,
          Colors.amber.shade800,
          Colors.amber.shade50,
          Colors.amber.shade700,
        ),
      );
      cards.add(
        _buildStatCard(
          'Cloud Patra',
          'Applications',
          _cloudPatra,
          Icons.verified_user,
          Colors.blue,
          Colors.blue.shade50,
          Colors.blue.shade700,
        ),
      );
    }

    if (cards.isEmpty) {
      cards.add(
        _buildStatCard(
          'Engagement',
          'User interactions',
          0,
          Icons.local_activity,
          Colors.deepPurple,
          Colors.deepPurple.shade50,
          Colors.deepPurple.shade700,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _getRoleDisplayName(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _highestRole == 'taluka_head'
                        ? 'Taluka Leadership'
                        : _getRoleDisplayName(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _highestRole == 'taluka_head'
                        ? 'Taluka-wide operations, Ward management & leadership directory'
                        : 'Operations, member analytics & live field updates',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (_talukaName.isNotEmpty ||
                (_highestRole.contains('district') &&
                    _districtName.isNotEmpty))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _talukaName.isNotEmpty
                          ? 'Your Taluka: '
                          : 'Your District: ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _talukaName.isNotEmpty
                          ? '$_districtName > $_talukaName'
                          : _districtName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: cards,
            ),
            const SizedBox(height: 24),
            if (_highestRole == 'super_admin' ||
                _highestRole.contains('state') ||
                _highestRole == 'taluka_head' ||
                _highestRole.contains('district') ||
                _highestRole.contains('ward'))
              _buildTabs(),
            if ((_highestRole == 'super_admin' ||
                _highestRole.contains('state')) &&
                _activeTab == 'Overview & Strategic Analytics')
              _buildOverviewTab(),
            if ((_highestRole == 'super_admin' ||
                _highestRole.contains('state')) &&
                _activeTab != 'Overview & Strategic Analytics')
              _buildTabContent(),
            if ((_highestRole == 'taluka_head' ||
                _highestRole.contains('district') ||
                _highestRole.contains('ward')) &&
                _activeTab == 'Overview & Analytics')
              _buildOverviewTab(),
            if ((_highestRole == 'taluka_head' ||
                _highestRole.contains('district') ||
                _highestRole.contains('ward')) &&
                _activeTab != 'Overview & Analytics')
              _buildTabContent(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_activeTab == 'Wards') {
      return _buildSimpleList(_wardsList, 'wardName', 'wardNumber');
    } else if (_activeTab == 'Talukas') {
      return _buildSimpleList(
        _talukasList,
        'talukaName',
        'talukaId',
        altSubKey: '_id',
      );
    } else if (_activeTab == 'Ward Chairmen') {
      return _buildSimpleList(
        _chairmenList,
        'name',
        'email',
        altTitleKey: 'firstName',
        altSubKey: 'mobileNumber',
      );
    } else if (_activeTab == 'Channel Partners') {
      return _buildSimpleList(_cpList, 'name', 'email');
    } else if (_activeTab == 'Members' || _activeTab == 'Platform Members') {
      return _buildSimpleList(
        _usersList,
        'firstName',
        'email',
        altTitleKey: 'name',
        altSubKey: 'mobileNumber',
      );
    } else if (_activeTab == 'Districts Hierarchy') {
      return _buildSimpleList(_districtsList, 'districtName', 'districtId');
    } else if (_activeTab == 'Leadership Directory') {
      return _buildLeadershipDirectory();
    } else if (_activeTab == 'Governance & Quick Actions') {
      return _buildGovernanceActions();
    }
    return const SizedBox();
  }

  Widget _buildLeadershipDirectory() {
    return _LeadershipDirectoryWidget(
      headsList: _headsList,
      buildList: (items) => _buildSimpleList(
        items,
        'firstName',
        'email',
        altTitleKey: 'name',
        altSubKey: 'mobileNumber',
      ),
    );
  }

  Widget _buildGovernanceActions() {
    final actions = [
      {
        'title': 'User Role Management',
        'desc':
        'Assign roles, set administrative permissions, and manage user access levels.',
        'icon': Icons.admin_panel_settings,
        'color': Colors.blue,
      },
      {
        'title': 'Create Ward & GeoJSON',
        'desc':
        'Create new wards, upload GeoJSON boundary files, and assign districts.',
        'icon': Icons.add_circle_outline,
        'color': Colors.green,
      },
      {
        'title': 'Business Circle Scoring',
        'desc':
        'Configure scoring matrices, engagement points, and member ranking criteria.',
        'icon': Icons.tune,
        'color': Colors.purple,
      },
      {
        'title': 'Taxonomy & Sectors',
        'desc': 'Manage industry sectors, subsectors, and business tags.',
        'icon': Icons.layers,
        'color': Colors.orange,
      },
      {
        'title': 'Communication Campaigns',
        'desc':
        'Send bulk WhatsApp, SMS, and Email announcements across regions.',
        'icon': Icons.campaign,
        'color': Colors.red,
      },
      {
        'title': 'Job Management',
        'desc':
        'Review job postings, applicant queues, and employment listings.',
        'icon': Icons.work,
        'color': Colors.cyan,
      },
      {
        'title': 'News Management',
        'desc':
        'Publish platform news, event updates, and official announcements.',
        'icon': Icons.article,
        'color': Colors.indigo,
      },
      {
        'title': 'Area Chart Builder',
        'desc':
        'Build geographical layouts, assign chairmen slots, and view ward maps.',
        'icon': Icons.map,
        'color': Colors.deepOrange,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Governance & Platform Management Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: () {
                  Widget screen;
                  switch (action['title']) {
                    case 'User Role Management':
                      screen = const ManageRolesScreen();
                      break;
                    case 'Create Ward & GeoJSON':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This action is only available in the Web Login.',
                          ),
                        ),
                      );
                      return;
                    case 'Business Circle Scoring':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This action is only available in the Web Login.',
                          ),
                        ),
                      );
                      return;
                    case 'Taxonomy & Sectors':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This action is only available in the Web Login.',
                          ),
                        ),
                      );
                      return;
                    case 'Communication Campaigns':
                      screen = const CommunicationsManagementDashboardScreen();
                      break;
                    case 'Job Management':
                      screen = const JobManagementDashboardScreen();
                      break;
                    case 'News Management':
                      screen = const NewsManagementDashboardScreen();
                      break;
                    case 'Area Chart Builder':
                      screen = const UcnDashboardScreen();
                      break;
                    default:
                      screen = Scaffold(
                        appBar: AppBar(title: Text(action['title'].toString())),
                        body: Center(
                          child: Text('${action['title']} Coming Soon'),
                        ),
                      );
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        action['title'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action['desc'].toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleList(
      List<dynamic> items,
      String titleKey,
      String subKey, {
        String? altTitleKey,
        String? altSubKey,
      }) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No records found.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title =
            item[titleKey]?.toString() ??
                (altTitleKey != null ? item[altTitleKey]?.toString() : null) ??
                'Unknown';
        final sub =
            item[subKey]?.toString() ??
                (altSubKey != null ? item[altSubKey]?.toString() : null) ??
                '';
        final char = title.isNotEmpty
            ? title.substring(0, 1).toUpperCase()
            : '?';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Text(
                char,
                style: TextStyle(color: Colors.purple.shade700),
              ),
            ),
            title: Text(title),
            subtitle: Text(sub),
          ),
        );
      },
    );
  }
}

class _LeadershipDirectoryWidget extends StatefulWidget {
  final List<dynamic> headsList;
  final Widget Function(List<dynamic>) buildList;

  const _LeadershipDirectoryWidget({
    required this.headsList,
    required this.buildList,
  });

  @override
  State<_LeadershipDirectoryWidget> createState() =>
      _LeadershipDirectoryWidgetState();
}


class _LeadershipDirectoryWidgetState
    extends State<_LeadershipDirectoryWidget> {
  String _leadershipRoleFilter = 'ALL';
  String _leadershipSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<dynamic> filtered = widget.headsList.where((h) {
      bool matchesRole = _leadershipRoleFilter == 'ALL';
      if (!matchesRole) {
        final role = h['roleName']?.toString().toLowerCase() ?? '';
        if (_leadershipRoleFilter == 'DISTRICT_HEAD' &&
            role.contains('district'))
          matchesRole = true;
        if (_leadershipRoleFilter == 'TALUKA_HEAD' && role.contains('taluk'))
          matchesRole = true;
        if (_leadershipRoleFilter == 'WARD_CHAIRMAN' && role.contains('ward'))
          matchesRole = true;
      }

      bool matchesSearch = _leadershipSearchQuery.isEmpty;
      if (!matchesSearch) {
        final name =
            h['firstName']?.toString().toLowerCase() ??
                h['name']?.toString().toLowerCase() ??
                '';
        final email = h['email']?.toString().toLowerCase() ?? '';
        final mobile = h['mobileNumber']?.toString().toLowerCase() ?? '';
        final q = _leadershipSearchQuery.toLowerCase();
        if (name.contains(q) || email.contains(q) || mobile.contains(q)) {
          matchesSearch = true;
        }
      }
      return matchesRole && matchesSearch;
    }).toList();

    print(
      'DEV DEBUG - Filtering Leadership Directory: Search="$_leadershipSearchQuery", Role="$_leadershipRoleFilter". Total: ${widget.headsList.length} -> Filtered: ${filtered.length}',
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search leaders...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (val) =>
                      setState(() => _leadershipSearchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _leadershipRoleFilter,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                      DropdownMenuItem(
                        value: 'DISTRICT_HEAD',
                        child: Text('District Heads'),
                      ),
                      DropdownMenuItem(
                        value: 'TALUKA_HEAD',
                        child: Text('Taluka Heads'),
                      ),
                      DropdownMenuItem(
                        value: 'WARD_CHAIRMAN',
                        child: Text('Ward Chairmen'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null)
                        setState(() => _leadershipRoleFilter = val);
                    },
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
        widget.buildList(filtered),
      ],
    );
  }
}

