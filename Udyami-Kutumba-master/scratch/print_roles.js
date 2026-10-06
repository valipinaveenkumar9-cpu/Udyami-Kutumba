const fs = require('fs');
const text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');
const start = text.indexOf('Future<void> _checkProfileAndRoles()');
console.log(text.substring(start, start + 2500));
