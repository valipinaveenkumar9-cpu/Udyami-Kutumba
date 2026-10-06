const fs = require('fs');
const text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');
const start = text.indexOf('getLocationByWardHeadId');
console.log(text.substring(start - 200, start + 1500));
