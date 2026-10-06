const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');
const regex = /_channelPartners = _countData\(await _api.fetchChannelPartners\(\)\);/;
text = text.replace(regex, `final cpRes = await _api.fetchChannelPartners();\n             _cpList = _extractList(cpRes, 'data');\n             _channelPartners = _countData(cpRes);`);
if (!text.includes('List<dynamic> _cpList = [];')) {
  text = text.replace('int _channelPartners = 0;', 'int _channelPartners = 0;\n  List<dynamic> _cpList = [];');
}
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
