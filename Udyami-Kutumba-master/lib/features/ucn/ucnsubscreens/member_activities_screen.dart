import 'package:flutter/material.dart';
import 'gratitude_history_screen.dart';
import 'my_leads_screen.dart';
import 'face_to_face_screen.dart';
import 'guests_history_screen.dart';

class MemberActivitiesScreen extends StatelessWidget {
  final Map<String, dynamic> memberData;

  const MemberActivitiesScreen({super.key, required this.memberData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = memberData['name']?.toString() ?? 'Member';
    final userId = memberData['userId']?.toString();

    final gratitudeSlips = memberData['gratitudeSlipCount'] ?? memberData['totalGratitudeSlips'] ?? 0;
    final leads = memberData['leadCount'] ?? memberData['totalLeads'] ?? 0;
    final faceToFace = memberData['faceToFaceCount'] ?? memberData['totalFaceToFace'] ?? 0;
    final guests = memberData['guestCount'] ?? memberData['totalGuests'] ?? 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text('$name\'s Activities', style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text('Invalid Member ID'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildActivityCard(
                  context,
                  title: 'Gratitude Slips',
                  count: gratitudeSlips,
                  icon: Icons.receipt_long,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GratitudeHistoryScreen(targetUserId: userId),
                      ),
                    );
                  },
                ),
                _buildActivityCard(
                  context,
                  title: 'Leads',
                  count: leads,
                  icon: Icons.leaderboard,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyLeadsScreen(targetUserId: userId),
                      ),
                    );
                  },
                ),
                _buildActivityCard(
                  context,
                  title: 'Face to Face',
                  count: faceToFace,
                  icon: Icons.handshake,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FaceToFaceScreen(targetUserId: userId),
                      ),
                    );
                  },
                ),
                _buildActivityCard(
                  context,
                  title: 'Guests',
                  count: guests,
                  icon: Icons.person_add,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuestsHistoryScreen(targetUserId: userId),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required dynamic count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Count: $count',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
