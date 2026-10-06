const fs = require('fs');
const text = fs.readFileSync('lib/features/home/presentation/main_screen.dart', 'utf-8');
const start = text.indexOf('title: \'Near By\',');
console.log(text.substring(start, start + 500));
