import 'package:flutter/material.dart';
import 'calendar_tab.dart';
import 'campaigns_screen.dart';
import 'incidents_screen.dart';
import 'overview_screen.dart';
import 'profile_screen.dart';
import 'review_approvals_screen.dart';
import 'widgets/marketos_theme.dart';
import '../../../core/api/membership/membership_purchase_api.dart';
import '../../../core/utils/session_manager.dart';
import '../../ucn/ucnsubscreens/ucn_subscription_screen.dart';

typedef SocialChannelScreen = SocialChannelsScreen;

class _SocialChannelNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _SocialChannelNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class SocialChannelsScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool? showAppBar;

  const SocialChannelsScreen({
    super.key,
    this.initialTabIndex = 0,
    this.showAppBar,
  });

  @override
  State<SocialChannelsScreen> createState() => _SocialChannelsScreenState();
}

class _SocialChannelsScreenState extends State<SocialChannelsScreen> {
  late int _currentIndex;
  final ScrollController _navScrollController = ScrollController();
  late PageController _pageController;

  bool _isDigitalMarketingSubscribed = false;
  bool _isLoadingSubscription = true;
  final MembershipPurchaseAPI _membershipAPI = MembershipPurchaseAPI();

  static const List<_SocialChannelNavItem> _navItems = [
    _SocialChannelNavItem(
      label: 'Overview',
      icon: Icons.grid_view_rounded,
      selectedIcon: Icons.grid_view_rounded,
    ),
    _SocialChannelNavItem(
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    _SocialChannelNavItem(
      label: 'Campaigns',
      icon: Icons.radio_button_checked_rounded,
      selectedIcon: Icons.radio_button_checked_rounded,
    ),
    _SocialChannelNavItem(
      label: 'Incidents',
      icon: Icons.warning_amber_rounded,
      selectedIcon: Icons.warning_rounded,
    ),
    _SocialChannelNavItem(
      label: 'Profile',
      icon: Icons.account_circle_outlined,
      selectedIcon: Icons.account_circle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, 4);
    _pageController = PageController(initialPage: _currentIndex);
    _checkSubscriptionStatus();
    SessionManager.profileUpdateNotifier.addListener(_checkSubscriptionStatus);
  }

  @override
  void dispose() {
    SessionManager.profileUpdateNotifier.removeListener(_checkSubscriptionStatus);
    _navScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _scrollToTab(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _scrollToTab(index);
  }

  void _scrollToTab(int index) {
    if (!_navScrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (index * 100.0) - (screenWidth / 2) + 50.0;
    
    _navScrollController.animateTo(
      targetOffset.clamp(0.0, _navScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkSubscriptionStatus() async {
    final user = SessionManager.user;
    if (user != null && user['userId'] != null) {
      try {
        final histRes = await _membershipAPI.getMembershipHistory(user['userId'].toString());
        if (histRes != null && histRes['success'] == true) {
          final List<dynamic> data = histRes['data'] ?? [];
          final now = DateTime.now();
          bool hasDigitalMarketing = false;
          for (var item in data) {
            final plan = item['plan'] ?? {};
            if (plan['membershipType'] == 'DIGITAL_MARKETING') {
              if (item['endDate'] != null) {
                final endDate = DateTime.tryParse(item['endDate'].toString());
                if (endDate != null && endDate.isAfter(now)) {
                  hasDigitalMarketing = true;
                  break;
                }
              }
            }
          }
          if (user['isDigital'] == true) {
            hasDigitalMarketing = true;
          }
          if (mounted) {
            setState(() {
              _isDigitalMarketingSubscribed = hasDigitalMarketing;
              _isLoadingSubscription = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingSubscription = false);
        }
      } catch (e) {
        if (mounted) setState(() => _isLoadingSubscription = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingSubscription = false);
    }
  }

  Widget _buildJoinDigitalMarketingUI(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade900,
              Colors.teal.shade700,
              Colors.teal.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.amberAccent,
                size: 80,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Unlock AI Marketing",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Join the Digital Marketing Plan to let our AI automatically generate, schedule, and publish posts to all your social channels.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UcnSubscriptionScreen()),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.teal.shade900,
                  elevation: 10,
                  shadowColor: Colors.amberAccent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  "Subscribe to Digital Marketing",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalNavMenu({
    required Color surf,
    required Color text,
    required Color muted,
    required Color line,
    required Color gold,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surf,
        border: Border(
          bottom: BorderSide(color: line, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        controller: _navScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _currentIndex == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTabSelected(index),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? gold.withValues(alpha: 0.16)
                          : surf,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? gold : line,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          size: 16,
                          color: isSelected ? gold : muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? gold : text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final showAppBar = widget.showAppBar ?? true;

    if (_isLoadingSubscription) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }
    
    if (!_isDigitalMarketingSubscribed) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
        appBar: showAppBar
            ? AppBar(
                title: Text(
                  'Social Channels', 
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                centerTitle: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                iconTheme: IconThemeData(
                  color: isDark ? Colors.white : Colors.black,
                ),
                elevation: 0,
              )
            : null,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildJoinDigitalMarketingUI(context),
        ),
      );
    }

    final surf = MarketOSTheme.surf(context);
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);

    final bool shouldShowAppBar = widget.showAppBar ?? Navigator.canPop(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: shouldShowAppBar
          ? AppBar(
              backgroundColor: surf,
              elevation: 0,
              iconTheme: IconThemeData(color: text),
              title: Text(
                'Social Channels',
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: line, height: 1),
              ),
            )
          : null,
      body: Column(
        children: [
          _buildHorizontalNavMenu(
            surf: surf,
            text: text,
            muted: muted,
            line: line,
            gold: gold,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                // Tab 0: Overview
                OverviewScreen(
                  onNavigateToAccounts: () => _onTabSelected(4), // navigate to profile
                  onNavigateToApprovals: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReviewApprovalsScreen(),
                      ),
                    );
                  },
                ),

                // Tab 1: Calendar
                const CalendarTab(),

                // Tab 2: Campaigns
                const CampaignsScreen(),

                // Tab 3: Incidents
                const IncidentsScreen(),

                // Tab 4: Profile
                SocialChannelsProfileScreen(
                  onBackToWorkspace: () => _onTabSelected(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
