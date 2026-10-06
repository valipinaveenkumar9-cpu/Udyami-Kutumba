const fs = require('fs');
const text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');
const start = text.indexOf('if (_activeTab == \'Overview & Analytics\') {');
console.log(text.substring(start - 200, start + 800));
