const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /try \{\s*final wardRes = await _api\.fetchWardsByTaluka\(talukaId\);\s*_wardsList = _extractList\(wardRes, 'data'\);\s*_wardsCount = _wardsList\.length;\s*_activeWards = 0;\s*for \(var w in _wardsList\) \{\s*int built = 0;\s*if \(w\['booths_built'\] != null\) built = int\.tryParse\(w\['booths_built'\]\.toString\(\)\) \?\? 0;\s*if \(w\['totalMembers'\] != null\) built = int\.tryParse\(w\['totalMembers'\]\.toString\(\)\) \?\? 0;\s*if \(built > 0\) _activeWards\+\+;\s*\}\s*\} catch \(\_\) \{\}/;

const replacement = `try {
              if (_locWards.isNotEmpty) {
                // Map the rich location wards directly so we have member counts for Overview!
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
              }
              _wardsCount = _wardsList.length;
              _activeWards = 0;
              for (var w in _wardsList) {
                int built = 0;
                if (w['booths_built'] != null) built = int.tryParse(w['booths_built'].toString()) ?? 0;
                if (w['totalMembers'] != null) built = int.tryParse(w['totalMembers'].toString()) ?? 0;
                if (built > 0) _activeWards++;
              }
            } catch (_) {}`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
