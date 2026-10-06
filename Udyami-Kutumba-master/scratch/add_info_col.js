const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', 'utf-8');

const infoCol = `
  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
`;

const buildIndex = text.lastIndexOf("Widget build(BuildContext context) {");
text = text.substring(0, buildIndex) + infoCol + '\n  @override\n  ' + text.substring(buildIndex);
fs.writeFileSync('lib/features/dashboard/presentation/ucn_dashboard_screen.dart', text, 'utf-8');
