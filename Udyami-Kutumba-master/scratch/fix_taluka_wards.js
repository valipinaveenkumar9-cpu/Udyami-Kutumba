const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const regex = /if \(roleType == 'taluka' && profile\['taluka'\] != null\) \{[\s\S]*?areaName = profile\['taluka'\];\s*\}/;
const replacement = `if (roleType == 'taluka' && profile['taluka'] != null) {
              areaName = profile['taluka'];
              _fetchWardsForTaluka(profile['taluka']);
            }`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
