const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const regex = /if \(profile != null\) \{[\s\S]*?print\(\s*"DEV DEBUG - Geofence: Extracted areaName from profile = \$areaName",\s*\);\s*\}/;

const replacement = `
          String? districtId;
          String? talukaId;

          if (profile != null) {
            // Extract District ID safely
            if (profile['district'] is Map) {
               districtId = profile['district']['_id']?.toString() ?? profile['district']['districtId']?.toString();
               areaName = profile['district']['districtName']?.toString();
            } else {
               areaName = profile['district']?.toString();
            }
            if (districtId == null && user['district'] != null) {
               districtId = user['district']['_id']?.toString() ?? user['district']['districtId']?.toString();
            }

            // Extract Taluka ID safely
            if (profile['taluka'] is Map) {
               talukaId = profile['taluka']['_id']?.toString() ?? profile['taluka']['talukaId']?.toString();
               if (areaName == null) areaName = profile['taluka']['talukaName']?.toString();
            } else {
               if (areaName == null) areaName = profile['taluka']?.toString();
            }
            if (talukaId == null && user['taluka'] != null) {
               talukaId = user['taluka']['_id']?.toString() ?? user['taluka']['talukaId']?.toString();
            }

            // Fallback for Taluka ID using location chart if missing
            if (roleType == 'taluka' && talukaId == null) {
               try {
                 final locRes = await _wardAPI.getLocationByWardHeadId(user['userId'].toString(), '');
                 if (locRes != null && locRes['success'] == true) {
                    final locData = locRes['data']?['areaChart']?['wards'] ?? [];
                    if (locData.isNotEmpty) {
                       final source = locData.first as Map<String, dynamic>;
                       talukaId = source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString();
                    }
                 }
               } catch (e) {
                 print("DEV DEBUG - Map: Error fallback fetching talukaId: $e");
               }
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
          }
`;

text = text.replace(regex, replacement.trim());
fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
