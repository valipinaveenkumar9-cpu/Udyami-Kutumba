const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const startStr = "final wardRes = await _api.fetchWardsByTaluka(talukaId);";
const idx = text.indexOf(startStr);
if (idx > -1) {
  const replaceStr = `if (_locWards.isNotEmpty) {
                _wardsList = _locWards.map((e) {
                  final wardInfo = e['ward'] ?? {};
                  return {
                    'wardNumber': wardInfo['wardNumber'],
                    'wardName': wardInfo['wardName'],
                    'constituency': wardInfo['constituencyName'] ?? wardInfo['talukaName'],
                    'totalMembers': e['totalWardChartMembers'] ?? e['totalMembers'] ?? 0,
                    'layoutCount': wardInfo['layoutCount'] ?? 100,
                  };
                }).toList();
              } else {
                final wardRes = await _api.fetchWardsByTaluka(talukaId);
                _wardsList = _extractList(wardRes, 'data');
              }`;
  
  // replace "final wardRes = ... \n _wardsList = ..."
  const endIdx = text.indexOf("_wardsCount = _wardsList.length;", idx);
  
  if (endIdx > -1) {
    const before = text.substring(0, idx);
    const after = text.substring(endIdx);
    text = before + replaceStr + "\n              " + after;
    fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
  }
}
