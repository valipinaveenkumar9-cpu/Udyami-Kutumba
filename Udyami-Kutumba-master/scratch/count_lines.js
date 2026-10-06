const fs = require('fs');
const text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');
const lines = text.split('\n');
console.log(lines.length + " lines in member_map_screen.dart");
