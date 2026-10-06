const fs = require('fs');
const text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');
const start = text.indexOf('Future<void> _checkProfileAndInit()');
const end = text.indexOf('Future<void> _fetchLiveLocation()');
console.log(text.substring(start, end));
