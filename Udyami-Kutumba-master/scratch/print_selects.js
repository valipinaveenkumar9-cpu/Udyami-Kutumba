const fs = require('fs');
const text = fs.readFileSync('D:/DigiNik/media/udyamikutumba/udyamiKutumb_web-main/src/components/pages/MemberMap.jsx', 'utf-8');
const filters = text.match(/<select[\s\S]*?<\/select>/g);
if (filters) {
  filters.forEach(f => console.log(f.substring(0, 300) + '...'));
} else {
  console.log('No selects found');
}
