const fs = require('fs');
let text = fs.readFileSync('lib/features/ward/presentation/ward_screen.dart', 'utf-8');

const replacement = `
  Widget _buildMemberCard(WardMemberModel member, ThemeData theme) {
    String name = member.name.trim();
    final imageUrl = member.profileImage ?? '';

    String displayRole = member.role.replaceAll('_', ' ').split(' ').map((str) => str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : '').join(' ');

    if (name.isEmpty) {
      name = 'Area ' + displayRole;
    }
    
    String planText = 'Basic';
    Color planColor = Colors.grey;
    if (member.isPatron) {
      planText = 'Patron';
      planColor = Colors.purple;
    } else if (member.isPrime) {
      planText = 'Prime';
      planColor = Colors.amber.shade700;
    }

    ImageProvider? imageProvider;
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',').last;
          final bytes = const Base64Decoder().convert(base64String);
          imageProvider = MemoryImage(bytes);
        } catch (e) {}
      } else {
        imageProvider = NetworkImage(imageUrl);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayRole,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: planColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              planText,
                              style: TextStyle(
                                color: planColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (member.mobileNumber != null && member.mobileNumber!.isNotEmpty)
              _buildProfileDetailRow(Icons.phone, 'Phone', member.mobileNumber!, theme),
            if (member.email != null && member.email!.isNotEmpty)
              _buildProfileDetailRow(Icons.email, 'Email', member.email!, theme),
            if (member.companyName != null && member.companyName!.isNotEmpty)
              _buildProfileDetailRow(Icons.business, 'Company', member.companyName!, theme),
          ],
        ),
      ),
    );
  }
`;

text = text.replace(/Widget _buildMemberCard\([\s\S]*?Widget _buildProfileDetailRow/m, replacement + '\n\n  Widget _buildProfileDetailRow');

fs.writeFileSync('lib/features/ward/presentation/ward_screen.dart', text, 'utf-8');
