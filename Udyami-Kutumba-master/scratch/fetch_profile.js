const https = require('https');
https.get('https://backend.udyamikutumba.com/userprofile/getUserProfileById/8ea97a49-88b8-4b14-9626-436fd3f076d7', (res) => {
  let body = '';
  res.on('data', d => body += d);
  res.on('end', () => {
    require('fs').writeFileSync('user_profile.json', body, 'utf-8');
    console.log("Saved to user_profile.json");
  });
}).on('error', (e) => {
  console.error(e);
});
