const fs = require('fs');
const data = JSON.parse(fs.readFileSync('location_response.json', 'utf-8'));
console.log("Root Keys:", Object.keys(data));
console.log("Data Keys:", Object.keys(data.data));
if (data.data.taluka) console.log("Has data.taluka");
if (data.data.district) console.log("Has data.district");
if (data.data.wards && data.data.wards[0]) {
  console.log("Ward 0 keys:", Object.keys(data.data.wards[0]));
  if (data.data.wards[0].taluka) console.log("Has data.wards[0].taluka");
  console.log("Ward 0 ward keys:", Object.keys(data.data.wards[0].ward));
  console.log("Ward 0 ward taluka info:", data.data.wards[0].ward.talukaName, data.data.wards[0].ward.talukaId, data.data.wards[0].ward.taluka);
}
