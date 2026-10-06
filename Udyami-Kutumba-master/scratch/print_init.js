const fs = require('fs');
const text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');
const start = text.indexOf('Future<void> _checkProfileAndInit()');
const end = text.indexOf('Future<void> _fetchLocationAndData');
console.log(text.substring(start, end));
