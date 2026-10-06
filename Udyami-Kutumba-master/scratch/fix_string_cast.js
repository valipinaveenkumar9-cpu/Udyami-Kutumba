const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

text = text.replace(/String\(val\)/g, "val.toString()");

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
