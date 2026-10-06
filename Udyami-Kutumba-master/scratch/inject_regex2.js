const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

text = text.replace(
  /_allDistrictsCount = _districtsList.length;\s*\}\s*catch\s*\(\_\)\s*\{\}/g,
  "_allDistrictsCount = _districtsList.length; \n            } catch (_) {}\n            print('DEBUG: [Super Admin] Data Fetched -> Users: ${_totalUsers}, Districts: ${_allDistrictsCount}, Heads: ${_allHeadsCount}, CPs: ${_channelPartners}');"
);

text = text.replace(
  /_appointedChairmen = _countData\(chRes\);\s*\}\s*catch\s*\(\_\)\s*\{\}\s*\}/g,
  "_appointedChairmen = _countData(chRes);\n              } catch (_) {}\n            }\n            print('DEBUG: Data Fetched -> Chairmen: ${_appointedChairmen}, CPs: ${_channelPartners}');"
);

fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
