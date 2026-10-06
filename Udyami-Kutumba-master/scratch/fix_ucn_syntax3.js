const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

text = text.replace(/profileRes\['data'\]\?\['profile'\]/g, "(profileRes['data'] as Map?)?['profile']");
text = text.replace(/source\['taluka'\]\?\['_id'\]/g, "(source['taluka'] as Map?)?['_id']");
text = text.replace(/source\['taluka'\]\?\['talukaId'\]/g, "(source['taluka'] as Map?)?['talukaId']");

// Remove unused local variables
text = text.replace(/final name = circle\['assemblyName'\].*/g, '');
text = text.replace(/final number = circle\['wardNumber'\].*/g, '');
text = text.replace(/final members = circle\['totalMembers'\].*/g, '');
text = text.replace(/final attendance = circle\['attendancePercentage'\].*/g, '');

text = text.replace(/title: Text\('\$number\$name',/g, "title: Text('${circle['wardNumber'] != null ? circle['wardNumber'] + ' ' : ''}${circle['assemblyName'] ?? circle['talukaName'] ?? circle['wardName'] ?? 'Unknown'}',");
text = text.replace(/subtitle: Text\('Members: \$members • Attendance: \$attendance%'\),/g, "subtitle: Text('Members: ${circle['totalMembers'] ?? circle['members'] ?? 0} • Attendance: ${circle['attendancePercentage'] ?? 0}%'),");

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');
