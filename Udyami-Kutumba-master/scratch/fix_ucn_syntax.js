const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

// Fix missing parenthesis for ternary
text = text.replace(/profile\['district'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(profile['district']['_id']?.toString() ?? '')");
text = text.replace(/user\['district'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(user['district']['_id']?.toString() ?? '')");
text = text.replace(/profile\['taluka'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(profile['taluka']['_id']?.toString() ?? '')");
text = text.replace(/source\['taluka'\]\['talukaId'\]\?\.toString\(\) \?\? ''/g, "(source['taluka']['talukaId']?.toString() ?? '')");
text = text.replace(/profile\['ward'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(profile['ward']['_id']?.toString() ?? '')");

// Wait, the error is likely because `source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? ''`
text = text.replace(/source\['taluka'\]\?\['_id'\]\?\.toString\(\) \?\? source\['taluka'\]\?\['talukaId'\]\?\.toString\(\) \?\? ''/g, "(source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? '')");


// Also remove backticks that got rendered literally! I used powershell here-strings, but wait, maybe `` ` `` got printed!
text = text.replace(/`\$\{/g, '${');
text = text.replace(/`\$e/g, '$e');
text = text.replace(/?`/g, '?');

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');
