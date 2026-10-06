const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const badText = `          try {
            try { _cpSubmissions = _countData(await _api.fetchCpSubmissions(userId), key: 'submissions'); } catch (_) {}
           print('DEBUG: [Ward Chairman] Data Fetched -> Users: ${_totalUsers}, Cloud Patra: ${_cloudPatra}, Submissions: ${_cpSubmissions}, CPs: ${_channelPartners}');
          }`;

const goodText = `          try { _cpSubmissions = _countData(await _api.fetchCpSubmissions(userId), key: 'submissions'); } catch (_) {}
           print('DEBUG: [Ward Chairman] Data Fetched -> Users: ${_totalUsers}, Cloud Patra: ${_cloudPatra}, Submissions: ${_cpSubmissions}, CPs: ${_channelPartners}');`;

text = text.replace(badText, goodText);

fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
