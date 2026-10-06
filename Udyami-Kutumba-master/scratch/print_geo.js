const fs = require('fs');
const text = fs.readFileSync('lib/features/geofence/presentation/geofence_screen.dart', 'utf-8');
console.log(text.substring(0, 1500));
