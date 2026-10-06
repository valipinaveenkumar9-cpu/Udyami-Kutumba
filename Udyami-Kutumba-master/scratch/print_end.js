const fs = require('fs');
const text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');
console.log(text.substring(text.length - 1500));
