import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
import 'attendance_summary_list_screen.dart';

class MeetingSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final String? meetingId;

  const MeetingSummaryScreen({
    super.key,
    required this.summaryData,
    this.meetingId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Safely extract data
    final leads = summaryData['leads'] ?? {};
    final guests = summaryData['guests'] ?? {};
    final f2f = summaryData['faceToFace'] ?? {};
    final gratitude = summaryData['gratitudeSlips'] ?? {};
    final attendance = summaryData['attendance'] ?? {};

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "Meeting Summary",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Meeting Ended Successfully",
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Final scorecard for this meeting",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              "Scorecard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              context,
              "Attendance (${attendance['total'] ?? 0})",
              Icons.people,
              Colors.blue,
              [
                "Total: ${attendance['total'] ?? 0}",
                "Present: ${attendance['present'] ?? 0}",
                "Absent: ${attendance['absent'] ?? 0}",
              ],
              onTap: meetingId != null
                  ? () {
                      // Build attendance list from summary data if available
                      final List<dynamic> attendanceList = [];
                      if (attendance['presentUsers'] is List) {
                        for (final u in attendance['presentUsers']) {
                          attendanceList.add({
                            'userId': u['userId'],
                            'userName': u['name'] ?? u['userName'] ?? 'Unknown',
                            'status': u['status'] ?? 'Present',
                            'attendanceType': u['attendanceType'],
                            'scanTime': u['scanTime'],
                          });
                        }
                      }
                      if (attendance['absentUsers'] is List) {
                        for (final u in attendance['absentUsers']) {
                          attendanceList.add({
                            'userId': u['userId'],
                            'userName': u['name'] ?? u['userName'] ?? 'Unknown',
                            'status': u['status'] ?? 'Absent',
                          });
                        }
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceSummaryListScreen(
                            meetingId: meetingId!,
                            attendanceData: attendanceList.isNotEmpty ? attendanceList : null,
                          ),
                        ),
                      );
                    }
                  : null,
            ),

            _buildStatCard(context, "Leads", Icons.leaderboard, Colors.orange, [
              "Total: ${leads['total'] ?? 0}",
              "Hot: ${leads['hot'] ?? 0} | Warm: ${leads['warm'] ?? 0} | Cold: ${leads['cold'] ?? 0}",
              "Converted: ${leads['converted'] ?? 0}",
            ]),

            _buildStatCard(context, "Guests", Icons.person_add, Colors.purple, [
              "Total: ${guests['total'] ?? 0}",
              "Confirmed: ${guests['confirmed'] ?? 0}",
            ]),

            _buildStatCard(
              context,
              "Face To Face",
              Icons.handshake,
              Colors.teal,
              [
                "Total: ${f2f['total'] ?? 0}",
                "Completed: ${f2f['completed'] ?? 0}",
              ],
            ),

            _buildStatCard(
              context,
              "Gratitude Slips",
              Icons.receipt_long,
              Colors.indigo,
              [
                "Total: ${gratitude['total'] ?? 0}",
                "Business Value: ₹${gratitude['totalBusinessValue'] ?? 0}",
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Meetings',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> details, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
                  Text(
                    d,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }
}
