const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(_usersList\.length > _totalUsers\) _totalUsers = _usersList\.length;\s*\}/;

const replacement = `if (_usersList.length > _totalUsers) _totalUsers = _usersList.length;
               }
               _calculatePlans(_usersList);`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
