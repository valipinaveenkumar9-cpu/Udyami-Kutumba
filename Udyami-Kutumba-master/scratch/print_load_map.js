const fs = require('fs');
const text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');
const start = text.indexOf('Future<void> _loadAssignedMap()');
console.log(text.substring(start, start + 1000));
