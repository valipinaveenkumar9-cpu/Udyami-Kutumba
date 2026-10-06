const fs = require('fs');
const text = fs.readFileSync('D:/DigiNik/media/udyamikutumba/udyamiKutumb_web-main/src/components/pages/MemberMap.jsx', 'utf-8');
const start = text.indexOf('Members');
console.log(text.substring(start - 200, start + 800));
