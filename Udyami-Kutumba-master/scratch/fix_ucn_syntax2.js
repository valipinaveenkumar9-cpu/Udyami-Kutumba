const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

text = text.replace(/profile\['district'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(profile['district']['_id']?.toString() ?? '')");
text = text.replace(/user\['district'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(user['district']['_id']?.toString() ?? '')");
text = text.replace(/profile\['taluka'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(profile['taluka']['_id']?.toString() ?? '')");
text = text.replace(/source\['taluka'\]\['talukaId'\]\?\.toString\(\) \?\? ''/g, "(source['taluka']['talukaId']?.toString() ?? '')");
text = text.replace(/profile\['ward'\]\['_id'\]\?\.toString\(\) \?\? ''/g, "(profile['ward']['_id']?.toString() ?? '')");

text = text.replace(/source\['taluka'\]\?\['_id'\]\?\.toString\(\) \?\? source\['taluka'\]\?\['talukaId'\]\?\.toString\(\) \?\? ''/g, "(source['taluka']?['_id']?.toString() ?? source['taluka']?['talukaId']?.toString() ?? '')");

text = text.replace(/`/g, '');
text = text.replace(/withOpacity/g, 'withValues(alpha: ');
text = text.replace(/0\.1\)/g, '0.1)'); // Just to fix the missing bracket if we blindly replace 
// Wait, withValues(alpha: 0.1)
text = text.replace(/withValues\(alpha: \(/g, 'withValues(alpha: ');

fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');

let mrText = fs.readFileSync('lib/features/dashboard/presentation/manage_roles_screen.dart', 'utf-8');
mrText = mrText.replace(/`/g, '');
mrText = mrText.replace(/withOpacity\(0\.3\)/g, 'withValues(alpha: 0.3)');
mrText = mrText.replace(/withOpacity\(0\.1\)/g, 'withValues(alpha: 0.1)');
fs.writeFileSync('lib/features/dashboard/presentation/manage_roles_screen.dart', mrText, 'utf-8');

