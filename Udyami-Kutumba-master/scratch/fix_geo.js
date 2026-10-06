const fs = require('fs');
let text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');

const regex = /if \(profile != null\) \{[\s\S]*?print\(\s*"DEV DEBUG - Geofence: Extracted areaName from profile = \$areaName",\s*\);\s*\}/;

const replacement = `
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
            print("DEV DEBUG - Geofence: Extracted areaName from profile = $areaName");
          }`;

text = text.replace(regex, replacement.trim());
fs.writeFileSync('lib/features/geofence/presentation/geofence_screen.dart', text, 'utf-8');
