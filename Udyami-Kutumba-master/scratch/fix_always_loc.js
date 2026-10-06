const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(talukaId == null \|\|[\s\S]*?wardId == null \|\|[\s\S]*?_wardName\.isEmpty\) \{([\s\S]*?try \{[\s\S]*?final locRes = await _api\.getLocationByWardHeadId\(userId\);[\s\S]*?\}\s*\} catch \(\_\) \{\}\s*\})/;

const replacement = `// ALWAYS fetch location data to get rich charts (wards array with totalMembers)
        try {
          final locRes = await _api.getLocationByWardHeadId(userId);
          if (locRes != null && (locRes['success'] == true || locRes['data'] != null)) {
            final locData = locRes['data'] ?? locRes;
            if (locData is Map && locData['wards'] != null && locData['wards'] is List) {
              _locWards = locData['wards'] as List;
            } else if (locData is List) {
              _locWards = locData;
            }
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
              if (wardId == null) wardId = source['ward']?['_id']?.toString() ?? source['ward']?['wardId']?.toString();
              if (_wardName.isEmpty) _wardName = source['ward']?['wardName']?.toString() ?? source['wardName']?.toString() ?? '';
              if (talukaId == null) talukaId = source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? source['ward']?['talukaId']?.toString();
              if (_talukaName.isEmpty) _talukaName = source['taluka']?['talukaName']?.toString() ?? source['ward']?['talukaName']?.toString() ?? source['talukaName']?.toString() ?? '';
              if (districtId == null) districtId = source['district']?['_id']?.toString() ?? source['district']?['districtId']?.toString() ?? source['ward']?['districtId']?.toString();
              if (_districtName.isEmpty) _districtName = source['district']?['districtName']?.toString() ?? source['ward']?['districtName']?.toString() ?? source['districtName']?.toString() ?? '';
            }
          }
        } catch (_) {}`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
