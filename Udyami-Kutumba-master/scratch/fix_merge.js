const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(_talukaName\.isNotEmpty\) \{[\s\S]*?final sList = _extractList\(searchRes, 'data'\);[\s\S]*?_totalUsers = _usersList\.length;\s*\}\s*\} catch \(\_\) \{\}\s*\}/;

const replacement = `if (_talukaName.isNotEmpty) {
             try {
               final usersRes = await _api.fetchUsersByTaluka(_talukaName);
               _usersList = _extractList(usersRes, 'users');
               _totalUsers = _countUsersSafe(usersRes);
             } catch (_) {}
           }
           if (talukaId != null) {
             try {
               final searchRes = await _api.searchMembers({'talukaId': talukaId});
               final sList = _extractList(searchRes, 'data');
               if (sList.isNotEmpty) {
                 Map<String, dynamic> merged = {};
                 for (var u in _usersList) { if (u['userId'] != null) merged[u['userId'].toString()] = u; }
                 for (var u in sList) { if (u['userId'] != null) merged[u['userId'].toString()] = u; }
                 _usersList = merged.values.toList();
                 if (_usersList.length > _totalUsers) _totalUsers = _usersList.length;
               }
             } catch (_) {}
           }`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
