const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');
text = text.replace("@override\n  \n  Widget _buildInfoCol", "Widget _buildInfoCol");
fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');
