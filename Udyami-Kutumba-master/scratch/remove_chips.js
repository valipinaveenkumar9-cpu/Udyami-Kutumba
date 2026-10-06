const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/member_map_screen.dart', 'utf-8');

// Remove the filter chips UI
text = text.replace(/SingleChildScrollView\([\s\S]*?_buildFilterChip[\s\S]*?const SizedBox\(height: 10\),/g, '');

// Remove the _buildFilterChip function entirely
text = text.replace(/Widget _buildFilterChip[\s\S]*?\}\s*\},[\s\S]*?\);[\s\S]*?\}/g, '');

fs.writeFileSync('lib/features/ward/presentation/member_map_screen.dart', text, 'utf-8');
