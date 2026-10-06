const fs = require('fs');
const text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');
const start = text.indexOf('Widget _buildWardsOverview()');
console.log(text.substring(start, start + 3000));
