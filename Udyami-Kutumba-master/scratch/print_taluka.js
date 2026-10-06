const fs = require('fs');
const text = fs.readFileSync('D:\\DigiNik\\media\\udyamikutumba\\udyamiKutumb_web-main\\src\\components\\redux\\slices\\wardSlice.js', 'utf-8');
const start = text.indexOf('export const fetchTalukasByDistrict');
console.log(text.substring(start, start + 300));
