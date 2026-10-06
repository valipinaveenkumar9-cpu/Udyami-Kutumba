const fs = require('fs');
const text = fs.readFileSync('D:\\DigiNik\\media\\udyamikutumba\\udyamiKutumb_web-main\\src\\components\\redux\\slices\\areaChartSlice.js', 'utf-8');
const start = text.indexOf('if (talukaId) {');
console.log(text.substring(start, start + 800));
