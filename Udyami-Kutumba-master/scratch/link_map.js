const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/ward_screen.dart', 'utf-8');
text = text.replace("import '../../geofence/presentation/geofence_screen.dart';", "import 'member_map_screen.dart';");
text = text.replace("const GeofenceScreen()", "const MemberMapScreen()");
fs.writeFileSync('lib/features/ward/presentation/ward_screen.dart', text, 'utf-8');
