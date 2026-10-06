const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/ward_screen.dart', 'utf-8');

if (!text.includes("final DashboardAPI _dashboardAPI = DashboardAPI();")) {
  text = text.replace("final LocationAPI _locationAPI = LocationAPI();", "final LocationAPI _locationAPI = LocationAPI();\n  final DashboardAPI _dashboardAPI = DashboardAPI();");
}

const newFetch = `
  Future<void> _fetchWardMembers(String wardId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingMembers = true;
      _wardMembers = [];
    });

    try {
      final res = await _dashboardAPI.searchMembers({'ward': wardId, 'limit': 100});
      if (res != null && res['success'] == true && res['data'] != null) {
        final List<dynamic> users = res['data']['users'] ?? [];
        if (mounted) {
          setState(() {
            _wardMembers = users.map((u) {
              final roles = u['roles'] as List? ?? [];
              String roleStr = 'Member';
              if (roles.isNotEmpty) {
                 roleStr = roles.map((r) => r['roleName']).join(', ');
              }
              String planStr = 'Basic';
              if (u['isPrime'] == true) planStr = 'Prime';
              if (u['isPatron'] == true) planStr = 'Patron';

              return WardMemberModel(
                memberId: u['userId']?.toString() ?? '',
                userId: u['userId']?.toString() ?? '',
                name: u['name'] ?? 'Unknown',
                role: roleStr,
                profileImage: u['profileImage'],
                mobileNumber: u['mobileNumber']?.toString(),
                email: u['email'],
                companyName: planStr, // Abusing companyName to store plan string for now, or just handle in UI
              );
            }).toList();
            _isLoadingMembers = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingMembers = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }
`;

const startIndex = text.indexOf("Future<void> _fetchWardMembers");
const endIndex = text.indexOf("Widget build(BuildContext context) {", startIndex);

// Also need to find `@override` before `Widget build`.
const overrideIndex = text.lastIndexOf("@override", endIndex);

text = text.substring(0, startIndex) + newFetch + '\n  ' + text.substring(overrideIndex);

// Let's also update `_buildMemberCard` to show the plan correctly if we abused companyName.
text = text.replace(
  "if (member.companyName != null && member.companyName!.isNotEmpty) ...[",
  "if (member.companyName != null && member.companyName!.isNotEmpty) ...[\n                            const SizedBox(width: 6),\n                            Container(\n                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),\n                              decoration: BoxDecoration(\n                                color: member.companyName == 'Prime' ? Colors.orange.withValues(alpha: 0.1) : (member.companyName == 'Patron' ? Colors.purple.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),\n                                borderRadius: BorderRadius.circular(6),\n                              ),\n                              child: Text(\n                                member.companyName!,\n                                style: TextStyle(\n                                  color: member.companyName == 'Prime' ? Colors.orange : (member.companyName == 'Patron' ? Colors.purple : Colors.grey),\n                                  fontSize: 11,\n                                  fontWeight: FontWeight.w600,\n                                ),\n                              ),\n                            ),\n                          ],"
);

fs.writeFileSync('lib/features/ward/presentation/ward_screen.dart', text, 'utf-8');
