import 'package:flutter/material.dart';

import 'ucn_home_screen.dart';

class UcnScreen extends StatefulWidget {
  const UcnScreen({super.key});

  @override
  State<UcnScreen> createState() => _BniScreenState();
}

class _BniScreenState extends State<UcnScreen> {
  String _selectedPeriod = '6 Months';
  String _selectedTab = 'Overview';
  bool _isActiveMember = true;
  String _selectedFilterChapter = 'All Chapters';

  // PageController and active index for the 3 Meeting Cards & 3 Dots indicator
  final PageController _meetingsPageController = PageController();
  int _activeMeetingIndex = 0;

  final List<String> _timePeriods = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
  ];

  // 3 Upcoming Meetings
  final List<Map<String, dynamic>> _upcomingMeetings = [
    {
      'title': 'Weekly Business Referral Meeting',
      'date': 'Thu, 24 Jul 2026',
      'time': '07:30 AM - 09:00 AM',
      'venue': 'The Leela Palace, Bangalore',
      'type': 'In-Person',
      'status': 'Attending',
    },
    {
      'title': 'Cross-Chapter Synergy Meet',
      'date': 'Tue, 29 Jul 2026',
      'time': '04:00 PM - 05:30 PM',
      'venue': 'Zoom Online',
      'type': 'Online',
      'status': 'RSVP Pending',
    },
    {
      'title': '1-on-1 Feature Presentation',
      'date': 'Fri, 01 Aug 2026',
      'time': '10:00 AM - 11:00 AM',
      'venue': 'Starbucks, Indiranagar',
      'type': 'Face to Face',
      'status': 'Confirmed',
    },
  ];

  @override
  void dispose() {
    _meetingsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          // Add a small delay to simulate refresh since most of UCN is local for now
          // or we can just trigger a setState to rebuild child UcnHomeScreen.
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // 1. Dashboard Header Banner
            // _buildDashboardHeader(theme, isDark),
            // const SizedBox(height: 16),
            //
            // // 2. Profile Card
            // _buildProfileCard(theme, isDark),
            // const SizedBox(height: 20),
            //
            // // 3. Upcoming Meetings Section (UP)
            // _buildUpcomingMeetingsSection(theme, isDark),
            // const SizedBox(height: 20),
            //
            // _buildFilterControls(theme, isDark),
            // const SizedBox(height: 8),
            //
            // // 5. Dashboard Cards Grid
            // _buildDashboardCardsGrid(theme, isDark),
            // const SizedBox(height: 8),
            //
            // // 6. THANK YOU SLIP Header Row
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text(
            //       "THANK YOU SLIP",
            //       style: TextStyle(fontSize: 14, color: Colors.grey),
            //     ),
            //     TextButton(
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => const ThankSlipScreen(),
            //           ),
            //         );
            //       },
            //       style: TextButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(horizontal: 4),
            //         minimumSize: const Size(0, 32),
            //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //       ),
            //       child: const Text('View All'),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            //
            // // 7. Thank You Slip Preview Card
            // _buildThankYouSlipCard(theme, isDark),
            // const SizedBox(height: 24),
            //
            // // 8. UCN Home Section
            // const Divider(height: 1),
            // const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text(
            //       "UCN SECTION",
            //       style: TextStyle(fontSize: 14, color: Colors.grey),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),
            const UcnHomeScreen(),
          ],
        ),
      ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // 1. Dashboard Header
  // ─────────────────────────────────────────────────
  Widget _buildDashboardHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BNI Dashboard",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Bangalore Chapter Hub",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No new BNI notifications"),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(
            Icons.notifications_none_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // 2. Profile Card
  // ─────────────────────────────────────────────────
  Widget _buildProfileCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(77) : Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: _isActiveMember
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Welcome, John Doe",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isActiveMember = !_isActiveMember;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isActiveMember
                              ? Colors.green.withAlpha(30)
                              : Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: _isActiveMember
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isActiveMember ? "Active" : "Away",
                              style: TextStyle(
                                color: _isActiveMember
                                    ? Colors.green.shade700
                                    : Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Member ID: BNI1025",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Chapter: Bangalore Chapter",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
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
    );
  }

  // ─────────────────────────────────────────────────
  // 3. Upcoming Meetings Section (UP)
  // ─────────────────────────────────────────────────
  Widget _buildUpcomingMeetingsSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Upcoming Meetings",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showAllMeetingsBottomSheet(theme, isDark),
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal PageView of 3 Cards
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _meetingsPageController,
            itemCount: _upcomingMeetings.length,
            onPageChanged: (int index) {
              setState(() {
                _activeMeetingIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final meeting = _upcomingMeetings[index];
              final isOnline = meeting['type'] == 'Online';

              return Container(
                margin: const EdgeInsets.only(right: 6, bottom: 4, top: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(40)
                          : Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.blue : Colors.deepOrange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meeting['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meeting['date'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meeting['time'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              isOnline
                                  ? Icons.videocam_outlined
                                  : Icons.location_on_outlined,
                              size: 12,
                              color: isOnline
                                  ? Colors.blue
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                meeting['venue'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOnline
                                      ? Colors.blue
                                      : (isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? Colors.blue.withAlpha(25)
                                : Colors.orange.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meeting['type'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOnline ? Colors.blue : Colors.deepOrange,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "RSVP updated for ${meeting['title']}",
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: Text(meeting['status']),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // 3 Dots Page Indicator below the cards
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_upcomingMeetings.length, (index) {
            final isSelected = _activeMeetingIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // 4. Filter & Control Row (DOWN)
  //    Overview tab | Time Period Dropdown | Filter Button
  // ─────────────────────────────────────────────────
  Widget _buildFilterControls(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Overview tab only
        _buildHeaderTabItem("Overview", theme, isDark),

        const Spacer(),

        // Time Period Dropdown
        PopupMenuButton<String>(
          initialValue: _selectedPeriod,
          onSelected: (String newValue) {
            setState(() {
              _selectedPeriod = newValue;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (BuildContext context) {
            return _timePeriods.map((String period) {
              return PopupMenuItem<String>(value: period, child: Text(period));
            }).toList();
          },
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedPeriod,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Filter Action Button
        Material(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _showFilterBottomSheet,
            child: const SizedBox(
              height: 42,
              width: 42,
              child: Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTabItem(String title, ThemeData theme, bool isDark) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? theme.colorScheme.surfaceContainer : Colors.white),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // ─────────────────────────────────────────────────
  // Thank You Slip Preview Card
  // ─────────────────────────────────────────────────
  Widget _buildThankYouSlipCard(ThemeData theme, bool isDark) {
    final List<Map<String, dynamic>> slips = [
      {
        'name': 'Rajesh Kumar',
        'category': 'IT Services',
        'amount': '₹12,000',
        'date': '20 Jul 2026',
        'status': 'Sent',
        'color': Colors.green,
        'initials': 'RK',
      },
      {
        'name': 'Priya Sharma',
        'category': 'Marketing',
        'amount': '₹8,500',
        'date': '18 Jul 2026',
        'status': 'Pending',
        'color': Colors.orange,
        'initials': 'PS',
      },
      {
        'name': 'Amit Patel',
        'category': 'Real Estate',
        'amount': '₹25,000',
        'date': '15 Jul 2026',
        'status': 'Sent',
        'color': Colors.blue,
        'initials': 'AP',
      },
    ];

    return Column(
      children: slips.map((slip) {
        final isSent = slip['status'] == 'Sent';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(40)
                    : Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with initials
              CircleAvatar(
                radius: 22,
                backgroundColor: (slip['color'] as Color).withAlpha(40),
                child: Text(
                  slip['initials'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: slip['color'] as Color,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Person details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slip['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slip['category'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slip['date'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    slip['amount'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSent
                          ? Colors.green.withAlpha(30)
                          : Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slip['status'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSent
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────
  // 5. Dashboard Cards Grid
  // ─────────────────────────────────────────────────
  Widget _buildDashboardCardsGrid(ThemeData theme, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.05,
      children: [
        _buildDashboardCard(
          icon: Icons.handshake_rounded,
          title: "New Meetings",
          value: "28",
          trend: "+14%",
          color: Colors.blue,
          theme: theme,
          isDark: isDark,
          onTap: () => _showStatDetailDialog(
            "New Meetings",
            "28 Scheduled meetings in the selected period.",
          ),
        ),
        _buildDashboardCard(
          icon: Icons.people_alt_rounded,
          title: "New Members",
          value: "15",
          trend: "+8%",
          color: Colors.green,
          theme: theme,
          isDark: isDark,
          onTap: () => _showStatDetailDialog(
            "New Members",
            "15 Members joined Bangalore chapter recently.",
          ),
        ),
        _buildDashboardCard(
          icon: Icons.person_search_rounded,
          title: "Face to Face",
          value: "42",
          trend: "+22%",
          color: Colors.orange,
          theme: theme,
          isDark: isDark,
          onTap: () => _showStatDetailDialog(
            "Face to Face",
            "42 One-on-one member interaction sessions completed.",
          ),
        ),
        _buildDashboardCard(
          icon: Icons.trending_up_rounded,
          title: "Traffic",
          value: "120",
          trend: "+35%",
          color: Colors.redAccent,
          theme: theme,
          isDark: isDark,
          onTap: () => _showStatDetailDialog(
            "Traffic",
            "120 Business referrals and visitor leads logged.",
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required Color color,
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(50)
                    : Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withAlpha(30),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Helpers & Modals
  // ─────────────────────────────────────────────────
  void _showAllMeetingsBottomSheet(ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Chapter Meetings",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _upcomingMeetings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final meeting = _upcomingMeetings[index];
                        final isOnline = meeting['type'] == 'Online';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.surfaceContainer
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? Colors.blue
                                      : Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meeting['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${meeting['date']} • ${meeting['time']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Venue: ${meeting['venue']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOnline
                                            ? Colors.blue
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "RSVP confirmed for ${meeting['title']}",
                                      ),
                                    ),
                                  );
                                },
                                child: Text(meeting['status']),
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
      },
    );
  }

  void _showStatDetailDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Dashboard",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Chapter Region",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'All Chapters',
                          'Bangalore North',
                          'Bangalore South',
                          'Mysore Chapter',
                        ].map((chapter) {
                          final selected = _selectedFilterChapter == chapter;
                          return ChoiceChip(
                            label: Text(chapter),
                            selected: selected,
                            onSelected: (val) {
                              setModalState(() {
                                _selectedFilterChapter = chapter;
                              });
                              setState(() {
                                _selectedFilterChapter = chapter;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Filters applied: $_selectedFilterChapter",
                            ),
                          ),
                        );
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
