const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');
if (!text.includes('List<dynamic> _locWards = [];')) {
  text = text.replace('List<dynamic> _wardsList = [];', 'List<dynamic> _wardsList = [];\n  List<dynamic> _locWards = [];');
  fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
}
