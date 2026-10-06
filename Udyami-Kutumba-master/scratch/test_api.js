const data = JSON.stringify({ name: 'nik pawar', query: 'nik pawar', role: 'TalukHead', wardName: 'Mathikere', talukaId: 'f9a6257c-7cbe-4c1c-a25a-8403ee801110', districtId: '3a4b9264-bc85-4d60-b74a-32ea61304150' });

fetch('https://backend.udyamikutumba.com/userprofile/search-users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4ZWE5N2E0OS04OGI4LTRiMTQtOTYyNi00MzZmZDNmMDc2ZDciLCJlbWFpbCI6ImthcnRoaWswMkBnbWFpbC5jb20iLCJyb2xlcyI6WyJ0YWx1a2FfaGVhZCJdLCJwb3NpdGlvbklkIjoiZjFmMWY4MzItOTJlNy00MTFhLTg2YzUtOTg5M2MyYjZmZjQ3IiwicGVybWlzc2lvbiI6IlJFQURfT05MWSIsImlhdCI6MTc4ODAyNTYzNSwiZXhwIjoxNzkwNjE3NjM1fQ._PJzdX7pg4TAvvn91dYujX635lulzim1Xd4wgVyDt_k'
  },
  body: data
}).then(res => res.json()).then(data => console.log(JSON.stringify(data))).catch(console.error);
