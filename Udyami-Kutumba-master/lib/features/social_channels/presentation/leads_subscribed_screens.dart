import 'package:flutter/material.dart';
import '../../communications/presentation/communications_screen.dart';
import 'social_channels_screen.dart';

class LeadsSubscribedScreens extends StatefulWidget {
  const LeadsSubscribedScreens({super.key});

  @override
  State<LeadsSubscribedScreens> createState() => _LeadsSubscribedScreensState();
}

class _LeadsSubscribedScreensState extends State<LeadsSubscribedScreens> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Leads (Comms)'),
                    Tab(text: 'Social Channels'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CommunicationsScreen(),
                  SocialChannelsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
