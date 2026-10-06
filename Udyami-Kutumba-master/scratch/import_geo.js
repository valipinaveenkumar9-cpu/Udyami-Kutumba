const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/ward_screen.dart', 'utf-8');
if (!text.includes('geofence_screen.dart')) {
  text = text.replace("import '../../dashboard/presentation/dashboard_screen.dart';", "import '../../dashboard/presentation/dashboard_screen.dart';\nimport '../../geofence/presentation/geofence_screen.dart';");
  fs.writeFileSync('lib/features/ward/presentation/ward_screen.dart', text, 'utf-8');
}
