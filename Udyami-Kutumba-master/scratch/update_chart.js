const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/area_chart_screen.dart', 'utf-8');

// 1. Fix the Image base64 issue in _buildSlotCard
text = text.replace(
  "backgroundImage: assigned['photoUrl'] != null ? NetworkImage(assigned['photoUrl']) : null,",
  `backgroundImage: assigned['photoUrl'] != null 
    ? (assigned['photoUrl'].toString().startsWith('data:') 
        ? MemoryImage(const Base64Decoder().convert(assigned['photoUrl'].toString().split(',').last)) as ImageProvider
        : NetworkImage(assigned['photoUrl']))
    : null,`
);

// 2. We need to dynamically extract ALL sectors and UMS from _assignments to render them!
// Currently the build method has hardcoded lists. Let's replace the hardcoded build method.
const newBuild = `  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // Dynamically collect all slots from assignments
    final List<String> coreKeys = ['core-president', 'core-vice-president', 'core-general-secretary', 'core-treasurer'];
    final Map<String, String> coreLabels = {
      'core-president': 'President',
      'core-vice-president': 'Vice President',
      'core-general-secretary': 'General Secretary',
      'core-treasurer': 'Treasurer',
    };

    final List<String> allSectorKeys = ['sector-msme', 'sector-healthcare', 'sector-education'];
    final List<String> allUmsKeys = ['ums-ai', 'ums-finance'];

    for (var key in _assignments.keys) {
      if (key.startsWith('core-') && !coreKeys.contains(key)) coreKeys.add(key);
      if (key.startsWith('sector-') && !allSectorKeys.contains(key)) allSectorKeys.add(key);
      if (key.startsWith('ums-') && !allUmsKeys.contains(key)) allUmsKeys.add(key);
    }

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection('Leadership', [
            _buildSlotCard('mla', _assignments['mla']?['slotLabel'] ?? 'Hon. MLA'),
            _buildSlotCard('ward-chairman', _assignments['ward-chairman']?['slotLabel'] ?? 'Ward Chairman'),
          ]),
          _buildSection('Core Team', coreKeys.map((k) => 
            _buildSlotCard(k, _assignments[k]?['slotLabel'] ?? coreLabels[k] ?? k.replaceFirst('core-', '').toUpperCase())
          ).toList()),
          _buildSection('Sectors', allSectorKeys.map((k) => 
            _buildSlotCard(k, _assignments[k]?['slotLabel'] ?? k.replaceFirst('sector-', '').toUpperCase() + ' Head')
          ).toList()),
          _buildSection('UMS Management', allUmsKeys.map((k) => 
            _buildSlotCard(k, _assignments[k]?['slotLabel'] ?? k.replaceFirst('ums-', '').toUpperCase() + ' Head')
          ).toList()),
        ],
      ),
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ward.wardName} Chart'),
        actions: [
          if (widget.showPdf) ...[
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'Customize Layout',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChartBuilderScreen(ward: widget.ward)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Download PDF',
              onPressed: () {},
            ),
          ]
        ],
      ),
      body: content,
    );
  }`;

text = text.replace(/@override\s+Widget build\(BuildContext context\) \{[\s\S]*\}\s*\n\s*\}\s*$/, newBuild + '\n}\n');

fs.writeFileSync('lib/features/ward/presentation/area_chart_screen.dart', text, 'utf-8');

