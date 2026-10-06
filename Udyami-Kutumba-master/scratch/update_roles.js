const fs = require('fs');
let text = fs.readFileSync('lib/features/dashboard/presentation/manage_roles_screen.dart', 'utf-8');

const replacement = `
  @override
  Widget build(BuildContext context) {
    final filteredUsers = _roleUsers.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Manage Roles'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Org Chart'),
              Tab(text: 'Role Cards'),
              Tab(text: 'Assign Roles'),
            ],
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Org Chart
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Organizational Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Text('Best viewed on the Web Dashboard.', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
            
            // Tab 2: Role Cards (Definitions)
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Role Definitions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildRoleDefCard(context, 'State Head', 'Top-level admin across the state.', Colors.purple),
                _buildRoleDefCard(context, 'District Head', 'Manages a specific district.', Colors.blue),
                _buildRoleDefCard(context, 'Taluka Head', 'Manages talukas under a district.', Colors.teal),
                _buildRoleDefCard(context, 'Ward Chairman', 'Manages specific wards.', Colors.green),
                _buildRoleDefCard(context, 'Channel Partner', 'Onboards local businesses.', Colors.orange),
              ],
            ),
            
            // Tab 3: Assign Roles (List of Users)
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRoles,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredUsers.isEmpty
                              ? const Center(child: Text('No role users found.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = filteredUsers[index];
                                    final name = user['name'] ?? 'Unknown User';
                                    final rolesList = user['roles'] as List? ?? [];
                                    final rolesStr = rolesList.map((r) => r['roleName']).join(', ');

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                          child: Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                          ),
                                        ),
                                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                          rolesStr.isNotEmpty ? rolesStr : 'No roles assigned',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                            foregroundColor: Theme.of(context).colorScheme.primary,
                                          ),
                                          onPressed: () {
                                            // Trigger Role Assignment BottomSheet
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Role Assignment form opens here')),
                                            );
                                          },
                                          child: const Text('Assign'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDefCard(BuildContext context, String name, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      color: color.withValues(alpha: 0.05),
      child: ListTile(
        leading: Icon(Icons.admin_panel_settings, color: color),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ),
    );
  }
}
`;

const startIndex = text.indexOf("  @override\n  Widget build(BuildContext context) {");
text = text.substring(0, startIndex) + replacement;

fs.writeFileSync('lib/features/dashboard/presentation/manage_roles_screen.dart', text, 'utf-8');
