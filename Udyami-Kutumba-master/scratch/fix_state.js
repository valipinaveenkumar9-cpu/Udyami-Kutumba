const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

if (!text.includes('int _activeWards = 0;')) {
  text = text.replace('int _wardsCount = 0;', 'int _wardsCount = 0;\n  int _activeWards = 0;');
  fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
}
