const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const regex = /String\? districtId;[\s\S]*?print\("DEV DEBUG - Map: Extracted districtId[\s\S]*?areaName = wardIdOrName;\s*\}/;

const replacement = `
          String? districtId;
          String? talukaId;

          if (profile != null) {
            // Extract District ID safely
            if (profile['district'] is Map) {
               districtId = profile['district']['_id']?.toString() ?? profile['district']['districtId']?.toString();
               if (roleType == 'district') areaName = profile['district']['districtName']?.toString();
            } else {
               if (roleType == 'district') areaName = profile['district']?.toString();
            }
            if (districtId == null && user['district'] != null) {
               districtId = user['district']['_id']?.toString() ?? user['district']['districtId']?.toString();
            }

            // Extract Taluka ID safely
            if (profile['taluka'] is Map) {
               talukaId = profile['taluka']['_id']?.toString() ?? profile['taluka']['talukaId']?.toString();
               if (roleType == 'taluka' && areaName == null) areaName = profile['taluka']['talukaName']?.toString();
            } else {
               if (roleType == 'taluka' && areaName == null && profile['taluka'] != null) areaName = profile['taluka']?.toString();
            }
            if (talukaId == null && user['taluka'] != null) {
               if (user['taluka'] is Map) {
                  talukaId = user['taluka']['_id']?.toString() ?? user['taluka']['talukaId']?.toString();
                  if (roleType == 'taluka' && areaName == null) areaName = user['taluka']['talukaName']?.toString();
               }
            }

            // Fallback using location chart if missing
            try {
              final locRes = await _dashboardAPI.getLocationByWardHeadId(user['userId'].toString());
              if (locRes != null) {
                 final locData = locRes['data'] ?? locRes;
                 List wardsArray = [];
                 if (locData is Map && locData['wards'] is List) wardsArray = locData['wards'];
                 else if (locData is List) wardsArray = locData;
                 else if (locData is Map && locData['areaChart'] != null && locData['areaChart']['wards'] is List) wardsArray = locData['areaChart']['wards'];
                 
                 if (wardsArray.isNotEmpty) {
                    final source = wardsArray.first as Map<String, dynamic>;
                    if (talukaId == null) talukaId = source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? source['ward']?['talukaId']?.toString();
                    if (roleType == 'taluka' && (areaName == null || areaName!.isEmpty)) {
                       areaName = source['taluka']?['talukaName']?.toString() ?? source['ward']?['talukaName']?.toString() ?? source['talukaName']?.toString();
                    }
                 }
              }
            } catch (e) {
              print("DEV DEBUG - Map: Error fallback fetching location: $e");
            }

            print("DEV DEBUG - Map: Extracted districtId: $districtId, talukaId: $talukaId, areaName: $areaName");

            if (roleType == 'district' && districtId != null) {
              _fetchTalukasForDistrict(districtId);
            } else if (roleType == 'taluka' && talukaId != null) {
              _fetchWardsForTaluka(talukaId);
            } else if (profile['ward'] != null) {
              final wardIdOrName = profile['ward'] is Map ? (profile['ward']['wardName'] ?? profile['ward']['_id']).toString() : profile['ward'].toString();
              areaName = wardIdOrName;
            }
          }`;

text = text.replace(regex, replacement.trim());
fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
