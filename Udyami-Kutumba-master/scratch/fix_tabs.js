const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const regex = /if \(_highestRole == 'taluka_head' &&\s*_activeTab != 'Overview & Analytics'\)[\s\S]*?const SizedBox\(height: 40\),/;

const replacement = `if (_highestRole == 'taluka_head' && _activeTab != 'Overview & Analytics')
                      _buildTabContent(),
                    const SizedBox(height: 40),`;

text = text.replace(regex, replacement);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
