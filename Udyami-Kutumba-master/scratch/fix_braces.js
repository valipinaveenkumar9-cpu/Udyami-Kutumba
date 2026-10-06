const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

const buggyStr = `              areaName = wardIdOrName;
            }
          }
          }

          if ((areaName == null || areaName.isEmpty) &&
              user['position'] != null) {`;

const fixedStr = `              areaName = wardIdOrName;
            }
          }

          if ((areaName == null || areaName.isEmpty) &&
              user['position'] != null) {`;

text = text.replace(buggyStr, fixedStr);

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
