const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(locData is Map\) \{[\s\S]*?source = locData as Map<String, dynamic>;/;

const replacement = "if (locData is Map) {\n" +
"                source = locData as Map<String, dynamic>;\n" +
"                print('DEV DEBUG - LOCDATA KEYS: ' + source.keys.toList().toString());\n" +
"                if (source['wards'] != null && source['wards'] is List && (source['wards'] as List).isNotEmpty) {\n" +
"                  print('DEV DEBUG - WARDS[0] KEYS: ' + (source['wards'][0] as Map).keys.toList().toString());\n" +
"                  if ((source['wards'][0] as Map)['ward'] != null) {\n" +
"                    print('DEV DEBUG - WARDS[0][ward] KEYS: ' + ((source['wards'][0] as Map)['ward'] as Map).keys.toList().toString());\n" +
"                  }\n" +
"                }";

text = text.replace(regex, replacement);

fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
