const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(locData is List && locData\.isNotEmpty\) \{[\s\S]*?if \(_districtName\.isEmpty && first\['district'\] != null\)[\s\S]*?_districtName = first\['district'\]\['districtName'\]\?\.toString\(\) \?\? '';\s*\}/;

const replacement = `if (locData is Map) {
                  Map<String, dynamic>? source = locData as Map<String, dynamic>;
                  if (source['taluka'] == null && source['district'] == null && source['wards'] != null && source['wards'] is List && (source['wards'] as List).isNotEmpty) {
                     source = (source['wards'] as List).first as Map<String, dynamic>;
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
                } else if (locData is List && locData.isNotEmpty) {
                  final first = locData.first;
                  if (talukaId == null && first['taluka'] != null)
                    talukaId = first['taluka']['_id']?.toString() ?? first['taluka']['talukaId']?.toString();
                  if (_talukaName.isEmpty && first['taluka'] != null)
                    _talukaName = first['taluka']['talukaName']?.toString() ?? '';
                  if (districtId == null && first['district'] != null)
                    districtId = first['district']['_id']?.toString() ?? first['district']['districtId']?.toString();
                  if (_districtName.isEmpty && first['district'] != null)
                    _districtName = first['district']['districtName']?.toString() ?? '';
                }`;

text = text.replace(regex, replacement);

fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
