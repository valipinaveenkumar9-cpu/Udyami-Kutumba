import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/ubn/uc_training_api.dart';
import '../../../core/models/uc_training_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class UCTrainingScreen extends StatefulWidget {
  const UCTrainingScreen({super.key});

  @override
  State<UCTrainingScreen> createState() => _UCTrainingScreenState();
}

class _UCTrainingScreenState extends State<UCTrainingScreen> {
  int selectedTab = 0;
  late Future<List<UcTrainingModel>> _trainingsFuture;

  @override
  void initState() {
    super.initState();
    _trainingsFuture = UcTrainingAPI().getAllTrainings();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    // Try to open in the YouTube app first
    bool launched = await launchUrl(
      url, 
      mode: LaunchMode.externalNonBrowserApplication,
    );
    
    // If the app is not installed, fallback to the browser
    if (!launched) {
      launched = await launchUrl(
        url, 
        mode: LaunchMode.externalApplication,
      );
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch video')),
      );
    }
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('EEE d MMM').format(dt); // e.g., Thu 24 Jul
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.surface,
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          "My UC Training",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<UcTrainingModel>>(
        future: _trainingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final trainings = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tabs
                // Row(
                //   children: [
                //     Expanded(
                //       child: _tabButton(
                //         title: "My UC Training",
                //         index: 0,
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     // Expanded(
                //     //   child: _tabButton(
                //     //     title: "Schedule",
                //     //     index: 1,
                //     //   ),
                //     // ),
                //     // const SizedBox(width: 8),
                //     // Expanded(
                //     //   child: _tabButton(
                //     //     title: "Topic Library",
                //     //     index: 2,
                //     //   ),
                //     // ),
                //   ],
                // ),
                // const SizedBox(height: 20),

                if (trainings.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("No trainings available.", style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...trainings.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _trainingCard(
                        iconColor: Colors.red,
                        title: "Training Session",
                        subtitle: "By ${t.createdUser.name} · ${_formatDate(t.createdAt)}",
                        badgeText: "Watch",
                        badgeColor: Colors.teal,
                        onTap: () => _launchUrl(t.ytLink),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required int index,
  }) {
    bool selected = selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Theme.of(context).colorScheme.surface : Colors.teal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _trainingCard({
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: iconColor.withOpacity(.15),
              child: Icon(
                Icons.play_arrow,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}