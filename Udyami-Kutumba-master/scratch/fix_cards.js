const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

// First compute active wards in the taluka block
const apiRegex = /_wardsCount = _wardsList\.length;\s*\}\s*catch\s*\(\_\)\s*\{\}/;
const apiReplacement = `_wardsCount = _wardsList.length;
               _activeWards = 0;
               for (var w in _wardsList) {
                 int built = 0;
                 if (w['booths_built'] != null) built = int.tryParse(w['booths_built'].toString()) ?? 0;
                 if (w['totalMembers'] != null) built = int.tryParse(w['totalMembers'].toString()) ?? 0;
                 if (built > 0) _activeWards++;
               }
             } catch (_) {}`;

text = text.replace(apiRegex, apiReplacement);

// Fix Chairmen logic
const chRegex = /_chairmenList = _extractList\(chRes, 'data'\);\s*_appointedChairmen = _countData\(chRes\);\s*\} catch \(\_\) \{\}/;
const chReplacement = `_chairmenList = _extractList(chRes, 'data');
               // The web app fetches ALL chairmen in the system using fetchHeadsByRole and adds them!
               // But we will stick to the accurate count for this Taluka:
               _appointedChairmen = _chairmenList.length;
             } catch (_) {}`;
text = text.replace(chRegex, chReplacement);

// Fix the UI text
const cardRegex1 = /'\\\$_wardsCount Active · 0 Chairmen Vacant'/g;
const cardRegex2 = /'\\\$_appointedChairmen active chairmen'/g;

text = text.replace(/'\$_wardsCount Active · 0 Chairmen Vacant'/g, "'${_activeWards} Active · ${_wardsCount > _appointedChairmen ? _wardsCount - _appointedChairmen : 0} Chairmen Vacant'");
text = text.replace(/'\$_appointedChairmen active chairmen'/g, "'${_appointedChairmen} active chairmen'");

fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
