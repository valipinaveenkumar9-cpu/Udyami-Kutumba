import 'package:flutter/material.dart';
import 'hall_coordinator_screen.dart';
import 'meetings_screen.dart';
import 'directory_coordinator_screen.dart';
import 'ai_lead_gen_screen.dart';
import 'coordinator_communications_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class CoordinatorsScreen extends StatelessWidget {
  const CoordinatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Coordinators",
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
            // Coral Banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Color(0xFFFF7F50), // Coral
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "UCN coordinator posts · G5 Malleshwaram",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "The networking-related posts from the org chart — chaired & assigned by the Circle leader",
                    style: TextStyle(color: Color(0xFF5D2417), fontSize: 13),
                  ),
                ],
              ),
            ),

            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "Hall", "Booked")),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(context, "Directory", "2 pending")),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard(context, "Announced", "1")),
              ],
            ),
            const SizedBox(height: 24),

            // Launch Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _buildLaunchTile(context, Icons.meeting_room_rounded, "Hall Coordinator", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HallCoordinatorScreen()));
                }),
                _buildLaunchTile(context, Icons.calendar_month_rounded, "Circle Meeting", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MeetingsScreen(userRole: 'Circle Leader')));
                }),
                _buildLaunchTile(context, Icons.menu_book_rounded, "Member Directory", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectoryCoordinatorScreen()));
                }),
                _buildLaunchTile(context, Icons.trending_up_rounded, "AI Lead Gen", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiLeadGenScreen()));
                }),
                _buildLaunchTile(context, Icons.chat_bubble_rounded, "Communications", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CoordinatorCommunicationsScreen()));
                }),
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                "Tap a post to open its tools · assign holders in Circle roles",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLaunchTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.withAlpha(26),
              child: Icon(icon, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
