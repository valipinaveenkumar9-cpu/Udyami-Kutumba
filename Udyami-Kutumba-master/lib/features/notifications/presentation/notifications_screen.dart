import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notifications for all modules
    final List<NotificationItem> notifications = [
      NotificationItem(
        title: 'New Member in your Ward',
        message: 'Rahul Sharma just joined the Koramangala Ward. Say hi!',
        time: '10 mins ago',
        icon: Icons.domain_rounded,
        iconColor: Colors.blue,
        bgColor: Colors.blue.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'UCN Meeting Scheduled',
        message: 'Your upcoming networking meeting is scheduled for tomorrow at 10 AM.',
        time: '1 hour ago',
        icon: Icons.handshake_rounded,
        iconColor: Colors.orange,
        bgColor: Colors.orange.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'New Flutter Developer Job',
        message: 'A new remote job matching your profile has been posted in Explore.',
        time: '2 hours ago',
        icon: Icons.work_rounded,
        iconColor: Colors.teal,
        bgColor: Colors.teal.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'Business Requirement Match',
        message: 'ABC Tech is looking for software services. Check their requirement.',
        time: '3 hours ago',
        icon: Icons.assignment_rounded,
        iconColor: Colors.purple,
        bgColor: Colors.purple.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'Financial Update',
        message: 'Your monthly wallet summary is ready to view.',
        time: '5 hours ago',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Colors.green,
        bgColor: Colors.green.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'UQueens Summit 2026',
        message: 'Registration for the annual Women Entrepreneur Summit is now open!',
        time: '1 day ago',
        icon: Icons.stars_rounded,
        iconColor: Colors.pink,
        bgColor: Colors.pink.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'Profile Card Viewed',
        message: 'Your Digital ID Card was viewed by 15 people this week.',
        time: '1 day ago',
        icon: Icons.credit_card_rounded,
        iconColor: Colors.indigo,
        bgColor: Colors.indigo.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'New Directory Connection',
        message: 'Priya Reddy sent you a connection request.',
        time: '2 days ago',
        icon: Icons.contact_phone_rounded,
        iconColor: Colors.amber.shade700,
        bgColor: Colors.amber.withValues(alpha: 0.1),
      ),
      NotificationItem(
        title: 'Campaign Delivered',
        message: 'Your SMS marketing campaign was successfully delivered.',
        time: '2 days ago',
        icon: Icons.campaign_rounded,
        iconColor: Colors.red,
        bgColor: Colors.red.withValues(alpha: 0.1),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
              const ThemeToggleButton(),
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: Colors.teal),
            tooltip: 'Mark all as read',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.delayed(const Duration(milliseconds: 400)),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 70, color: Colors.black12),
          itemBuilder: (context, index) {
            final notif = notifications[index];
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notif.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(notif.icon, color: notif.iconColor, size: 24),
              ),
              title: Text(
                notif.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xff0D1B4C)),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.message,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 13, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.time,
                      style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}
