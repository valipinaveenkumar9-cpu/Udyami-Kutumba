const fs = require('fs');
const text = fs.readFileSync('lib/core/api/ward_api.dart', 'utf-8');
const start = text.indexOf('getWardMap');
console.log(text.substring(start, start + 800));
