import 'package:flutter/material.dart';
import 'package:udyamikutumba/core/providers/theme_providers.dart';
import 'package:udyamikutumba/features/notifications/presentation/notifications_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _pointsKey = GlobalKey();
  final GlobalKey _activitiesKey = GlobalKey();
  final GlobalKey _awardsKey = GlobalKey();
  final GlobalKey _leaderboardKey = GlobalKey();
  final GlobalKey _ceremonyKey = GlobalKey();

  int _selectedSectionIndex = 0;

  String _selectedScope = 'State';
  String _selectedPeriod = 'All Time';
  String _selectedCategory = 'Total Points';

  final List<String> _scopes = ['State', 'District', 'Area'];
  final List<String> _periods = ['All Time', 'This Month', 'This Year'];
  final List<String> _categories = ['Total Points', 'Referrals', 'Leads'];

  final List<String> sections = [
    'My Points',
    'Activities',
    'Awards',
    'Leaderboard',
    'Ceremony',
  ];

  final List<Map<String, dynamic>> badges = [
    {'icon': '🪪', 'name': 'Profile Champion', 'locked': false},
    {'icon': '🎟️', 'name': 'Regular Attendee', 'locked': true},
    {'icon': '🤝', 'name': 'Network Builder', 'locked': true},
    {'icon': '🎯', 'name': 'Lead Generator', 'locked': true},
    {'icon': '📚', 'name': 'Skill Builder', 'locked': true},
    {'icon': '🚀', 'name': 'Growth Star', 'locked': false},
    {'icon': '🧭', 'name': 'Mentor Badge', 'locked': true},
    {'icon': '🛡️', 'name': 'Ground Warrior', 'locked': true},
  ];

  final List<Map<String, dynamic>> activities = [
    {
      'title': 'Complete full profile',
      'points': 50,
      'badge': '🪪 Profile Champion',
    },
    {
      'title': 'Attend ward meeting',
      'points': 20,
      'badge': '🎟️ Regular Attendee',
    },
    {
      'title': 'Refer new member',
      'points': 200,
      'badge': '🤝 Network Builder',
    },
    {
      'title': 'Generate qualified lead',
      'points': 100,
      'badge': '🎯 Lead Generator',
    },
    {
      'title': 'Complete training module',
      'points': 75,
      'badge': '📚 Skill Builder',
    },
    {
      'title': 'Achieve revenue milestone',
      'points': 500,
      'badge': '🚀 Growth Star',
    },
    {
      'title': 'Mentor another member',
      'points': 150,
      'badge': '🧭 Mentor Badge',
    },
    {
      'title': 'Submit field survey',
      'points': 30,
      'badge': '🛡️ Ground Warrior',
    },
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {'title': 'Bcn Tyfcb Logged', 'points': 200, 'date': '9 Jul'},
    {'title': 'Bcn Tyfcb Logged', 'points': 200, 'date': '9 Jul'},
    {'title': 'Bcn Tyfcb Logged', 'points': 200, 'date': '9 Jul'},
    {'title': 'Bcn Tyfcb Logged', 'points': 200, 'date': '9 Jul'},
    {'title': 'Profile Complete', 'points': 50, 'date': '9 Jun'},
  ];

  final List<Map<String, dynamic>> awards = [
    {
      'title': 'Top Udyami of the Month',
      'period': 'Monthly',
      'icon': Icons.emoji_events_rounded,
    },
    {
      'title': 'Udyami Queen of the Quarter',
      'period': 'Quarterly',
      'icon': Icons.workspace_premium_rounded,
    },
    {
      'title': 'Youth Entrepreneur of the Year',
      'period': 'Annual',
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'title': 'Best Channel Partner',
      'period': 'Quarterly',
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'title': 'Mentorship Excellence Award',
      'period': 'Annual',
      'icon': Icons.explore_rounded,
    },
  ];

  final List<Map<String, dynamic>> leaderboard = [
    {
      'rank': 1,
      'name': 'Admin',
      'points': 1250,
      'badges': 2,
      'trend': 'down',
    },
    {
      'rank': 2,
      'name': 'Kavitha Reddy',
      'points': 275,
      'badges': 0,
      'trend': 'up',
    },
    {
      'rank': 3,
      'name': 'Unknown',
      'points': 100,
      'badges': 1,
      'trend': 'up',
    },
    {
      'rank': 4,
      'name': 'kishan BN',
      'points': 100,
      'badges': 1,
      'trend': 'same',
    },
    {
      'rank': 5,
      'name': 'Sneha',
      'points': 100,
      'badges': 1,
      'trend': 'same',
    },
    {
      'rank': 6,
      'name': 'Krupananda Bn',
      'points': 100,
      'badges': 1,
      'trend': 'same',
    },
    {
      'rank': 7,
      'name': 'nikk',
      'points': 50,
      'badges': 1,
      'trend': 'up',
    },
    {
      'rank': 8,
      'name': 'Nandini Devi',
      'points': 50,
      'badges': 1,
      'trend': 'up',
    },
    {
      'rank': 9,
      'name': 'sahreyas',
      'points': 50,
      'badges': 1,
      'trend': 'down',
    },
    {
      'rank': 10,
      'name': 'Rangaraju GR',
      'points': 50,
      'badges': 1,
      'trend': 'same',
    },
    {
      'rank': 11,
      'name': 'Harish BP',
      'points': 50,
      'badges': 1,
      'trend': 'same',
    },
    {
      'rank': 12,
      'name': 'D Narasimha Murthy',
      'points': 50,
      'badges': 1,
      'trend': 'up',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToSection(int index) {
    setState(() {
      _selectedSectionIndex = index;
    });

    GlobalKey key;
    switch (index) {
      case 0:
        key = _pointsKey;
        break;
      case 1:
        key = _activitiesKey;
        break;
      case 2:
        key = _awardsKey;
        break;
      case 3:
        key = _leaderboardKey;
        break;
      case 4:
        key = _ceremonyKey;
        break;
      default:
        return;
    }

    final sectionContext = key.currentContext;
    if (sectionContext != null) {
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  void _showWinnerSelectionSheet(String awardTitle, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Winner',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            awardTitle,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: leaderboard.length,
                  separatorBuilder: (_, __) => Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final user = leaderboard[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Text(
                          _initials(user['name']),
                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        user['name'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${user['points']} pts • ${user['badges']} badges',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showMessage('${user['name']} selected for $awardTitle');
                        },
                        child: const Text('Select'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPointsDetailsSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Points History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('1,250', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                        Text('Total', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    Column(
                      children: [
                        Text('450', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                        Text('This Month', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: recentActivities.length,
                  itemBuilder: (context, index) {
                    final item = recentActivities[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.amber.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title'], style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                                const SizedBox(height: 4),
                                Text(item['date'], style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500)),
                              ],
                            ),
                          ),
                          Text(
                            '+${item['points']}',
                            style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo/uk_logo_white_bg_1584x672.png',
              height: 48,
              fit: BoxFit.contain,
            ),
            const Spacer(),

          ],
        ),
        centerTitle: true,
        actions: [
              const ThemeToggleButton(),
          PopupMenuButton<int>(
            icon: const Icon(Icons.add),
            onSelected: (int newIndex) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(value: 7, child: Text('Post')),
              const PopupMenuItem<int>(value: 6, child: Text('Requirements')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedSectionIndex == index;
                  return ActionChip(
                    label: Text(
                      sections[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : const Color(0xFF17191C)),
                      ),
                    ),
                    onPressed: () => _scrollToSection(index),
                    backgroundColor: isSelected ? Colors.teal : (isDark ? Colors.grey.shade800 : const Color(0xFFF0F2F4)),
                    side: BorderSide.none,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rewards & Recognition',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Celebrate Udyami Excellence',
                    style: TextStyle(
                      color: Color(0xFF737981),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // MY POINTS
                  Container(
                    key: _pointsKey,
                    child: _buildPointsCard(isDark),
                  ),

                  const SizedBox(height: 20),

                  // ACTIVITIES
                  Container(
                    key: _activitiesKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Points Activity Reference',
                          'How to earn points and unlock badges',
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildActivities(isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // AWARDS
                  Container(
                    key: _awardsKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Awards Program',
                          'Five flagship awards for outstanding Udyami excellence',
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildAwards(isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // LEADERBOARD
                  Container(
                    key: _leaderboardKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Leaderboard',
                          'Detailed view of members and their points',
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildLeaderboard(isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CEREMONY
                  Container(
                    key: _ceremonyKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Award Ceremony',
                          'Celebrate winners and recognize excellence',
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildCeremony(isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(bool isDark) {
    return GestureDetector(
      onTap: () => _showPointsDetailsSheet(isDark),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? Colors.grey.shade900 : Colors.white,
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR TOTAL POINTS',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '1,250',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'pts',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Silver',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '250 pts to Gold',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: .75,
                minHeight: 8,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'YOUR BADGES',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Container(
                  decoration: BoxDecoration(
                    color: badge['locked']
                        ? (isDark ? Colors.grey.shade800 : Colors.grey.shade100)
                        : (isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.shade50),
                    borderRadius: BorderRadius.circular(14),
                    border: badge['locked']
                        ? null
                        : Border.all(
                            color: isDark ? Colors.teal.withOpacity(0.3) : Colors.teal.shade200,
                          ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: badge['locked'] ? .35 : 1,
                      child: Text(
                        badge['icon'],
                        style: const TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent point-earning activity',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...recentActivities.map(
                    (activity) => _recentActivityTile(activity, isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentActivityTile(Map<String, dynamic> item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 17,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['title'],
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${item['points']}',
              style: TextStyle(
                color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item['date'],
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : const Color(0xFF777D84),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActivities(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(isDark),
      child: Column(
        children: activities.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : const Color(0xFFE8EAEC),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F5F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF23785D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['badge'],
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : const Color(0xFF737981),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${item['points']}',
                    style: const TextStyle(
                      color: Color(0xFF16804E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAwards(bool isDark) {
    return Column(
      children: awards.map((award) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(17),
          decoration: _cardDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  award['icon'],
                  color: const Color(0xFFC58A18),
                  size: 25,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                award['title'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : const Color(0xFFD9DDE1),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  award['period'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              const Text(
                'No winner announced yet',
                style: TextStyle(
                  color: Color(0xFF777D84),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showWinnerSelectionSheet(award['title'], isDark);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: isDark ? Colors.teal : Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    'Select Winner',
                    style: TextStyle(color: isDark ? Colors.teal : Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboard(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(isDark),
          child: Column(
            children: [
              _dropdownField(
                label: 'Scope',
                value: _selectedScope,
                options: _scopes,
                isDark: isDark,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedScope = val);
                },
              ),
              const SizedBox(height: 10),
              _dropdownField(
                label: 'Period',
                value: _selectedPeriod,
                options: _periods,
                isDark: isDark,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPeriod = val);
                },
              ),
              const SizedBox(height: 10),
              _dropdownField(
                label: 'Category',
                value: _selectedCategory,
                options: _categories,
                isDark: isDark,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...leaderboard.map(
          (person) => _leaderboardCard(person, isDark),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> options,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF646A70),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : const Color(0xFFDDE0E3),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF777D84),
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _leaderboardCard(Map<String, dynamic> person, bool isDark) {
    final int rank = person['rank'];
    final bool topThree = rank <= 3;

    return GestureDetector(
      onTap: () => _showUserPointsDialog(person, isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: topThree
            ? (isDark ? Colors.amber.withOpacity(0.1) : const Color(0xFFFFFBF0))
            : (isDark ? Colors.grey.shade900 : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: topThree
              ? (isDark ? Colors.amber.withOpacity(0.3) : const Color(0xFFF1E3B9))
              : (isDark ? Colors.grey.shade800 : const Color(0xFFE5E7EA)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: rank == 1
                ? const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                  )
                : Text(
                    '#$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF747A80),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F4EF),
            child: Text(
              _initials(person['name']),
              style: const TextStyle(
                color: Color(0xFF1D6B54),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${person['badges']} badge${person['badges'] == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF81868C),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${person['points']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Text(
                'POINTS',
                style: TextStyle(
                  fontSize: 8,
                  color: Color(0xFF888E94),
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          _trendIcon(person['trend']),
        ],
      ),
    ));
  }

  void _showUserPointsDialog(Map<String, dynamic> person, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${person['name']} — Points History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Hardcoded example history items similar to the prompt
                _historyDialogItem('profile complete', '12 Jun 2026', '+50', isDark),
                _historyDialogItem('daily login', '11 Jun 2026', '+10', isDark),
                _historyDialogItem('referral bonus', '10 Jun 2026', '+100', isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _historyDialogItem(String title, String date, String points, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: isDark ? Colors.teal.shade400 : Colors.teal.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              points,
              style: TextStyle(
                color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendIcon(String trend) {
    if (trend == 'up') {
      return const Icon(
        Icons.trending_up_rounded,
        size: 19,
        color: Colors.green,
      );
    }

    if (trend == 'down') {
      return const Icon(
        Icons.trending_down_rounded,
        size: 19,
        color: Colors.redAccent,
      );
    }

    return const Icon(
      Icons.remove_rounded,
      size: 19,
      color: Colors.grey,
    );
  }

  Widget _buildCeremony(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF173F34),
            Color(0xFF28735D),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Plan Award Ceremony',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Organize your next recognition ceremony and celebrate outstanding Udyamis.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark
                            ? const ColorScheme.dark(
                                primary: Colors.teal,
                                onPrimary: Colors.white,
                                surface: Color(0xFF1E1E1E),
                                onSurface: Colors.white,
                              )
                            : const ColorScheme.light(
                                primary: Colors.teal,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (selectedDate != null) {
                  _showMessage('Ceremony scheduled for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}');
                }
              },
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Plan Ceremony'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF195541),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark ? Colors.grey.shade800 : const Color(0xFFE5E7EA),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.025),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first.substring(
        0,
        parts.first.length >= 2 ? 2 : 1,
      ).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

