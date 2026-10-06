const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', 'utf-8');

const newMethod = `
  Widget _buildTabContent() {
    if (_activeTab == 'Wards') {
      return _buildSimpleList(_wardsList, 'wardName', 'wardNumber');
    } else if (_activeTab == 'Ward Chairmen') {
      return _buildSimpleList(_chairmenList, 'name', 'email');
    } else if (_activeTab == 'Channel Partners') {
      return _buildSimpleList(_cpList, 'name', 'email');
    } else if (_activeTab == 'Members') {
      return _buildSimpleList(_usersList, 'name', 'email');
    }
    return const SizedBox();
  }

  Widget _buildSimpleList(List<dynamic> items, String titleKey, String subKey) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No records found.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Text(
                (item[titleKey] ?? '?').toString().substring(0, 1).toUpperCase(),
                style: TextStyle(color: Colors.purple.shade700),
              ),
            ),
            title: Text(item[titleKey]?.toString() ?? 'Unknown'),
            subtitle: Text(item[subKey]?.toString() ?? ''),
          ),
        );
      },
    );
  }
}
`;

text = text.replace(/}\s*$/, newMethod);
fs.writeFileSync('lib/features/dashboard/presentation/dashboard_screen.dart', text, 'utf-8');
