const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(talukaId == null \|\| _talukaName\.isEmpty\) \{[\s\S]*?\} catch \(\_\) \{\}\n\s*\}/;

const replacement = `if (talukaId == null || _talukaName.isEmpty || districtId == null || _districtName.isEmpty || wardId == null || _wardName.isEmpty) {
          try {
            final locRes = await _api.getLocationByWardHeadId(userId);
            if (locRes != null && (locRes['success'] == true || locRes['data'] != null)) {
              final locData = locRes['data'] ?? locRes;
              Map<String, dynamic>? source;
              
              if (locData is Map) {
                source = locData as Map<String, dynamic>;
                if (source['taluka'] == null && source['district'] == null && source['wards'] != null && source['wards'] is List && (source['wards'] as List).isNotEmpty) {
                  source = (source['wards'] as List).first as Map<String, dynamic>;
                }
              } else if (locData is List && locData.isNotEmpty) {
                source = locData.first as Map<String, dynamic>;
              }
              
              if (source != null) {
                if (wardId == null && source['ward'] != null) {
                  wardId = source['ward']['_id']?.toString() ?? source['ward']['wardId']?.toString();
                }
                if (_wardName.isEmpty && source['ward'] != null) {
                  _wardName = source['ward']['wardName']?.toString() ?? '';
                }
                if (talukaId == null && source['taluka'] != null) {
                  talukaId = source['taluka']['_id']?.toString() ?? source['taluka']['talukaId']?.toString();
                }
                if (_talukaName.isEmpty && source['taluka'] != null) {
                  _talukaName = source['taluka']['talukaName']?.toString() ?? '';
                }
                if (districtId == null && source['district'] != null) {
                  districtId = source['district']['_id']?.toString() ?? source['district']['districtId']?.toString();
                }
                if (_districtName.isEmpty && source['district'] != null) {
                  _districtName = source['district']['districtName']?.toString() ?? '';
                }
              }
            }
          } catch (_) {}
        }`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
