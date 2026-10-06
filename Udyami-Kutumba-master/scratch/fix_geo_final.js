const fs = require('fs');
let text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');

const start = text.indexOf('Future<void> _checkProfileAndInit()');
const end = text.indexOf('Future<void> _fetchLiveLocation()');

if (start === -1 || end === -1) {
  console.log("Could not find method bounds!");
  process.exit(1);
}

const replacement = `Future<void> _checkProfileAndInit() async {
    try {
      final user = SessionManager.user;
      if (user != null && user['userId'] != null) {
        final roleType = _getRoleType();
        _hasPrivilegedRole = (roleType == 'district' || roleType == 'taluka');
        final profileAPI = ProfileAPI();
        final response = await profileAPI.getUserProfileById(user['userId'].toString());
        if (response != null && response['success'] == true) {
          final profile = response['data']?['profile'];
          String? areaName;
          print("DEV DEBUG - Geofence: roleType = $roleType, _hasPrivilegedRole = $_hasPrivilegedRole");

          if (profile != null) {
            if (roleType == 'district' && profile['district'] != null) {
              areaName = profile['district'] is Map ? profile['district']['districtName']?.toString() : profile['district'].toString();
            } else if (roleType == 'taluka' && profile['taluka'] != null) {
              areaName = profile['taluka'] is Map ? profile['taluka']['talukaName']?.toString() : profile['taluka'].toString();
            } else if (roleType == 'ward_head' && profile['ward'] != null) {
              areaName = profile['ward'] is Map ? (profile['ward']['wardName'] ?? profile['ward']['_id']).toString() : profile['ward'].toString();
            } else if (profile['ward'] != null && !_hasPrivilegedRole) {
              areaName = profile['ward'] is Map ? (profile['ward']['wardName'] ?? profile['ward']['_id']).toString() : profile['ward'].toString();
            }
          }

          // Fallback via location chart if areaName is still null for privileged roles
          if ((areaName == null || areaName.isEmpty) && _hasPrivilegedRole) {
              try {
                final DashboardAPI dashApi = DashboardAPI();
                final locRes = await dashApi.getLocationByWardHeadId(user['userId'].toString());
                if (locRes != null) {
                   final locData = locRes['data'] ?? locRes;
                   List wardsArray = [];
                   if (locData is Map && locData['wards'] is List) wardsArray = locData['wards'];
                   else if (locData is List) wardsArray = locData;
                   else if (locData is Map && locData['areaChart'] != null && locData['areaChart']['wards'] is List) wardsArray = locData['areaChart']['wards'];
                   
                   if (wardsArray.isNotEmpty) {
                      final source = wardsArray.first as Map<String, dynamic>;
                      if (roleType == 'district') {
                         areaName = source['district']?['districtName']?.toString() ?? source['ward']?['districtName']?.toString() ?? source['districtName']?.toString();
                      } else if (roleType == 'taluka') {
                         areaName = source['taluka']?['talukaName']?.toString() ?? source['ward']?['talukaName']?.toString() ?? source['talukaName']?.toString();
                      }
                   }
                }
              } catch (e) {
                print("DEV DEBUG - Geofence: Error fallback fetching location: $e");
              }
          }
          
          print("DEV DEBUG - Geofence: Extracted areaName from profile = $areaName");

          if (areaName != null && areaName.isNotEmpty) {
            _assignedAreaName = areaName;
            _isWardUpdated = true;
            print("DEV DEBUG - Geofence: Final assignedAreaName = $_assignedAreaName, _isWardUpdated = true");
          } else {
            print("DEV DEBUG - Geofence: No assignedAreaName could be found.");
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking profile for geofence: $e");
    }

    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (_isWardUpdated || _hasPrivilegedRole) {
        _fetchLiveLocation();
        if (_isWardUpdated) _loadAssignedMap();
      }
    }
  }

  `;

text = text.substring(0, start) + replacement + text.substring(end);

if (!text.includes("import '../../../core/api/dashboard_api.dart';")) {
  text = text.replace("import '../../../core/api/ward_api.dart';", "import '../../../core/api/ward_api.dart';\nimport '../../../core/api/dashboard_api.dart';");
}

fs.writeFileSync('lib/features/geofence/presentation/geofence_screen.dart', text, 'utf-8');
