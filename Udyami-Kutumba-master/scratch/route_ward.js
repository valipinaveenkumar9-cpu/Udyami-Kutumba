const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/ward_screen.dart', 'utf-8');

if (!text.includes("import '../../dashboard/presentation/ucn_dashboard_screen.dart';")) {
  text = text.replace(
    "import 'member_map_screen.dart';",
    "import 'member_map_screen.dart';\nimport '../../dashboard/presentation/ucn_dashboard_screen.dart';\nimport '../../dashboard/presentation/manage_roles_screen.dart';"
  );
}

text = text.replace(
  "} else if (item['name'] == 'Member Map') {",
  "} else if (item['name'] == 'UCN') {\n                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UcnDashboardScreen()));\n                } else if (item['name'] == 'Manage Roles') {\n                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRolesScreen()));\n                } else if (item['name'] == 'Member Map') {"
);

fs.writeFileSync('lib/features/ward/presentation/ward_screen.dart', text, 'utf-8');
