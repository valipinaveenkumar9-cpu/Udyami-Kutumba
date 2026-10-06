import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/area/ward_api.dart';
import '../../../core/api/area/dashboard_api.dart';
import '../../../core/models/ward_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/layout_calculator.dart';

import 'assign_member_screen.dart';
import 'chart_builder_screen.dart';

class AreaChartScreen extends StatefulWidget {
  final WardModel ward;
  final bool showPdf;
  final bool isEmbedded;
  final VoidCallback? onDetailsTap;
  final String? resolvedWardHeadId;

  const AreaChartScreen({
    super.key,
    required this.ward,
    this.showPdf = true,
    this.isEmbedded = false,
    this.onDetailsTap,
    this.resolvedWardHeadId,
  });

  @override
  State<AreaChartScreen> createState() => _AreaChartScreenState();
}

const List<Map<String, dynamic>> DEFAULT_BRAND_TILES = [
  {
    "key": "ub-queens",
    "label": "UB QUEEN'S",
    "color": "#D6357F",
    "products": [
      {"key": "dark-store", "name": "UB Q Dark Store", "sub": "Udyami Queen's", "enabled": true},
      {"key": "wellness", "name": "Wellness Supplements", "sub": "MORINGA/ TURMERIC CAPSULES", "enabled": true},
      {"key": "jute", "name": "Jute & Fabric Bags", "sub": "TIFFIN/ SHOPPING BAGS", "enabled": true},
      {"key": "kitchen", "name": "Kitchen Utility", "sub": "WOODEN SPOONS/ CLAY POTS", "enabled": true},
      {"key": "candles", "name": "Hand-Poured Soy Candles", "sub": "FRAGRANCE/ WELLNESS", "enabled": true},
      {"key": "stationary", "name": "UB Q Mart – Stationary", "sub": "SEED PAPER/ RECYCLED PENS", "enabled": true},
      {"key": "batter", "name": "Idli/Dosa Batter", "sub": "STOCKED DAILY AT 6 AM", "enabled": true},
      {"key": "spices", "name": "Hand-Pounded Spices", "sub": "SMALL HIGH-VALUE PACKETS", "enabled": true},
      {"key": "oils", "name": "Cold-Pressed Oils", "sub": "HEAVY STOCKED IN 500ML/1L.", "enabled": true},
      {"key": "snacks", "name": "Traditional Snacks", "sub": "MURUKKU NIPPATTU KODUBALE", "enabled": true},
      {"key": "breakfast", "name": "Millet-Based Breakfast", "sub": "READY-TO COOK MIXES.", "enabled": true},
      {"key": "jaggery", "name": "Artisanal Jaggery Sweets", "sub": "GUILT-FREE TREATS/LADOOS", "enabled": true},
      {"key": "cleaners", "name": "Eco-Friendly Cleaners", "sub": "BIO-ENZYME FLOOR/ DISH WASH.", "enabled": true},
      {"key": "teas", "name": "Herbal Teas & Coffee", "sub": "STONE-GROUND/ SMALL BATCH.", "enabled": true},
      {"key": "babyfood", "name": "Organic Baby Food", "sub": "CHEMICAL FREE PORRIDGES", "enabled": true},
      {"key": "hygiene", "name": "Menstrual Hygiene", "sub": "CLOTH/ BAMBOO PADS", "enabled": true},
      {"key": "soaps", "name": "Handmade Soaps", "sub": "ESSENTIAL OIL-BASED", "enabled": true},
      {"key": "dryfruits", "name": "Dry Fruits & Seeds", "sub": "NUT MIXES/ SUPERFOODS", "enabled": true},
      {"key": "honey", "name": "Forest Honey & Preserves", "sub": "RAW, UNHEATED VARIETIES", "enabled": true},
      {"key": "pickles", "name": "Ready-to-Eat Pickles", "sub": "TRADITIONAL RECIPES", "enabled": true},
    ],
  },
  {
    "key": "ub-realty",
    "label": "UB Realty Construction",
    "color": "#3B5BA8",
    "products": [
      {"key": "cloudpatra", "name": "UB Cloudpatra", "sub": "Cloud Patra", "enabled": true},
      {"key": "bhoomivalut", "name": "UB Bhoomivalut", "sub": "Bhoomi Vault", "enabled": true},
      {"key": "landshomes", "name": "Lands & Homes", "sub": "L&H", "enabled": true},
      {"key": "buildhive", "name": "UB Build Hive", "sub": "Build Hive", "enabled": true},
      {"key": "buildaihome", "name": "UB Build AI Home", "sub": "Build AI Homes", "enabled": true},
    ],
  },
  {
    "key": "yuva-udyami",
    "label": "Yuva Udyami",
    "color": "#dbc118",
    "products": [
      {"key": "slot1", "name": "Yuva Udyami 1", "sub": "Yuva Udyami", "enabled": true},
      {"key": "slot2", "name": "Yuva Udyami 2", "sub": "Yuva Udyami", "enabled": true},
      {"key": "slot3", "name": "Yuva Udyami 3", "sub": "Yuva Udyami", "enabled": true},
      {"key": "slot4", "name": "Yuva Udyami 4", "sub": "Yuva Udyami", "enabled": true},
      {"key": "slot5", "name": "Yuva Udyami 5", "sub": "Yuva Udyami", "enabled": true},
    ],
  },
  {
    "key": "ec",
    "label": "E3",
    "color": "#b7492b",
    "products": [
      {"key": "slot1", "name": "E3 1", "sub": "E3", "enabled": true},
      {"key": "slot2", "name": "E3 2", "sub": "E3", "enabled": true},
      {"key": "slot3", "name": "E3 3", "sub": "E3", "enabled": true},
      {"key": "slot4", "name": "E3 4", "sub": "E3", "enabled": true},
      {"key": "slot5", "name": "E3 5", "sub": "E3", "enabled": true},
    ],
  },
  {
    "key": "ub-finance-it",
    "label": "UB Finance & IT",
    "color": "#D97706",
    "products": [
      {"key": "firstchoice", "name": "First Choice", "sub": "First Choice", "enabled": true},
      {"key": "finserve", "name": "UB Finserve", "sub": "Udyami Bharat Finserve", "enabled": true},
      {"key": "yuvaudyami", "name": "UB Yuva Udyami", "sub": "YUVA UDYAMI", "enabled": true},
      {"key": "aiml", "name": "UB AI/ML", "sub": "UB AI / ML ROBOTIC", "enabled": true},
      {"key": "rownify", "name": "UB R Ownify", "sub": "OWNIFY", "enabled": true},
    ],
  },
  {
    "key": "ub-social",
    "label": "UB Social & Brand",
    "color": "#2F6F4E",
    "products": [
      {"key": "pac", "name": "UB PAC", "sub": "JANATA CIRCLE", "enabled": true},
      {"key": "socials", "name": "UB Socials", "sub": "UB SOCIALS", "enabled": true},
      {"key": "firstgo", "name": "UB First Go", "sub": "FIRST GO", "enabled": true},
      {"key": "esalt", "name": "UB E Salt", "sub": "UB SALT", "enabled": true},
      {"key": "brandlook", "name": "UB Brand Look", "sub": "CORPORATE GIFTING", "enabled": true},
    ],
  },
];

class _AreaChartScreenState extends State<AreaChartScreen> {
  bool _isLoading = true;

  Map<String, dynamic> _assignments = {};
  List<dynamic> _layoutSectors = [];
  List<dynamic> _layoutUmsRoles = [];
  List<dynamic> _layoutBrandTiles = [];
  Map<String, dynamic> _slotCounts = {};
  int? _layoutCount;
  int? _totalMembers;
  int _talukaWardsCount = 9;
  String _resolvedWardHeadId = '';
  Map<String, String> _chairmanLabels = {};
  bool _isWardChairman = false;
  bool _isManagement = false;
  bool _hasAssignedChairman = false;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);
    try {
      final user = SessionManager.user;
      final userId = user?['userId']?.toString() ?? '';

      final roles = user?['roles'] as List<dynamic>? ?? [];
      bool isSuperAdmin = roles.any((r) {
        final name = (r is Map ? r['roleName'] ?? r['name'] : r).toString().toLowerCase();
        return name.contains('super_admin') || name.contains('superadmin');
      }) || user?['role']?.toString().toLowerCase().contains('super') == true;

      bool isDistrictHead = roles.any((r) {
        final name = (r is Map ? r['roleName'] ?? r['name'] : r).toString().toLowerCase();
        return name.contains('district_head') || name.contains('districthead');
      });

      bool isTalukaHead = roles.any((r) {
        final name = (r is Map ? r['roleName'] ?? r['name'] : r).toString().toLowerCase();
        return name.contains('taluk_head') || name.contains('taluka_head');
      });

      _isManagement = isSuperAdmin || isDistrictHead || isTalukaHead;

      _isWardChairman = !_isManagement && roles.any((r) {
        final name = (r is Map ? r['roleName'] ?? r['name'] : r).toString().toLowerCase();
        return name.contains('ward_chairman') || name.contains('ward_head') || name.contains('wardhead');
      });

      print('DEV DEBUG - AreaChart: Current User Roles -> isSuperAdmin: $isSuperAdmin, isDistrictHead: $isDistrictHead, isTalukaHead: $isTalukaHead, isWardChairman: $_isWardChairman');

      final token = SessionManager.token;
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      String wardHeadId = userId;
      
      if (widget.resolvedWardHeadId != null && widget.resolvedWardHeadId!.isNotEmpty) {
        wardHeadId = widget.resolvedWardHeadId!;
      } else {
        String? positionId;
        if (user?['positionHolder'] != null && user!['positionHolder']['positionId'] != null) {
          positionId = user['positionHolder']['positionId'].toString();
        }

        if (positionId != null && positionId.isNotEmpty) {
          final locResRaw = await http.get(
            Uri.parse('https://backend.udyamikutumba.com/ward-chart/hierarchy/$positionId'),
            headers: headers,
          );

          if (locResRaw.statusCode == 200) {
            final locRes = jsonDecode(locResRaw.body);
            if (locRes != null && locRes['data'] != null) {
              var d = locRes['data'];
              if (d is List && d.isNotEmpty) d = d.first;
              if (d is Map && d['wardDetails'] is Map && d['wardDetails']['id'] != null) {
                wardHeadId = d['wardDetails']['id'].toString();
              } else if (d is Map && d['id'] != null) {
                wardHeadId = d['id'].toString();
              }
            }
          }
        }
      }

      _resolvedWardHeadId = wardHeadId;
      print('DEV DEBUG - Resolved ward head ID: $wardHeadId');

      final res = await http.get(
        Uri.parse(
          'https://backend.udyamikutumba.com/ward-chart/getWardChartData/$wardHeadId/${widget.ward.wardId}',
        ),
        headers: headers,
      );
      Map<String, dynamic>? chartData;
      if (res.statusCode == 200) {
        chartData = jsonDecode(res.body);
      }

      // Fetch additional members to merge (just like Web)
      List<dynamic> ucnMembers = [];
      List<dynamic> umsMembers = [];
      List<dynamic> channelPartners = [];
      List<dynamic> talukaChairmen = [];
      List<dynamic> constituencyWards = [];
      List<dynamic> patrons = [];

      try {
        final ucnRes = await http.get(
          Uri.parse(
            'https://backend.udyamikutumba.com/auth/ucn-members/${widget.ward.wardId}',
          ),
          headers: headers,
        );
        if (ucnRes.statusCode == 200)
          ucnMembers =
              jsonDecode(ucnRes.body)['data'] ?? jsonDecode(ucnRes.body) ?? [];
      } catch (_) {}

      try {
        final umsRes = await http.get(
          Uri.parse(
            'https://backend.udyamikutumba.com/udyamimngt/getMngtMembers/${widget.ward.wardId}',
          ),
          headers: headers,
        );
        if (umsRes.statusCode == 200)
          umsMembers =
              jsonDecode(umsRes.body)['data'] ?? jsonDecode(umsRes.body) ?? [];
      } catch (_) {}

      try {
        final cpRes = await http.get(
          Uri.parse(
            'https://backend.udyamikutumba.com/auth/getAllChannelPartners?page=1&limit=50&wardId=${widget.ward.wardId}',
          ),
          headers: headers,
        );
        if (cpRes.statusCode == 200)
          channelPartners =
              jsonDecode(cpRes.body)['data'] ?? jsonDecode(cpRes.body) ?? [];
      } catch (_) {}

      // Robust talukaId resolution matching Web logic
      String? talukaId = widget.ward.talukaId;
      if (talukaId == null || talukaId.isEmpty) {
        talukaId = chartData?['data']?['taluka']?['talukaId']?.toString() ??
            chartData?['data']?['wardDetails']?['talukaId']?.toString() ??
            chartData?['data']?['talukaId']?.toString();
      }
      if (talukaId == null || talukaId.isEmpty) {
        try {
          final allWardsRes = await WardAPI().getAllWards();
          final List<dynamic> wardsList = (allWardsRes != null && allWardsRes['data'] is List)
              ? allWardsRes['data']
              : [];
          final match = wardsList.firstWhere(
            (w) =>
                (w['taluka'] ?? '').toString().toLowerCase().trim() ==
                    widget.ward.taluka.toLowerCase().trim() &&
                w['talukaId'] != null &&
                w['talukaId'].toString().isNotEmpty,
            orElse: () => null,
          );
          if (match != null) {
            talukaId = match['talukaId'].toString();
          }
        } catch (_) {}
      }

      print('DEV DEBUG - AreaChart: Resolved talukaId: "$talukaId" for Taluka "${widget.ward.taluka}"');

      if (talukaId != null && talukaId.isNotEmpty) {
        // 1. Fetch all wards for this taluka/constituency (Web's constituencyWards)
        try {
          final wardsRes = await DashboardAPI().fetchWardsByTaluka(talukaId);
          if (wardsRes != null && wardsRes['success'] == true && wardsRes['data'] is List) {
            constituencyWards = List<dynamic>.from(wardsRes['data']);
            print('DEV DEBUG - AreaChart: fetchWardsByTaluka returned ${constituencyWards.length} wards');
          }
        } catch (e) {
          print('DEV DEBUG - AreaChart: fetchWardsByTaluka error: $e');
        }

        // Fallback to local allWards if API returned 0
        if (constituencyWards.isEmpty) {
          try {
            final allWardsRes = await WardAPI().getAllWards();
            final List<dynamic> wardsList = (allWardsRes != null && allWardsRes['data'] is List)
                ? allWardsRes['data']
                : [];
            final filtered = wardsList
                .where((w) =>
                    (w['taluka'] ?? '').toString().toLowerCase().trim() ==
                    widget.ward.taluka.toLowerCase().trim())
                .toList();
            constituencyWards = filtered;
            print('DEV DEBUG - AreaChart: Fallback allWards found ${constituencyWards.length} wards for ${widget.ward.taluka}');
          } catch (_) {}
        }

        // 2. Fetch chairmen records from backend
        try {
          final talukaRes = await http.get(
            Uri.parse(
              'https://backend.udyamikutumba.com/talukas/getAllWardChaimansBy/$talukaId',
            ),
            headers: headers,
          );
          if (talukaRes.statusCode == 200) {
            final decoded = jsonDecode(talukaRes.body);
            talukaChairmen =
                decoded['data'] ?? decoded ?? [];
            print('DEV DEBUG - AreaChart: getAllWardChaimansBy returned ${talukaChairmen.length} items');
          }
        } catch (e) {
          print('DEV DEBUG - AreaChart: getAllWardChaimansBy error: $e');
        }

        // 3. Fetch patrons
        try {
          final patronRes = await http.get(
            Uri.parse(
              'https://backend.udyamikutumba.com/auth/getAllPatrons/$talukaId',
            ),
            headers: headers,
          );
          if (patronRes.statusCode == 200) {
            final decoded = jsonDecode(patronRes.body);
            patrons =
                decoded['data'] ?? decoded ?? [];
            print('DEV DEBUG - AreaChart: getAllPatrons returned ${patrons.length} items');
          }
        } catch (e) {
          print('DEV DEBUG - AreaChart: getAllPatrons error: $e');
        }
      }

      // Always parse response so standard/default config initializes all slots,
      // even if the ward has no custom chart yet (e.g. 404 from backend like in Mysuru)
      _parseWardChartResponse(
        chartData ?? {},
        ucnMembers,
        umsMembers,
        channelPartners,
        talukaChairmen,
        constituencyWards,
        patrons,
      );

      final hasAssignedChairman = _isWardChairman ||
          (widget.resolvedWardHeadId != null && widget.resolvedWardHeadId!.isNotEmpty) ||
          (chartData != null &&
              chartData['data'] is Map &&
              (chartData['data']['wardHead'] != null ||
                  (chartData['data']['members'] is Map &&
                      (chartData['data']['members']['WardChairman'] as List?)?.isNotEmpty == true)));
      _hasAssignedChairman = hasAssignedChairman;
    } catch (e) {
      debugPrint('Error loading chart data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _parseWardChartResponse(
    dynamic apiResponse,
    List<dynamic> ucnMembers,
    List<dynamic> umsMembersList,
    List<dynamic> cpMembers,
    List<dynamic> talukaChairmen,
    List<dynamic> constituencyWards,
    List<dynamic> extraPatrons,
  ) {
    final rawMembersData = apiResponse?['data']?['members'];
    final Map<String, dynamic> members = (rawMembersData is Map)
        ? Map<String, dynamic>.from(rawMembersData)
        : {};
    final Map<String, dynamic> assignments = {};

    Map<String, dynamic> formatMember(dynamic m, String defaultLabel) {
      return {
        'name': m['name'] ?? m['memberName'] ?? '',
        'company': m['companyName'] ?? m['company'] ?? '',
        'photoUrl':
            m['profileImage'] ?? m['photoUrl'] ?? m['profile']?['profileImage'],
        'mobileNumber': m['mobileNumber'] ?? '',
        'memberId': m['memberId'] ?? m['userId'],
        'userId': m['userId'] ?? m['memberId'],
        // A member returned here already occupies a slot on this ward chart,
        // so default isAssigned to true when the API doesn't send it explicitly.
        'isAssigned': m['isAssigned'] ?? true,
        'assignedBy': m['assignedBy'],
        'status': m['isActive'] == false
            ? 'inactive'
            : (m['status'] ?? 'registered'),
        'slotLabel': m['slotLabel'] ?? defaultLabel,
      };
    }

    if (members['MLA'] != null && (members['MLA'] as List).isNotEmpty) {
      assignments['mla'] = formatMember(members['MLA'][0], 'MLA');
    }

    final wcList = members['WardChairman'] ?? [];
    if (wcList.isNotEmpty) {
      assignments['ward-chairman'] = formatMember(wcList[0], 'Ward Chairman');
    } else if (apiResponse?['data']?['wardHead'] != null) {
      assignments['ward-chairman'] = formatMember(
        apiResponse['data']['wardHead'],
        'Ward Chairman',
      );
    }

    if (members['Official'] != null) {
      int idx = 1;
      for (var m in members['Official']) {
        final slotId = m['slotId'] ?? 'official-$idx';
        assignments[slotId] = formatMember(
          m,
          m['slotLabel'] ?? 'Official $idx',
        );
        idx++;
      }
    }

    if (members['Patron'] != null) {
      int idx = 1;
      for (var m in members['Patron']) {
        final slotId = m['slotId'] ?? 'patron-$idx';
        assignments[slotId] = formatMember(m, m['slotLabel'] ?? 'Patron $idx');
        idx++;
      }
    }

    if (members['Chairman'] != null) {
      int idx = 1;
      for (var m in members['Chairman']) {
        final slotId = m['slotId'] ?? 'chairman-$idx';
        assignments[slotId] = formatMember(
          m,
          m['slotLabel'] ?? 'Chairman $idx',
        );
        idx++;
      }
    }

    if (members['Advisory'] != null) {
      int idx = 1;
      for (var m in members['Advisory']) {
        final slotId = m['slotId'] ?? 'advisory-$idx';
        assignments[slotId] = formatMember(
          m,
          m['slotLabel'] ?? 'Advisory $idx',
        );
        idx++;
      }
    }

    if (members['Mentor'] != null) {
      int idx = 1;
      for (var m in members['Mentor']) {
        final slotId = m['slotId'] ?? 'mentor-$idx';
        assignments[slotId] = formatMember(m, m['slotLabel'] ?? 'Mentor $idx');
        idx++;
      }
    }

    final coreRoleToSlot = {
      'President': 'core-president',
      'Vice-President': 'core-vice-president',
      'General Secretary': 'core-general-secretary',
      'Treasurer': 'core-treasurer',
    };
    if (members['CoreTeam'] != null) {
      for (var m in members['CoreTeam']) {
        final slotId =
            m['slotId'] ??
            (m['coreRole'] != null ? coreRoleToSlot[m['coreRole']] : null);
        if (slotId != null)
          assignments[slotId] = formatMember(m, m['coreRole'] ?? slotId);
      }
    }

    if (members['Sector'] != null) {
      for (var m in members['Sector']) {
        final slotId =
            m['slotId'] ??
            (m['sectorKey'] != null ? 'sector-${m['sectorKey']}' : null);
        if (slotId != null)
          assignments[slotId] = formatMember(m, m['sectorKey'] ?? slotId);
      }
    }

    if (members['UMS'] != null) {
      for (var m in members['UMS']) {
        final slotId =
            m['slotId'] ?? (m['umsKey'] != null ? 'ums-${m['umsKey']}' : null);
        if (slotId != null)
          assignments[slotId] = formatMember(m, m['umsKey'] ?? slotId);
      }
    }

    if (members['ChannelPartner'] != null) {
      for (var m in members['ChannelPartner']) {
        final slotId =
            m['slotId'] ??
            (m['productKey'] != null ? 'product-${m['productKey']}' : null);
        if (slotId != null)
          assignments[slotId] = formatMember(m, m['productKey'] ?? slotId);
      }
    }

    final rawMemberList = members['Member'] ?? members['member'] ?? members['members'];
    if (rawMemberList is List) {
      for (var m in rawMemberList) {
        if (m is Map) {
          final slotId = m['slotId']?.toString();
          if (slotId != null && slotId.isNotEmpty) {
            assignments[slotId] = formatMember(m, m['slotLabel'] ?? slotId);
          }
        }
      }
    }

    // Merge Channel Partners extra API
    for (var m in cpMembers) {
      if (m == null) continue;
      String? slotId =
          m['slotId'] ??
          (m['productKey'] != null ? 'product-${m['productKey']}' : null);
      if (slotId != null && assignments[slotId] == null) {
        assignments[slotId] = formatMember(m, m['productKey'] ?? slotId);
      }
    }

    // Merge Patrons extra API
    for (var m in extraPatrons) {
      if (m == null) continue;
      String slotId = (m['slotId'] ?? 'patron-1').toString();
      if (assignments[slotId] == null) {
        assignments[slotId] = formatMember(
          m,
          m['slotLabel'] ?? 'Patron ${slotId.split("-").last}',
        );
      }
    }

    // Merge UCN Members extra API
    final ucnToSlot = {
      "circle_leader": "core-president",
      "circle-leader": "core-president",
      "president": "core-president",
      "vice_president": "core-vice-president",
      "vice-president": "core-vice-president",
      "general_secretary": "core-general-secretary",
      "general-secretary": "core-general-secretary",
      "treasurer": "core-treasurer",
      "ward_chairman": "ward-chairman",
      "ward-chairman": "ward-chairman",
    };
    final umsKeys = [
      "ai",
      "comms",
      "digital",
      "ground",
      "circle",
      "directory",
      "hall",
      "finance2",
      "kutumba",
      "arbitration",
    ];
    int ucnIdx = 0;
    for (var member in ucnMembers) {
      if (member == null) continue;
      String assignmentType = (member['assignmentType'] ?? "")
          .toString()
          .toLowerCase();
      String? slotId = member['slotId'];

      if (slotId == null) {
        if (ucnToSlot.containsKey(assignmentType)) {
          slotId = ucnToSlot[assignmentType];
        } else if (assignmentType.startsWith("ums_") ||
            assignmentType.startsWith("ums-")) {
          slotId = "ums-${assignmentType.replaceAll(RegExp(r'^ums[_-]'), '')}";
        } else if (member['umsKey'] != null) {
          slotId = "ums-${member['umsKey']}";
        } else if (umsKeys.contains(assignmentType)) {
          slotId = "ums-$assignmentType";
        } else if (member['sectorKey'] != null ||
            assignmentType.startsWith("sector_") ||
            assignmentType.startsWith("sector-")) {
          String sec =
              member['sectorKey'] ??
              assignmentType.replaceAll(RegExp(r'^sector[_-]'), '');
          slotId = "sector-$sec";
        } else if (assignmentType == "advisory") {
          slotId = "advisory-${ucnIdx + 1}";
        } else if (assignmentType == "mentor") {
          slotId = "mentor-${ucnIdx + 1}";
        }
      }

      String name = (member['name'] ?? member['assignedUserName'] ?? "")
          .toString()
          .trim();
      if (slotId != null && name.isNotEmpty && assignments[slotId] == null) {
        assignments[slotId] = {
          'name': name,
          'company': member['companyName'] ?? member['company'] ?? "",
          'photoUrl':
              member['profileImage'] ??
              member['photoUrl'] ??
              member['profile']?['profileImage'],
          'mobileNumber': member['mobileNumber'] ?? "",
          'memberId': member['userId'] ?? member['memberId'],
          'status': member['positionIsActive'] == false
              ? "inactive"
              : (member['status'] ?? "registered"),
          'slotLabel': member['positionName'] ?? member['slotLabel'] ?? slotId,
        };
      }
      ucnIdx++;
    }

    // Merge UMS Members extra API
    final designToSlot = {
      "ai lead generation": "ums-ai",
      "circle meeting": "ums-circle",
      "digital management": "ums-digital",
      "ground intelligence": "ums-ground",
      "hall coordinator": "ums-hall",
      "communications": "ums-comms",
      "comms": "ums-comms",
      "directory management": "ums-directory",
      "directory": "ums-directory",
      "finance": "ums-finance2",
      "kutumba": "ums-kutumba",
      "arbitration": "ums-arbitration",
    };
    for (var item in umsMembersList) {
      if (item == null) continue;
      String desName =
          (item['designation']?['designationName'] ??
                  item['positionName'] ??
                  item['slotLabel'] ??
                  "")
              .toLowerCase()
              .trim();
      String? slotId = item['slotId'] ?? designToSlot[desName];

      if (slotId == null) {
        if (desName.contains("ai"))
          slotId = "ums-ai";
        else if (desName.contains("circle"))
          slotId = "ums-circle";
        else if (desName.contains("digital"))
          slotId = "ums-digital";
        else if (desName.contains("ground"))
          slotId = "ums-ground";
        else if (desName.contains("hall"))
          slotId = "ums-hall";
        else if (desName.contains("comms") || desName.contains("communicat"))
          slotId = "ums-comms";
        else if (desName.contains("director"))
          slotId = "ums-directory";
        else if (desName.contains("finance"))
          slotId = "ums-finance2";
        else if (desName.contains("kutumba"))
          slotId = "ums-kutumba";
        else if (desName.contains("arbitrat"))
          slotId = "ums-arbitration";
        else if (item['umsKey'] != null)
          slotId = "ums-${item['umsKey']}";
        else if (item['assignmentType'] != null) {
          String at = item['assignmentType']
              .toString()
              .toLowerCase()
              .replaceAll(RegExp(r'^ums[_-]'), '');
          slotId = "ums-$at";
        }
      }

      var holderUser =
          item['holder']?['user'] ??
          (item['user']?['name'] != null ? item['user'] : null);
      String name =
          (holderUser?['name'] ??
                  item['assignedUserName'] ??
                  ((item['name'] != null &&
                          item['name'] !=
                              item['designation']?['designationName'])
                      ? item['name']
                      : ""))
              .toString()
              .trim();

      if (slotId != null && name.isNotEmpty && assignments[slotId] == null) {
        assignments[slotId] = {
          'name': name,
          'company':
              item['designation']?['designationName'] ??
              item['positionName'] ??
              item['companyName'] ??
              item['company'] ??
              "",
          'photoUrl':
              holderUser?['profileImage'] ??
              holderUser?['photoUrl'] ??
              holderUser?['profile']?['profileImage'] ??
              item['profileImage'] ??
              item['photoUrl'],
          'mobileNumber':
              holderUser?['mobileNumber'] ?? item['mobileNumber'] ?? "",
          'memberId':
              holderUser?['userId'] ?? item['userId'] ?? item['memberId'],
          'status':
              item['isActive'] == false || item['positionIsActive'] == false
              ? "inactive"
              : (item['status'] ?? "registered"),
          'slotLabel':
              item['designation']?['designationName'] ??
              item['slotLabel'] ??
              slotId,
        };
      }
    }

    // Target wards: all wards in the constituency/taluka (matching Web logic)
    final rawTargetWards = (constituencyWards.isNotEmpty)
        ? constituencyWards
        : talukaChairmen;

    // Deduplicate target wards by wardId / wardName
    final seenWardKeys = <String>{};
    final List<dynamic> targetWards = [];
    for (var w in rawTargetWards) {
      if (w is Map) {
        final key = (w['wardId'] ?? w['id'] ?? w['wardName'] ?? w['ward_name'] ?? '').toString().trim().toLowerCase();
        if (key.isNotEmpty && seenWardKeys.contains(key)) continue;
        if (key.isNotEmpty) seenWardKeys.add(key);
        targetWards.add(w);
      }
    }

    _talukaWardsCount = targetWards.isNotEmpty ? targetWards.length : talukaChairmen.length;
    print('DEV DEBUG - AreaChart: _talukaWardsCount set to $_talukaWardsCount (targetWards: ${targetWards.length}, talukaChairmen: ${talukaChairmen.length})');

    // Merge Taluka Chairmen (Chairmans section)
    for (int i = 0; i < targetWards.length; i++) {
      final constituencyWard = targetWards[i];
      final slotId = "chairman-${i + 1}";

      final wardId = constituencyWard['wardId'] ?? constituencyWard['id'];
      final wardNumber = constituencyWard['wardNumber'] ?? constituencyWard['ward_number'];
      final wardName = constituencyWard['wardName'] ?? constituencyWard['ward_name'];

      final String fallbackLabel = "${wardName ?? wardNumber ?? 'Ward'} Chairman";
      _chairmanLabels[slotId] = fallbackLabel;

      // Match with talukaChairmen API response
      dynamic matchedApiWard;
      try {
        matchedApiWard = talukaChairmen.firstWhere(
          (item) =>
              (wardId != null && (item['wardId'] == wardId || item['id'] == wardId)) ||
              (wardNumber != null && (item['wardNumber'] == wardNumber || item['ward_number'] == wardNumber)) ||
              (wardName != null &&
                  item['wardName'] != null &&
                  item['wardName'].toString().toLowerCase().trim() == wardName.toString().toLowerCase().trim()),
        );
      } catch (_) {
        matchedApiWard = null;
      }

      if (matchedApiWard != null) {
        dynamic chairmanMember;

        if (matchedApiWard['wardChart'] != null) {
          final wardChartObj = matchedApiWard['wardChart'];
          final rawMembers = wardChartObj['members'];

          if (rawMembers is List) {
            try {
              chairmanMember = rawMembers.firstWhere(
                (m) => m['userType'] == "WardChairman" || m['slotId'] == "ward-chairman",
              );
            } catch (_) {}
          } else if (rawMembers is Map) {
            final wcList = rawMembers['WardChairman'] ?? rawMembers['wardChairman'] ?? rawMembers['ward_chairman'];
            if (wcList is List && wcList.isNotEmpty) chairmanMember = wcList[0];
          }

          if (chairmanMember == null && wardChartObj['wardHead'] != null) {
            final head = wardChartObj['wardHead'];
            if (head is Map && (head['name'] != null || head['firstName'] != null)) {
              chairmanMember = head;
            }
          }
        }

        if (chairmanMember == null && matchedApiWard['wardHead'] != null) {
          final head = matchedApiWard['wardHead'];
          if (head is Map && (head['name'] != null || head['firstName'] != null)) {
            chairmanMember = head;
          }
        }

        if (chairmanMember != null &&
            (chairmanMember['name'] != null ||
                chairmanMember['memberName'] != null ||
                chairmanMember['firstName'] != null)) {
          final name = (chairmanMember['name'] ?? chairmanMember['memberName'] ?? chairmanMember['firstName'] ?? '').toString();
          final company = (chairmanMember['companyName'] ?? chairmanMember['company'] ?? '').toString();
          final photo = chairmanMember['profileImage'] ??
              chairmanMember['photoUrl'] ??
              chairmanMember['profile']?['profileImage'] ??
              matchedApiWard['wardChart']?['profileImage'];

          assignments[slotId] = {
            'name': name,
            'company': company,
            'photoUrl': photo,
            'mobileNumber': chairmanMember['mobileNumber']?.toString() ?? "",
            'memberId': chairmanMember['memberId'] ?? chairmanMember['userId'],
            'status': chairmanMember['isActive'] == false
                ? "inactive"
                : (chairmanMember['status'] ?? "registered"),
            'slotLabel': fallbackLabel,
          };
          if (wardId == widget.ward.wardId ||
              (wardName != null && wardName.toString().toLowerCase().trim() == widget.ward.wardName.toLowerCase().trim())) {
            _hasAssignedChairman = true;
          }
          print('DEV DEBUG - AreaChart: Assigned $slotId ($fallbackLabel) -> $name');
        } else {
          print('DEV DEBUG - AreaChart: Slot $slotId ($fallbackLabel) is unassigned');
        }
      } else {
        print('DEV DEBUG - AreaChart: Slot $slotId ($fallbackLabel) has no chairman record yet');
      }
    }

    List<dynamic> layoutSectors = [];
    List<dynamic> layoutUmsRoles = [];
    List<dynamic> layoutBrandTiles = [];

    final layoutConfig = apiResponse?['data']?['layoutConfig'];
    if (layoutConfig != null) {
      print('DEV DEBUG - _updateStateWithData - Successfully Loaded Custom layoutConfig from Web API');
      if (layoutConfig['sectors'] != null && (layoutConfig['sectors'] as List).isNotEmpty) {
        layoutSectors = layoutConfig['sectors'];
      }
      if (layoutConfig['umsRoles'] != null && (layoutConfig['umsRoles'] as List).isNotEmpty) {
        layoutUmsRoles = layoutConfig['umsRoles'];
      }
      if (layoutConfig['brandTiles'] != null && (layoutConfig['brandTiles'] as List).isNotEmpty) {
        layoutBrandTiles = layoutConfig['brandTiles'];
      }
      // Parse slotCounts from layoutConfig
      if (layoutConfig['slotCounts'] != null) {
        final rawCounts = Map<String, dynamic>.from(layoutConfig['slotCounts']);
        print('DEV DEBUG - _updateStateWithData - Loading Synced Slot Counts: $rawCounts');
        rawCounts.forEach((key, value) {
          if (value is int) {
            _slotCounts[key] = value;
          } else if (value is String) {
            _slotCounts[key] = int.tryParse(value) ?? 0;
          } else {
            _slotCounts[key] = 0;
          }
        });
      }
    } else {
      print('DEV DEBUG - _updateStateWithData - No custom layoutConfig found, using defaults.');
    }
      // Apply Web DEFAULT_CONFIG fallbacks for missing/null layoutConfigs
      _slotCounts['officials'] ??= 4;
      _slotCounts['patrons'] ??= 10;
      _slotCounts['advisories'] ??= 3;
      _slotCounts['mentors'] ??= 2;
      _slotCounts['udyamiQueens'] ??= 20;
      _slotCounts['ubRealtyConstruction'] ??= 5;
      _slotCounts['yuvaUdyami'] ??= 5;
      _slotCounts['ec'] ??= 5;
      _slotCounts['ubFinanceIT'] ??= 5;
      _slotCounts['ubSocialBrand'] ??= 5;

      if (layoutSectors.isEmpty) {
        layoutSectors = [
          {"key": "reality", "label": "Reality Sector", "enabled": true},
          {"key": "msme", "label": "MSME Sector", "enabled": true},
          {"key": "healthcare", "label": "Healthcare", "enabled": true},
          {"key": "education", "label": "Education Sector", "enabled": true},
          {"key": "food", "label": "Food & Hospitality", "enabled": true},
          {"key": "tech", "label": "Tech-Enabled", "enabled": true},
          {"key": "orange", "label": "Orange Economy", "enabled": true},
          {"key": "finance", "label": "Finance-Capital", "enabled": true},
          {"key": "skillset", "label": "Skillset Matching", "enabled": true},
          {"key": "news", "label": "News & Media", "enabled": true},
          {"key": "agro", "label": "Agro Tech", "enabled": true},
          {"key": "women", "label": "Empower - Women", "enabled": true},
          {"key": "datascience", "label": "Data Science", "enabled": true},
          {"key": "aiml", "label": "AI ML", "enabled": true},
          {"key": "web3", "label": "WEB 3", "enabled": true}
        ];
      }

      if (layoutUmsRoles.isEmpty) {
        layoutUmsRoles = [
          {"key": "ai", "label": "AI Lead Generation", "enabled": true},
          {"key": "comms", "label": "Communications Management", "enabled": true},
          {"key": "digital", "label": "Digital Management", "enabled": true},
          {"key": "ground", "label": "Ground Intelligence", "enabled": true},
          {"key": "circle", "label": "Circle Meeting", "enabled": true},
          {"key": "directory", "label": "Member Directory", "enabled": true},
          {"key": "hall", "label": "Hall Coordinator", "enabled": true},
          {"key": "finance2", "label": "UB Finance", "enabled": true},
          {"key": "kutumba", "label": "UB Kutumba Coordinator", "enabled": true},
          {"key": "arbitration", "label": "UB Arbitration", "enabled": true}
        ];
      }

      const categoryCountMap = {
        "ub-queens": "udyamiQueens",
        "ub-realty": "ubRealtyConstruction",
        "yuva-udyami": "yuvaUdyami",
        "ec": "ec",
        "ub-finance-it": "ubFinanceIT",
        "ub-social": "ubSocialBrand",
      };

      final baseBrandTiles = DEFAULT_BRAND_TILES.map((defaultCat) {
        final savedCat = layoutBrandTiles.firstWhere(
          (c) => c is Map && c['key'] == defaultCat['key'],
          orElse: () => null,
        );

        final defaultProducts = List<Map<String, dynamic>>.from(
          (defaultCat['products'] as List).map((p) => Map<String, dynamic>.from(p)),
        );

        List<Map<String, dynamic>> customProducts = [];
        if (savedCat != null && savedCat['products'] is List) {
          customProducts = (savedCat['products'] as List)
              .where((sp) => !defaultProducts.any((dp) => dp['key'] == sp['key']))
              .map<Map<String, dynamic>>((sp) => Map<String, dynamic>.from(sp))
              .toList();
        }

        final allCatProducts = [...defaultProducts, ...customProducts];

        final mergedProducts = allCatProducts.map((p) {
          Map<String, dynamic>? savedProduct;
          if (savedCat != null && savedCat['products'] is List) {
            final found = (savedCat['products'] as List).firstWhere(
              (sp) => sp['key'] == p['key'],
              orElse: () => null,
            );
            if (found != null) savedProduct = Map<String, dynamic>.from(found);
          }
          return {
            ...p,
            'name': savedProduct?['name'] ?? p['name'],
            'enabled': savedProduct != null ? (savedProduct['enabled'] == true) : (p['enabled'] == true),
          };
        }).toList();

        final enabledProducts = mergedProducts.where((p) => p['enabled'] == true).toList();
        final countKey = categoryCountMap[defaultCat['key']];
        final maxCount = (countKey != null && _slotCounts.containsKey(countKey))
            ? (_slotCounts[countKey] as int? ?? enabledProducts.length)
            : enabledProducts.length;

        final slots = [...enabledProducts];
        while (slots.length < maxCount) {
          final idx = slots.length;
          slots.add({
            'key': 'placeholder-$idx',
            'name': '${defaultCat['label']} ${idx + 1}',
            'sub': 'Position ${idx + 1}',
            'enabled': true,
            'isPlaceholder': true,
          });
        }

        return {
          ...defaultCat,
          'products': slots.take(maxCount).toList(),
        };
      }).where((cat) => (cat['products'] as List).isNotEmpty).toList();

      final customCatsInConfig = layoutBrandTiles.where(
        (c) => c is Map && !DEFAULT_BRAND_TILES.any((dc) => dc['key'] == c['key']),
      ).map<Map<String, dynamic>>((cat) {
        final countKey = categoryCountMap[cat['key']] ?? cat['countKey'] ?? 'count_${cat['key']}';
        final products = (cat['products'] is List)
            ? (cat['products'] as List).map((p) => Map<String, dynamic>.from(p)).toList()
            : <Map<String, dynamic>>[];
        final enabledProducts = products.where((p) => p['enabled'] != false).toList();
        final maxCount = (_slotCounts[countKey] as int?) ?? (enabledProducts.isNotEmpty ? enabledProducts.length : 5);

        final slots = [...enabledProducts];
        while (slots.length < maxCount) {
          final idx = slots.length;
          slots.add({
            'key': 'placeholder-${cat['key']}-$idx',
            'name': '${cat['label'] ?? cat['key']} ${idx + 1}',
            'sub': 'Position ${idx + 1}',
            'enabled': true,
            'isPlaceholder': true,
          });
        }
        return {
          ...Map<String, dynamic>.from(cat),
          'products': slots.take(maxCount).toList(),
        };
      }).where((cat) => (cat['products'] as List).isNotEmpty).toList();

      layoutBrandTiles = [...baseBrandTiles, ...customCatsInConfig];

      // Extract total layout count dynamically
      _layoutCount = LayoutCalculator.calculateTotalLayoutCards({
        'slotCounts': _slotCounts,
        'sectors': layoutSectors,
        'umsRoles': layoutUmsRoles,
        'brandTiles': layoutBrandTiles,
      }, wardLength: _talukaWardsCount);

      if (apiResponse?['data']?['totalMembers'] != null) {
        final tm = apiResponse['data']['totalMembers'];
        _totalMembers = tm is int ? tm : int.tryParse(tm.toString());
      }

      setState(() {
        _assignments = assignments;
        _layoutSectors = layoutSectors;
        _layoutUmsRoles = layoutUmsRoles;
        _layoutBrandTiles = layoutBrandTiles;
        // _slotCounts already updated above
      });

      print('\n========================================================');
      print('DEV DEBUG - AREA CHART SLOTS & ASSIGNMENTS SUMMARY');
      print('WARD: ${widget.ward.wardName} (${widget.ward.wardId})');
      print('--------------------------------------------------------');

      void printSection(String name, int total, List<String> slotIds) {
        if (total == 0) return;
        int assigned = 0;
        List<String> details = [];
        for (var id in slotIds) {
          if (_assignments.containsKey(id)) {
            assigned++;
            details.add('${_assignments[id]['name']} ($id)');
          }
        }
        int unassigned = total - assigned;
        print('[$name]');
        print('  Total Displayed Slots : $total');
        print('  Assigned Slots        : $assigned');
        print('  Empty Slots           : $unassigned');
        if (details.isNotEmpty) {
          print('  Assigned Data         : ${details.join(", ")}');
        }
        print('--------------------------------------------------------');
      }

      if (!_isWardChairman) {
        printSection('Leadership (Constituency)', 1, ['mla']);
        final officialsCount = _slotCounts['officials'] as int? ?? 0;
        printSection('Officials', officialsCount, List.generate(officialsCount, (i) => 'official-${i + 1}'));
        final patronsCount = _slotCounts['patrons'] as int? ?? 0;
        printSection('Patrons', patronsCount, List.generate(patronsCount, (i) => 'patron-${i + 1}'));
        printSection('Chairmans', _talukaWardsCount, List.generate(_talukaWardsCount, (i) => 'chairman-${i + 1}'));
      } else {
        printSection('Leadership (Ward Chairman)', 1, ['ward-chairman']);
      }
      printSection('Core Team', 4, ['core-president', 'core-vice-president', 'core-general-secretary', 'core-treasurer']);
      
      final advisoriesCount = _slotCounts['advisories'] as int? ?? 0;
      printSection('Advisory Board', advisoriesCount, List.generate(advisoriesCount, (i) => 'advisory-${i + 1}'));
      
      final mentorsCount = _slotCounts['mentors'] as int? ?? 0;
      printSection('Mentors', mentorsCount, List.generate(mentorsCount, (i) => 'mentor-${i + 1}'));
      
      final activeSectors = _layoutSectors.where((s) => s['enabled'] == true).toList();
      printSection('Sectors', activeSectors.length, activeSectors.map((s) => 'sector-${s['key']}').toList());
      
      final activeUms = _layoutUmsRoles.where((s) => s['enabled'] == true).toList();
      printSection('UMS Members', activeUms.length, activeUms.map((s) => 'ums-${s['key']}').toList());
      
      int brandTileCount = 0;
      List<String> brandTileIds = [];
      for (var cat in _layoutBrandTiles) {
        final catKey = cat['key'] ?? '';
        final products = cat['products'] as List<dynamic>? ?? [];
        final enabled = products.where((p) => p['enabled'] == true).toList();
        brandTileCount += enabled.length;
        for (int pIdx = 0; pIdx < enabled.length; pIdx++) {
          final p = enabled[pIdx];
          final slotId = (p['slotId'] != null)
              ? p['slotId'].toString()
              : (p['isPlaceholder'] == true
                  ? 'product-$catKey-slot-${pIdx + 1}'
                  : (p['key'] != null && (p['key'].toString().startsWith('sector-') || p['key'].toString().startsWith('ums-'))
                      ? p['key'].toString()
                      : 'product-$catKey-${p['key']}'));
          brandTileIds.add(slotId);
        }
      }
      printSection('Brand Tiles', brandTileCount, brandTileIds);
      
      print('========================================================\n');
    }

  void _handleSlotTap(
    String slotId,
    String slotLabel, [
    dynamic assignedUser,
  ]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignMemberScreen(
          ward: widget.ward,
          slotId: slotId,
          slotLabel: slotLabel,
          assignedUser: assignedUser,
          wardHeadId: _resolvedWardHeadId,
        ),
      ),
    );
    if (result == true) {
      _loadChartData();
    }
  }

  Widget _buildSlotCard(String slotId, String label, {bool hideLabel = false}) {
    final assigned = _assignments[slotId];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: assigned != null ? Colors.blue.shade200 : Colors.grey.shade300,
          width: assigned != null ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (_isWardChairman || _isManagement)
            ? () => _handleSlotTap(slotId, label, assigned)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: assigned != null
              ? Row(
                  children: [
                    Builder(
                      builder: (context) {
                        final photoUrl = assigned['photoUrl'] as String?;
                        final name = assigned['name'] as String?;
                        Widget fallback = Text(
                          name != null && name.isNotEmpty
                              ? name[0].toUpperCase()
                              : '?',
                        );
                        Widget avatarChild;
                        if (photoUrl == null || photoUrl.isEmpty) {
                          avatarChild = fallback;
                        } else {
                          if (photoUrl.startsWith('data:')) {
                            try {
                              final base64String = photoUrl.split(',').last;
                              avatarChild = Image.memory(
                                const Base64Decoder().convert(base64String),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stk) => fallback,
                              );
                            } catch (e) {
                              avatarChild = fallback;
                            }
                          } else {
                            avatarChild = Image.network(
                              photoUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stk) => fallback,
                            );
                          }
                        }

                        return CircleAvatar(
                          radius: 24,
                          child: ClipOval(child: avatarChild),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!hideLabel)
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (!hideLabel) const SizedBox(height: 4),
                          Text(
                            assigned['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (assigned['mobileNumber'] != null)
                            Text(
                              assigned['mobileNumber'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isWardChairman || _isManagement)
                      const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!hideLabel)
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          const Text(
                            'Tap to assign member',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_isWardChairman || _isManagement)
                      const Icon(Icons.add, color: Colors.blue),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    print('DEV DEBUG - Calculating total slots');
    // Determine total slots: prefer backend layoutCount, fallback to aggregation
    int totalSlots;
    if (_layoutCount != null && _layoutCount! > 0) {
      totalSlots = _layoutCount!;
    } else {
      totalSlots = widget.ward.boothsTotal > 0 ? widget.ward.boothsTotal : 103;
    }

    // Determine assigned count: prefer backend totalMembers, fallback to assignment map length
    int assignedCount;
    if (_totalMembers != null) {
      assignedCount = _totalMembers!;
    } else {
      assignedCount = _assignments.length;
    }
    int unassignedCount = totalSlots - assignedCount;

    // Debug prints - Area Chart screen (taluka-based)
    final _wardTaluka = widget.ward.taluka;
    final _wardName = widget.ward.wardName;
    print('DEV DEBUG - $_wardTaluka\'s Ward - $_wardName (Area Chart) - count $assignedCount/$totalSlots');
    print('DEV DEBUG - Area Chart slots breakdown:');
    print('  Leadership: 2 | Core Team: 4 | Officials: ${_slotCounts['officials'] ?? 0} | Patrons: ${_slotCounts['patrons'] ?? 0}');
    print('  Chairmen(P2): ${_slotCounts['chairmenPage2'] ?? 0} | Chairmen(P3): ${_slotCounts['chairmenPage3'] ?? 0} | Advisories: ${_slotCounts['advisories'] ?? 0} | Mentors: ${_slotCounts['mentors'] ?? 0}');
    print('  Sectors: ${_layoutSectors.where((s) => s['enabled'] == true).length} | UMS: ${_layoutUmsRoles.where((s) => s['enabled'] == true).length}');
    int brandTileCount = 0;
    for (var cat in _layoutBrandTiles) {
      final products = cat['products'] as List<dynamic>? ?? [];
      brandTileCount += products.where((p) => p['enabled'] == true).length;
    }
    print('  Brand-tiles: $brandTileCount');
    print('DEV DEBUG - Total slots: $totalSlots | Assigned: $assignedCount | Unassigned: $unassignedCount');

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  totalSlots.toString(),
                  Colors.blue.shade700,
                ),
                _buildStatItem(
                  'Assigned',
                  assignedCount.toString(),
                  Colors.green.shade700,
                ),
                _buildStatItem(
                  'Available',
                  unassignedCount.toString(),
                  Colors.orange.shade700,
                ),
              ],
            ),
          ),
          if (!_hasAssignedChairman)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.amber.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No Ward Chairman is assigned to ${widget.ward.wardName}. Displaying default constituency chart template.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildSection('Leadership', [
            if (!_isWardChairman)
              _buildSlotCard('mla', '${widget.ward.taluka} Assembly constituency'),
            if (_isWardChairman)
              _buildSlotCard('ward-chairman', 'Ward Chairman'),
          ]),
          if (!_isWardChairman && (_slotCounts['officials'] as int? ?? 0) > 0)
            _buildSection(
              'Officials',
              List.generate(_slotCounts['officials'] as int, (i) {
                return _buildSlotCard('official-${i + 1}', 'Official ${i + 1}', hideLabel: true);
              }),
            ),
          if (!_isWardChairman && (_slotCounts['patrons'] as int? ?? 0) > 0)
            _buildSection(
              'Patrons',
              List.generate(_slotCounts['patrons'] as int, (i) {
                return _buildSlotCard('patron-${i + 1}', 'Patron ${i + 1}');
              }),
            ),

          // Chairmens section (Dynamic list of all ward chairmen in taluka, matching Web logic)
          if (!_isWardChairman && _talukaWardsCount > 0)
            _buildSection(
              'Chairmans',
              List.generate(_talukaWardsCount, (i) {
                String sId = 'chairman-${i + 1}';
                return _buildSlotCard(sId, _chairmanLabels[sId] ?? 'Chairman ${i + 1}');
              }),
            ),

          if ((_slotCounts['advisories'] as int? ?? 0) > 0)
            _buildSection(
              'Advisory Board',
              List.generate(_slotCounts['advisories'] as int, (i) {
                return _buildSlotCard('advisory-${i + 1}', 'Advisory ${i + 1}');
              }),
            ),
          if ((_slotCounts['mentors'] as int? ?? 0) > 0)
            _buildSection(
              'Mentors',
              List.generate(_slotCounts['mentors'] as int? ?? 2, (i) {
                return _buildSlotCard('mentor-${i + 1}', 'Mentor ${i + 1}');
              }),
            ),
          _buildSection('Core Team', [
            _buildSlotCard('core-president', 'President'),
            _buildSlotCard('core-vice-president', 'Vice President'),
            _buildSlotCard('core-general-secretary', 'General Secretary'),
            _buildSlotCard('core-treasurer', 'Treasurer'),
          ]),
          if (_layoutSectors.isNotEmpty)
            _buildSection(
              'Sectors',
              _layoutSectors
                  .where((s) => s['enabled'] == true)
                  .map<Widget>(
                    (s) => _buildSlotCard(
                      'sector-${s['key']}',
                      s['label'] ?? s['key'],
                    ),
                  )
                  .toList(),
            )
          else
            const SizedBox.shrink(),
          if (_layoutUmsRoles.isNotEmpty)
            _buildSection(
              'UMS Management',
              _layoutUmsRoles
                  .where((s) => s['enabled'] == true)
                  .map<Widget>(
                    (s) => _buildSlotCard(
                      'ums-${s['key']}',
                      s['label'] ?? s['key'],
                    ),
                  )
                  .toList(),
            )
          else
            const SizedBox.shrink(),

          // Add Brand Tiles / Products
          if (_layoutBrandTiles.isNotEmpty)
            ..._layoutBrandTiles.map((category) {
              final products = category['products'] as List<dynamic>? ?? [];
              final enabledProducts = products
                  .where((p) => p['enabled'] == true)
                  .toList();
              if (enabledProducts.isEmpty) return const SizedBox.shrink();
              return _buildSection(
                category['label'] ?? category['key'],
                enabledProducts
                    .asMap()
                    .entries
                    .map<Widget>((entry) {
                      final pIdx = entry.key;
                      final p = entry.value;
                      final slotId = (p['slotId'] != null)
                          ? p['slotId'].toString()
                          : (p['isPlaceholder'] == true
                              ? 'product-${category['key']}-slot-${pIdx + 1}'
                              : (p['key'] != null && (p['key'].toString().startsWith('sector-') || p['key'].toString().startsWith('ums-'))
                                  ? p['key'].toString()
                                  : 'product-${category['key']}-${p['key']}'));
                      return _buildSlotCard(
                        slotId,
                        p['name'] ?? p['key'] ?? 'Product ${pIdx + 1}',
                      );
                    })
                    .toList(),
              );
            }),
        ],
      ),
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ward.wardName} Chart'),
        actions: [
          if (widget.showPdf) ...[
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'Customize Layout',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartBuilderScreen(
                      ward: widget.ward,
                      layoutSectors: _layoutSectors,
                      layoutUmsRoles: _layoutUmsRoles,
                      layoutBrandTiles: _layoutBrandTiles,
                      slotCounts: _slotCounts,
                      wardHeadId: _resolvedWardHeadId,
                      talukaWardsCount: _talukaWardsCount,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    _loadChartData(); // Refresh chart when layout saved
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Download PDF',
              onPressed: () {},
            ),
          ],
        ],
      ),
      body: content,
    );
  }
}
