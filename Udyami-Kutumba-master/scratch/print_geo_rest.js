const fs = require('fs');
const text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');
const start = text.indexOf('print("DEV DEBUG - Geofence: Extracted areaName from profile = $areaName");');
const end = text.indexOf('Future<void> _fetchLiveLocation()');
console.log(text.substring(start, end));
