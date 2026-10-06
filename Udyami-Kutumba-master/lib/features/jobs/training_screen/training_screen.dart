import 'dart:convert' as dart_convert;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:udyamikutumba/core/providers/theme_providers.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../../core/api/profile/profile_api.dart';
import 'package:udyamikutumba/core/api/ubn/feed_api.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../auth/presentation/login_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../cards/presentation/cards_screen.dart';
import '../../jobs/jobs_screen.dart';
import '../../jobs/directory_screen/member_directory_screen.dart';
import '../../requirements/presentation/requirements_screen.dart';
import '../../posts/presentation/post_screen.dart';
import '../../explore/presentation/explore_screen.dart';
import '../../uqueens/presentation/uqueens_screen.dart';
import '../../geofence/presentation/geofence_screen.dart';
import 'package:udyamikutumba/features/jobs/news/news_screen.dart';
import 'package:udyamikutumba/features/jobs/reward/screen/rewards_scree.dart';
import 'package:udyamikutumba/features/jobs/lead/lead_management_screen.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';
class SkillTrainingScreen extends StatefulWidget {
  const SkillTrainingScreen({super.key});

  @override
  State<SkillTrainingScreen> createState() => _SkillTrainingScreenState();
}

class _SkillTrainingScreenState extends State<SkillTrainingScreen> {
  int selectedTab = 0;
  int bottomNavIndex = 0;
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _cardColor => _isDarkMode ? Colors.grey.shade900 : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : const Color(0xFF17202A);

  String? _selectedLevel = 'Beginner';
  String? _selectedGoal = 'Start a Business';
  String? _selectedMode = 'Online';
  String? _selectedCategoryFilter = 'Culinary';
  String? _selectedDurationFilter = 'All Durations';
  String? _selectedModeFilter = 'All Modes';
  String? _selectedStatusFilter = 'All Status';
  String? _bulkEnrollFileName;

  int? _selectedDemandIndex;
  int? _selectedSectorIndex;

  UserProfileModel? _profileData;
  final ProfileAPI _profileAPI = ProfileAPI();

  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    SessionManager.profileUpdateNotifier.addListener(_fetchProfile);
  }

  @override
  void dispose() {
    SessionManager.profileUpdateNotifier.removeListener(_fetchProfile);
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = SessionManager.user;
      if (user != null && user['userId'] != null) {
        final userIdStr = user['userId'].toString();
        final response = await _profileAPI.getUserProfileById(
          userIdStr,
        );
        final posts = await FeedAPI.getPostsByUser(userIdStr);
        final followersData = await FeedAPI.getFollowers(userIdStr);
        final followingData = await FeedAPI.getFollowing(userIdStr);
        
        if (mounted) {
          setState(() {
            if (response != null && response['success'] == true) {
              _profileData = UserProfileModel.fromJson(response['data']);
            }
            _postsCount = posts.length;
            if (followersData != null) _followersCount = followersData['count'] ?? 0;
            if (followingData != null) _followingCount = followingData['count'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile in training screen: $e");
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Theme.of(context).colorScheme.surface,
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await SessionManager.clearSession();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(String count, String label, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final color = isLogout ? Colors.red : Colors.teal;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isLogout
              ? Colors.red.shade800
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87),
        ),
      ),
      trailing: isLogout
          ? null
          : Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          backgroundColor: _cardColor,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
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
              onSelected: (int newIndex) {
                 _showMessage('Action $newIndex selected');
              },
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
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              }
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64.0),
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xFF2E7D32),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Color(0xFF59636E),
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'Training'),
                    Tab(text: 'Placement'),
                  ],
                ),
              ),
            ),
          ),
        ),
        endDrawer: Drawer(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/logo/uk_logo_white_bg_1584x672.png',
                    height: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Scrollable Menu Content
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Profile Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surface
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.teal.withValues(
                                        alpha: 0.1,
                                      ),
                                      backgroundImage: (() {
                                        final img =
                                            _profileData?.profile.profileImage ??
                                            SessionManager.user?['profileImage'];
                                        if (img == null || img.isEmpty)
                                          return null;
                                        if (img.startsWith('data:')) {
                                          final base64Str = img.split(',').last;
                                          return MemoryImage(
                                                dart_convert.base64Decode(
                                                  base64Str,
                                                ),
                                              )
                                              as ImageProvider;
                                        }
                                        return NetworkImage(img) as ImageProvider;
                                      })(),
                                      child: (() {
                                        final img =
                                            _profileData?.profile.profileImage ??
                                            SessionManager.user?['profileImage'];
                                        if (img == null || img.isEmpty) {
                                          return const Icon(
                                            Icons.person,
                                            size: 24,
                                            color: Colors.teal,
                                          );
                                        }
                                        return null;
                                      })(),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _profileData?.user.name ??
                                            SessionManager.user?['name'] ??
                                            'Guest',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn(_postsCount.toString(), 'Feed', Theme.of(context)),
                                    _buildStatColumn(_followersCount.toString(), 'Connected By', Theme.of(context)),
                                    _buildStatColumn(_followingCount.toString(), 'Connected With', Theme.of(context)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surface
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildDrawerItem(
                              context,
                              icon: Icons.credit_card_outlined,
                              title: 'My cards',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileCardScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.work_outline,
                              title: 'Jobs',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const JobsScreen()));
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.contact_phone_outlined,
                              title: 'Directory',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const MemberDirectoryScreen()));
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.assignment_outlined,
                              title: 'Requirements',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RequirementsScreen()));
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.dynamic_feed_outlined,
                              title: 'Post',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const PostScreen()));
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.explore_outlined,
                              title: 'Explore',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreScreen()));
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.stars_rounded,
                              title: 'uQueens',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const UQueensScreen()));
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.location_on_rounded,
                              title: 'Near By',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GeofenceScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.newspaper_rounded,
                              title: 'News',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NewsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.card_giftcard_rounded,
                              title: 'Rewards & Recognition',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RewardsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.school_rounded,
                              title: 'Training',
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.assignment_ind_rounded,
                              title: 'Lead Management',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LeadManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Logout Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surface
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildDrawerItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    isLogout: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrainingPage(),
            _buildPlacementPage(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRAINING PAGE
  // ============================================================

  Widget _buildTrainingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Skill Training & Job Placement',
            'Discover training paths, enrol members, and connect them with jobs and internships.',
          ),

          const SizedBox(height: 18),

          _buildStats([
            _StatData(
              'Total Enrolled',
              '847',
              Icons.people_alt_outlined,
              const Color(0xFF1976D2),
            ),
            _StatData(
              'Completion Rate',
              '67%',
              Icons.task_alt_rounded,
              const Color(0xFF2E7D32),
            ),
            _StatData(
              'Placement Success',
              '71%',
              Icons.work_outline_rounded,
              const Color(0xFF7B1FA2),
            ),
            _StatData(
              'Active Programs',
              '34',
              Icons.school_outlined,
              const Color(0xFFEF6C00),
            ),
          ]),

          const SizedBox(height: 24),

          _buildTrainingPathQuiz(),

          const SizedBox(height: 22),

          const SizedBox(height: 24),

          _buildSectionTitle(
            'Training Program Catalog',
            actionText: 'Clear Filters',
            onActionTap: () {
              setState(() {
                _selectedCategoryFilter = 'Culinary';
                _selectedDurationFilter = 'All Durations';
                _selectedModeFilter = 'All Modes';
                _selectedStatusFilter = 'All Status';
              });
              _showMessage('Filters cleared');
            },
          ),

          const SizedBox(height: 12),

          _buildFilters(),

          const SizedBox(height: 14),

          ...trainingPrograms.map((program) => _buildTrainingCard(program)),

          const SizedBox(height: 25),

          _buildSectionTitle(
            'Enrolled Members Tracker',
            actionText: 'Bulk Enroll',
            onActionTap: _showBulkEnrollSheet,
          ),

          const SizedBox(height: 12),

          ...members.map((member) => _buildMemberCard(member)),

          const SizedBox(height: 25),

          _buildSectionTitle(
            'Training Partner Directory',
            actionText: 'Add Partner',
            onActionTap: _showAddPartnerSheet,
          ),

          const SizedBox(height: 12),

          ...partners.map((partner) => _buildPartnerCard(partner)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF68737D),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FIND YOUR TRAINING PATH QUIZ
  // ============================================================

  Widget _buildTrainingPathQuiz() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE5E8EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Training Path',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Answer 5 quick questions',
            style: TextStyle(fontSize: 13, color: Color(0xFF68737D)),
          ),
          const SizedBox(height: 20),

          // Question 1
          Text(
            '1. What is your primary interest area?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: _isDarkMode ? null : Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Choose a sector'),
                items: ['IT', 'Retail', 'Manufacturing', 'Food']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {},
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Question 2
          Text(
            '2. Current skill level?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              final isSelected = _selectedLevel == level;
              return ChoiceChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    _selectedLevel = val ? level : null;
                  });
                },
                selectedColor: Colors.grey.shade300,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Question 3
          Text(
            '3. Hours available per week?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              hintText: 'e.g. 5 hrs',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Question 4
          Text(
            '4. Your goal?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Start a Business', 'Get Employed'].map((goal) {
              final isSelected = _selectedGoal == goal;
              return ChoiceChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    _selectedGoal = val ? goal : null;
                  });
                },
                selectedColor: Colors.grey.shade300,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Question 5
          Text(
            '5. Preferred learning mode?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Online', 'Offline', 'Hybrid'].map((mode) {
              final isSelected = _selectedMode == mode;
              return ChoiceChip(
                label: Text(mode),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    _selectedMode = val ? mode : null;
                  });
                },
                selectedColor: Colors.grey.shade300,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showRecommendationsSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Get My Recommendations',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<_StatData> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.30,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];

        return Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: _isDarkMode ? null : Border.all(color: Color(0xFFE5E8EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF69747D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _question(
    String number,
    String title,
    String value, {
    List<String>? options,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 8),

          if (options != null)
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: options.map((option) {
                final bool selected = option == value;

                return GestureDetector(
                  onTap: () {
                    _showMessage('$option selected');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Color(0xFF2E7D32) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: _isDarkMode ? null : Border.all(
                        color: selected
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFD7DDD8),
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF455A64),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(9),
                border: _isDarkMode ? null : Border.all(color: Color(0xFFD7DDD8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF69747D),
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(_selectedCategoryFilter ?? 'Culinary', () {
            _showFilterOptions('Category', ['Culinary', 'IT', 'Retail'], (val) {
              setState(() { _selectedCategoryFilter = val; });
            });
          }),
          _filterChip(_selectedDurationFilter ?? 'All Durations', () {
            _showFilterOptions('Duration', ['All Durations', '1 week', '1 month', '3 months'], (val) {
              setState(() { _selectedDurationFilter = val; });
            });
          }),
          _filterChip(_selectedModeFilter ?? 'All Modes', () {
            _showFilterOptions('Mode', ['All Modes', 'Online', 'Offline', 'Hybrid'], (val) {
              setState(() { _selectedModeFilter = val; });
            });
          }),
          _filterChip(_selectedStatusFilter ?? 'All Status', () {
            _showFilterOptions('Status', ['All Status', 'Open', 'Closed'], (val) {
              setState(() { _selectedStatusFilter = val; });
            });
          }),
        ],
      ),
    );
  }

  Widget _filterChip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(9),
          border: _isDarkMode ? null : Border.all(color: Color(0xFFDDE2E6)),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRAINING CARDS
  // ============================================================

  Widget _buildTrainingCard(_TrainingProgram program) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE3E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  program.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (program.almostFull)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Almost full!',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            program.institution,
            style: TextStyle(color: Color(0xFF66727C), fontSize: 12),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _smallTag(
                program.category,
                const Color(0xFFE3F2FD),
                const Color(0xFF2E7D32),
              ),
              _smallTag(
                program.mode,
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
              _smallTag(
                program.duration,
                const Color(0xFFF3E5F5),
                const Color(0xFF7B1FA2),
              ),
              _smallTag(
                program.status,
                program.status == 'Open'
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFFF3E0),
                program.status == 'Open'
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE65100),
              ),
              _smallTag(
                program.certified ? 'Certified' : 'No cert',
                const Color(0xFFF5F5F5),
                const Color(0xFF616161),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Text(
                program.price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const Spacer(),
              Text(
                'Enrolled: ${program.enrolled} / ${program.capacity}',
                style: TextStyle(fontSize: 11, color: Color(0xFF68737D)),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showProgramDetails(program);
                  },
                  child: Text('View Details'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ElevatedButton(
                  onPressed: program.status == 'Open'
                      ? () {
                          _showEnrollMemberSheet(program.title);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Enroll Member'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // MEMBERS
  // ============================================================

  Widget _buildMemberCard(_Member member) {
    Color statusColor;

    if (member.status == 'Completed') {
      statusColor = const Color(0xFF2E7D32);
    } else if (member.status == 'Dropped') {
      statusColor = const Color(0xFFC62828);
    } else {
      statusColor = const Color(0xFF1565C0);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE3E7EA)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showProfileSheet(member),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Text(
                    member.name.substring(0, 1),
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        member.program,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF69747D),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${member.progress}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: member.progress / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFECEFF1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                member.enrolled,
                style: TextStyle(fontSize: 10, color: Color(0xFF77818A)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  member.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showModulesSheet(member);
                  },
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                  label: Text('Modules'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showCertificateSheet(member);
                  },
                  icon: const Icon(Icons.workspace_premium_outlined, size: 16),
                  label: Text('Certificate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PARTNERS
  // ============================================================

  Widget _buildPartnerCard(_Partner partner) {
    final bool active = partner.status == 'Active';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE3E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  partner.institution,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  partner.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            partner.contact,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),

          const SizedBox(height: 4),

          GestureDetector(
            onTap: () async {
              final Uri url = Uri(scheme: 'tel', path: partner.phone.replaceAll(RegExp(r'[^0-9+]'), ''));
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                _showMessage('Could not launch dialer');
              }
            },
            child: Text(
              partner.phone,
              style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: partner.programs
                .map(
                  (e) => _smallTag(
                    e,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1565C0),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 17,
                color: Color(0xFF68737D),
              ),
              const SizedBox(width: 5),
              Text(
                '40,191 Active Enrollments',
                style: TextStyle(fontSize: 11, color: Color(0xFF68737D)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showPartnerUsersSheet(partner);
                },
                child: Text('View'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLACEMENT PAGE
  // ============================================================

  Widget _buildPlacementPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Skill Training & Job Placement',
            'Connect trained members with jobs and internships.',
          ),

          const SizedBox(height: 18),

          _buildStats([
            _StatData(
              'Open Positions',
              '67',
              Icons.work_outline,
              const Color(0xFF1976D2),
            ),
            _StatData(
              'Applications This Month',
              '234',
              Icons.description_outlined,
              const Color(0xFF7B1FA2),
            ),
            _StatData(
              'Placement Rate',
              '71%',
              Icons.trending_up_rounded,
              const Color(0xFF2E7D32),
            ),
            _StatData(
              'Shortlisted',
              '24',
              Icons.star_border_rounded,
              const Color(0xFFEF6C00),
            ),
          ]),

          const SizedBox(height: 25),

          _buildSectionTitle(
            'Job & Internship Listings',
            actionText: 'Post Opportunity',
            onActionTap: () => _showPostOpportunitySheet(context),
          ),

          const SizedBox(height: 12),

          ...jobs.map((job) => _buildJobCard(job)),

          const SizedBox(height: 25),

          _buildSectionTitle('Application Tracking'),

          const SizedBox(height: 12),

          _buildApplicationPipeline(),

          const SizedBox(height: 25),

          _buildDemandSupply(),

          const SizedBox(height: 25),

          _buildSectorPlacement(),

          const SizedBox(height: 25),

          _buildIndustryFeedback(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildJobCard(_Job job) {
    final bool open = job.status == 'Open';

    return GestureDetector(
      onTap: () {
        _showJobDetails(job);
      },
      child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE3E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.business_center_outlined,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.company,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF68737D),
                      ),
                    ),
                  ],
                ),
              ),
              _smallTag(
                job.type,
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _smallTag(
                job.sector,
                const Color(0xFFF3E5F5),
                const Color(0xFF7B1FA2),
              ),
              ...job.skills.map(
                (skill) => _smallTag(
                  skill,
                  const Color(0xFFF5F5F5),
                  const Color(0xFF616161),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF68737D),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Deadline: ${job.deadline}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF68737D),
                  ),
                ),
              ),
              Text(
                '${job.applicants} Applicants',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: open
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: open
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  _showJobDetails(job);
                },
                child: Text('View'),
              ),
              if (open) ...[
                const SizedBox(width: 7),
                ElevatedButton(
                  onPressed: () {
                    _showMessage('${job.title} opportunity closed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37474F),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Close'),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
    );
  }
  // ============================================================
  // APPLICATION PIPELINE
  // ============================================================

  Widget _buildApplicationPipeline() {
    final stages = [
      _PipelineStage('Applied', 4, const Color(0xFF1976D2)),
      _PipelineStage('Shortlisted', 4, const Color(0xFF7B1FA2)),
      _PipelineStage('Interview Scheduled', 4, const Color(0xFFEF6C00)),
      _PipelineStage('Offer Made', 4, const Color(0xFF00838F)),
      _PipelineStage('Placed', 4, const Color(0xFF2E7D32)),
    ];

    return Column(
      children: stages.map((stage) {
        return _buildPipelineStage(stage);
      }).toList(),
    );
  }

  Widget _buildPipelineStage(_PipelineStage stage) {
    final candidates = placementCandidates[stage.title] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE3E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: stage.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.title,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: stage.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${stage.count}',
                  style: TextStyle(
                    color: stage.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ...candidates.map(
            (candidate) => GestureDetector(
              onTap: () => _showCandidateTrackingSheet(candidate, stage),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: stage.color.withOpacity(0.12),
                    child: Text(
                      candidate.name.substring(0, 1),
                      style: TextStyle(
                        color: stage.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          candidate.position,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF69747D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${candidate.match}%',
                    style: TextStyle(
                      color: stage.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEMAND VS SUPPLY
  // ============================================================

  Widget _buildDemandSupply() {
    final data = [
      {'name': 'Digital Marketing', 'demand': 85.0, 'supply': 52.0},
      {'name': 'Tally/Accounting', 'demand': 70.0, 'supply': 66.0},
      {'name': 'Tailoring', 'demand': 60.0, 'supply': 80.0},
      {'name': 'Food Processing', 'demand': 55.0, 'supply': 40.0},
      {'name': 'IT Support', 'demand': 78.0, 'supply': 48.0},
      {'name': 'Sales', 'demand': 92.0, 'supply': 72.0},
      {'name': 'Content Creation', 'demand': 68.0, 'supply': 36.0},
      {'name': 'Machine Operation', 'demand': 50.0, 'supply': 60.0},
    ];

    return _sectionCard(
      title: 'Skill Demand vs Supply',
      child: Column(
        children: [
          if (_selectedDemandIndex != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey.shade800 : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE29267).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${data[_selectedDemandIndex!]['name']}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Demand: ${(data[_selectedDemandIndex!]['demand'] as double).toInt()}',
                    style: const TextStyle(color: Color(0xFFE29267), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Available Candidates: ${(data[_selectedDemandIndex!]['supply'] as double).toInt()}',
                    style: const TextStyle(color: Color(0xFF4C587A), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-axis labels
              SizedBox(
                width: 30,
                height: 160,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: const [
                    Positioned(top: 0 - 6, right: 8, child: Text('100', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)))),
                    Positioned(top: 40 - 6, right: 8, child: Text('75', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)))),
                    Positioned(top: 80 - 6, right: 8, child: Text('50', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)))),
                    Positioned(top: 120 - 6, right: 8, child: Text('25', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)))),
                    Positioned(top: 160 - 6, right: 8, child: Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)))),
                  ],
                ),
              ),
              // Vertical axis line
              Container(
                width: 1,
                height: 160,
                color: Colors.grey.shade400,
              ),
              // Chart Area (Bars + Grid + X-Axis text)
              Expanded(
                child: SizedBox(
                  height: 260, // 160 for bars + 100 for text
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Grid lines
                      ...List.generate(5, (index) {
                        return Positioned(
                          top: index * 40.0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: Colors.grey.withAlpha(50),
                          ),
                        );
                      }),
                      // X axis base line
                      Positioned(
                        top: 160,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      // Bars and text
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: data.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedDemandIndex == index) {
                                    _selectedDemandIndex = null;
                                  } else {
                                    _selectedDemandIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.transparent, // For gesture detection area
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 160,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // Demand bar
                                          FractionallySizedBox(
                                            heightFactor: (item['demand'] as double) / 100.0,
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE29267).withOpacity(_selectedDemandIndex == null || _selectedDemandIndex == index ? 1.0 : 0.4),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          // Supply bar
                                          FractionallySizedBox(
                                            heightFactor: (item['supply'] as double) / 100.0,
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4C587A).withOpacity(_selectedDemandIndex == null || _selectedDemandIndex == index ? 1.0 : 0.4),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 90,
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          item['name'] as String,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _selectedDemandIndex == index ? _textColor : const Color(0xFF9E9E9E),
                                            fontWeight: _selectedDemandIndex == index ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, color: const Color(0xFFE29267)),
              const SizedBox(width: 6),
              const Text('Demand', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              const SizedBox(width: 18),
              Container(width: 12, height: 12, color: const Color(0xFF4C587A)),
              const SizedBox(width: 6),
              const Text('Available Candidates', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ============================================================
  // SECTOR PLACEMENT
  // ============================================================

  Widget _buildSectorPlacement() {
    final sectors = [
      {'name': 'Manufacturing', 'percent': 24.0, 'color': const Color(0xFFF29C38)},
      {'name': 'IT/Tech', 'percent': 19.0, 'color': const Color(0xFF3B82F6)},
      {'name': 'Retail', 'percent': 16.0, 'color': const Color(0xFF10B981)},
      {'name': 'Food & Bev', 'percent': 14.0, 'color': const Color(0xFFEAB308)},
      {'name': 'Healthcare', 'percent': 12.0, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Education', 'percent': 9.0, 'color': const Color(0xFFEC407A)},
      {'name': 'Other', 'percent': 6.0, 'color': const Color(0xFF06B6D4)},
    ];

    return _sectionCard(
      title: 'Placement by Sector',
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _DonutChartPainter(
                percentages: sectors.map((e) => e['percent'] as double).toList(),
                colors: sectors.map((e) => e['color'] as Color).toList(),
                isDarkMode: _isDarkMode,
                selectedIndex: _selectedSectorIndex,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: sectors.asMap().entries.map((entry) {
              int index = entry.key;
              var sector = entry.value;
              final isSelected = _selectedSectorIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedSectorIndex == index) {
                      _selectedSectorIndex = null;
                    } else {
                      _selectedSectorIndex = index;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? (sector['color'] as Color).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? (sector['color'] as Color) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isSelected ? 12 : 10,
                        height: isSelected ? 12 : 10,
                        decoration: BoxDecoration(
                          color: sector['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sector['name'] as String,
                        style: TextStyle(
                          fontSize: isSelected ? 12 : 11,
                          color: isSelected ? _textColor : const Color(0xFF69747D),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  Widget _buildIndustryFeedback() {
    return _sectionCard(
      title: 'Industry Feedback',
      trailing: TextButton(
        onPressed: () {
          _showAddFeedbackSheet();
        },
        child: Text('Add Feedback'),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '4.2',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 17),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 17),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 17),
                      Icon(Icons.star, color: Color(0xFFFFB300), size: 17),
                      Icon(Icons.star_half, color: Color(0xFFFFB300), size: 17),
                    ],
                  ),
                  Text(
                    '/ 5.0 satisfaction',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          ...feedbacks.map(
            (feedback) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feedback.company,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        feedback.date,
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF69747D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedback.candidate,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF69747D),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    feedback.feedback,
                    style: TextStyle(fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 7),
                  TextButton(
                    onPressed: () {
                      _showFeedbackDetailsSheet(feedback);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'View Full',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: _isDarkMode ? null : Border.all(color: Color(0xFFE3E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed:
                onActionTap ??
                () {
                  _showMessage(actionText);
                },
            child: Text(actionText),
          ),
      ],
    );
  }

  // ============================================================
  // PROGRAM DETAILS
  // ============================================================

  void _showProgramDetails(_TrainingProgram program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              program.institution,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Cutting, stitching, and how to start your own boutique.',
            ),
            const SizedBox(height: 12),
            Text(
              'Curriculum',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Pattern making\nStitching\nEmbroidery\nPricing\nCustomer handling',
            ),
            const SizedBox(height: 12),
            Text(
              'Contact',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('+91 98765 33444', style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Color(0xFF69747D)),
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ============================================================
  // JOB DETAILS
  // ============================================================

  void _showJobDetails(_Job job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                Text(
                  job.company,
                  style: TextStyle(color: Color(0xFF69747D)),
                ),

                const SizedBox(height: 18),

                _detailRow('Type', job.type),
                _detailRow('Sector', job.sector),
                _detailRow('Deadline', job.deadline),
                _detailRow('Applicants', '${job.applicants}'),
                _detailRow('Status', job.status),

                const SizedBox(height: 12),

                Text(
                  'Required Skills',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.skills
                      .map(
                        (skill) => _smallTag(
                          skill,
                          const Color(0xFFE3F2FD),
                          const Color(0xFF2E7D32),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showManageApplicationsSheet(job);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Manage Applications'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ============================================================
  // MANAGE APPLICATIONS
  // ============================================================

  void _showManageApplicationsSheet(_Job job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final List<Map<String, String>> applicants = [
          {
            'name': 'Ramesh Kumar',
            'status': 'Applied',
            'date': 'Oct 12, 2026',
            'match': '92%',
          },
          {
            'name': 'Priya Singh',
            'status': 'Shortlisted',
            'date': 'Oct 10, 2026',
            'match': '88%',
          },
          {
            'name': 'Amit Patel',
            'status': 'Interview Scheduled',
            'date': 'Oct 09, 2026',
            'match': '95%',
          },
          {
            'name': 'Sneha Rao',
            'status': 'Applied',
            'date': 'Oct 14, 2026',
            'match': '78%',
          },
        ];

        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Applications',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            job.title,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF68737D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: applicants.length,
                    itemBuilder: (context, index) {
                      final applicant = applicants[index];
                      Color statusColor;
                      switch (applicant['status']) {
                        case 'Shortlisted':
                          statusColor = const Color(0xFF7B1FA2);
                          break;
                        case 'Interview Scheduled':
                          statusColor = const Color(0xFFEF6C00);
                          break;
                        default:
                          statusColor = const Color(0xFF1976D2);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: statusColor.withOpacity(0.1),
                                  child: Text(
                                    applicant['name']!.substring(0, 1),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        applicant['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'Applied on ${applicant['date']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF69747D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${applicant['match']} Match',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status: ${applicant['status']}',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    _showMessage('Viewing ${applicant['name']}\'s profile');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('View Profile', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ============================================================
  // POST NEW OPPORTUNITY & MODALS
  // ============================================================

  void _showEnrollMemberSheet(String programTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enroll Member — $programTitle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search member by name or phone...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showMessage('Member Enrolled!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                ),
                child: Text(
                  'Confirm Enrollment',
                  style: TextStyle(color: _cardColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showBulkEnrollSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bulk Enroll via CSV',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CSV columns: member_name, program_id, enrolled_date',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setSheetState(() {
                            _bulkEnrollFileName = 'members_list.csv';
                          });
                        },
                        child: Text('Choose File'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _bulkEnrollFileName ?? 'No file chosen',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showMessage('Bulk Enrolled!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                      child: Text(
                        'Upload & Enroll',
                        style: TextStyle(color: _cardColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPartnerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Training Partner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Institution Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Contact Person',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Program Types (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Partnership Terms',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showMessage('Partner Added!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                  child: Text(
                    'Save Partner',
                    style: TextStyle(color: _cardColor),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostOpportunitySheet(BuildContext context) {
    String selectedType = 'Job';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Post New Opportunity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Title',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g. Sales Executive',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Company',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Company Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Job', 'Internship', 'Contract'].map((type) {
                          final bool isSelected = selectedType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (val) {
                              setSheetState(() {
                                selectedType = type;
                              });
                            },
                            selectedColor: const Color(
                              0xFF2E7D32,
                            ).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sector',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g. Retail',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g. Pune, Maharashtra',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Skills Required (Enter to add)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'Type skill, press Enter',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stipend/Salary',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g. ₹4 LPA',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Deadline',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Pick',
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter description...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showMessage('Opportunity Posted!');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Post Opportunity',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRecommendationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecCard(
              title: 'Entrepreneurship Basics',
              provider: 'MSME-DI Pune',
              duration: '1 month · Hybrid',
              price: 'Free',
              description: 'Builds the foundational business plan and registration knowledge',
            ),
            const SizedBox(height: 12),
            _buildRecCard(
              title: 'Digital Marketing Mastery',
              provider: 'Manipal ProLearn',
              duration: '1 month · Hybrid',
              price: '₹4,500',
              description: 'Helps you reach customers online through SEO, ads and social media',
            ),
            const SizedBox(height: 12),
            _buildRecCard(
              title: 'Excel for Small Business',
              provider: 'Aptech Computer Edu',
              duration: '1 week · Online',
              price: '₹850',
              description: 'Practical Excel for accounts, inventory and basic dashboards',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecCard({required String title, required String provider, required String duration, required String price, required String description}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
            ],
          ),
          const SizedBox(height: 4),
          Text('$provider • $duration', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              child: Text('Enroll Now'),
            ),
          )
        ],
      ),
    );
  }

  void _showFilterOptions(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select $title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
              title: Text(option),
              onTap: () {
                onSelect(option);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet(_Member member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.black : Color(0xFFF6F8FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Text(member.name.substring(0, 1), style: TextStyle(fontSize: 24, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Enrolled: ${member.enrolled}', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _detailRow('Program', member.program),
                  _detailRow('Status', member.status),
                  _detailRow('Progress', '${member.progress}%'),
                  _detailRow('Phone', '+91 98765 43210'),
                  _detailRow('Email', '${member.name.toLowerCase().replaceAll(' ', '')}@example.com'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModulesSheet(_Member member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modules - ${member.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Module 1: Introduction')),
            const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Module 2: Basics')),
            const ListTile(leading: Icon(Icons.play_circle, color: Colors.blue), title: Text('Module 3: Intermediate', style: TextStyle(fontWeight: FontWeight.bold))),
            const ListTile(leading: Icon(Icons.lock, color: Colors.grey), title: Text('Module 4: Advanced', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  void _showCertificateSheet(_Member member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Certificates - ${member.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (member.progress < 100)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No certificates available yet. Complete the course to earn one.')))
            else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(border: _isDarkMode ? null : Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.orange, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${member.program} Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Issued: Oct 20, 2025', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.download), onPressed: () => _showMessage('Downloading certificate...')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPartnerUsersSheet(_Partner partner) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enrolled Users - ${partner.institution}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Showing 3 out of 40,191 active enrollments', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const ListTile(
              leading: CircleAvatar(child: Text('R')),
              title: Text('Rahul Sharma'),
              subtitle: Text('Enrolled: Oct 1, 2025'),
              trailing: Text('85%'),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('P')),
              title: Text('Priya Patel'),
              subtitle: Text('Enrolled: Sep 15, 2025'),
              trailing: Text('92%'),
            ),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('Amit Kumar'),
              subtitle: Text('Enrolled: Oct 10, 2025'),
              trailing: Text('40%'),
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // CANDIDATE TRACKING
  // ============================================================

  void _showCandidateTrackingSheet(_Candidate candidate, _PipelineStage currentStage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: currentStage.color.withOpacity(0.1),
                            child: Text(
                              candidate.name.substring(0, 1),
                              style: TextStyle(fontSize: 24, color: currentStage.color, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(candidate.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor)),
                                const SizedBox(height: 4),
                                Text(candidate.position, style: TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTrackingStat('Skill Match', '${candidate.match}%', Icons.check_circle_outline),
                          _buildTrackingStat('Current Stage', currentStage.title, Icons.timeline),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                      const SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: _isDarkMode ? Colors.black : Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            _detailRow('Email', '${candidate.name.split(' ')[0].toLowerCase()}@mail.com'),
                            _detailRow('Phone', '+91 98765 ${candidate.match}00'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Status Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                      const SizedBox(height: 16),
                      _buildTimeline(currentStage.title),
                      const SizedBox(height: 24),
                      Text('Interviewer Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                      const SizedBox(height: 12),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add notes about candidate...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          filled: true,
                          fillColor: _isDarkMode ? Colors.black : Color(0xFFF8F9FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentStage.color,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Save Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrackingStat(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: _isDarkMode ? Colors.black : Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStageTitle) {
    List<String> allStages = ['Applied', 'Shortlisted', 'Interview Scheduled', 'Offer Made', 'Placed'];
    int currentIndex = allStages.indexOf(currentStageTitle);
    if (currentIndex == -1) currentIndex = 0;
    
    return Column(
      children: List.generate(currentIndex + 1, (index) {
        bool isLast = index == currentIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                ),
                if (!isLast) Container(width: 2, height: 30, color: Color(0xFF2E7D32)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(allStages[index], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor)),
                    Text('2026-04-${(16 + index * 5).toString().padLeft(2, '0')}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ============================================================
  // FEEDBACK SHEETS
  // ============================================================

  void _showAddFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Industry Feedback', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor)),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Candidate Name',
                    filled: true,
                    fillColor: _isDarkMode ? Colors.black : Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Feedback Notes',
                    filled: true,
                    fillColor: _isDarkMode ? Colors.black : Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackDetailsSheet(_Feedback feedback) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feedback.company, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor)),
              const SizedBox(height: 8),
              Text('Candidate: ${feedback.candidate}', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text('Date: ${feedback.date}', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: _isDarkMode ? Colors.black : Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                child: Text(feedback.feedback, style: TextStyle(fontSize: 16, height: 1.5, color: _textColor)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

// ================================================================
// MODELS
// ================================================================

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatData(this.title, this.value, this.icon, this.color);
}

class _PipelineStage {
  final String title;
  final int count;
  final Color color;

  _PipelineStage(this.title, this.count, this.color);
}

class _TrainingProgram {
  final String title;
  final String institution;
  final String category;
  final String mode;
  final String duration;
  final String status;
  final String price;
  final int enrolled;
  final int capacity;
  final bool certified;
  final bool almostFull;

  _TrainingProgram({
    required this.title,
    required this.institution,
    required this.category,
    required this.mode,
    required this.duration,
    required this.status,
    required this.price,
    required this.enrolled,
    required this.capacity,
    required this.certified,
    required this.almostFull,
  });
}

class _Member {
  final String name;
  final String program;
  final String enrolled;
  final int progress;
  final String status;

  _Member({
    required this.name,
    required this.program,
    required this.enrolled,
    required this.progress,
    required this.status,
  });
}

class _Partner {
  final String institution;
  final String contact;
  final String phone;
  final List<String> programs;
  final int enrollments;
  final String status;

  _Partner({
    required this.institution,
    required this.contact,
    required this.phone,
    required this.programs,
    required this.enrollments,
    required this.status,
  });
}

class _Job {
  final String title;
  final String company;
  final String type;
  final String sector;
  final List<String> skills;
  final String deadline;
  final int applicants;
  final String status;

  _Job({
    required this.title,
    required this.company,
    required this.type,
    required this.sector,
    required this.skills,
    required this.deadline,
    required this.applicants,
    required this.status,
  });
}

class _Candidate {
  final String name;
  final String position;
  final int match;

  _Candidate({required this.name, required this.position, required this.match});
}

class _Feedback {
  final String company;
  final String candidate;
  final String feedback;
  final String date;

  _Feedback({
    required this.company,
    required this.candidate,
    required this.feedback,
    required this.date,
  });
}


// ================================================================
// TRAINING DATA
// ================================================================

final List<_TrainingProgram> trainingPrograms = [
  _TrainingProgram(
    title: 'Full-Stack Web Development',
    institution: 'NIIT Pune',
    category: 'Tech',
    mode: 'Online',
    duration: '3 months',
    status: 'Open',
    price: '₹12,500',
    enrolled: 42,
    capacity: 50,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Digital Marketing Mastery',
    institution: 'Manipal ProLearn',
    category: 'Digital Marketing',
    mode: 'Hybrid',
    duration: '1 month',
    status: 'Open',
    price: '₹4,500',
    enrolled: 67,
    capacity: 75,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Tally with GST',
    institution: 'Aptech Computer Edu',
    category: 'Finance',
    mode: 'Offline',
    duration: '1 month',
    status: 'Open',
    price: '₹3,200',
    enrolled: 28,
    capacity: 30,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Tailoring & Boutique Setup',
    institution: 'Singer Skill Academy',
    category: 'Craft',
    mode: 'Offline',
    duration: '3 months',
    status: 'Open',
    price: 'Free',
    enrolled: 35,
    capacity: 40,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Restaurant Operations 101',
    institution: 'IIHM Bangalore',
    category: 'Culinary',
    mode: 'Hybrid',
    duration: '1 month',
    status: 'Open',
    price: '₹5,500',
    enrolled: 22,
    capacity: 25,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Entrepreneurship Basics',
    institution: 'MSME-DI Pune',
    category: 'Business',
    mode: 'Hybrid',
    duration: '1 month',
    status: 'Open',
    price: 'Free',
    enrolled: 89,
    capacity: 100,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Spoken English & Communication',
    institution: 'British Council Pune',
    category: 'Business',
    mode: 'Online',
    duration: '3 months',
    status: 'Full',
    price: '₹8,500',
    enrolled: 75,
    capacity: 75,
    certified: true,
    almostFull: true,
  ),
  _TrainingProgram(
    title: 'Mobile Repair Technician',
    institution: 'Skill India Mission',
    category: 'Tech',
    mode: 'Offline',
    duration: '1 month',
    status: 'Open',
    price: 'Free',
    enrolled: 18,
    capacity: 25,
    certified: true,
    almostFull: false,
  ),
  _TrainingProgram(
    title: 'Beauty & Wellness Foundation',
    institution: 'VLCC Institute',
    category: 'Craft',
    mode: 'Offline',
    duration: '3 months',
    status: 'Upcoming',
    price: '₹14,500',
    enrolled: 12,
    capacity: 30,
    certified: true,
    almostFull: false,
  ),
  _TrainingProgram(
    title: 'Excel for Small Business',
    institution: 'Aptech Computer Edu',
    category: 'Finance',
    mode: 'Online',
    duration: '1 week',
    status: 'Open',
    price: '₹850',
    enrolled: 56,
    capacity: 100,
    certified: false,
    almostFull: false,
  ),
  _TrainingProgram(
    title: 'Cloud Kitchen Launch',
    institution: 'IIHM Bangalore',
    category: 'Culinary',
    mode: 'Hybrid',
    duration: '1 month',
    status: 'Upcoming',
    price: '₹6,500',
    enrolled: 8,
    capacity: 20,
    certified: true,
    almostFull: false,
  ),
  _TrainingProgram(
    title: 'Social Media for SMBs',
    institution: 'Manipal ProLearn',
    category: 'Digital Marketing',
    mode: 'Online',
    duration: '1 week',
    status: 'Open',
    price: 'Free',
    enrolled: 124,
    capacity: 150,
    certified: false,
    almostFull: true,
  ),
];

// ================================================================
// MEMBER DATA
// ================================================================

final List<_Member> members = [
  _Member(
    name: 'Priya Sharma',
    program: 'Digital Marketing Mastery',
    enrolled: '2026-03-15',
    progress: 78,
    status: 'In Progress',
  ),
  _Member(
    name: 'Rohit Kulkarni',
    program: 'Tally with GST',
    enrolled: '2026-02-20',
    progress: 100,
    status: 'Completed',
  ),
  _Member(
    name: 'Anjali Deshpande',
    program: 'Tailoring & Boutique Setup',
    enrolled: '2026-01-10',
    progress: 100,
    status: 'Completed',
  ),
  _Member(
    name: 'Vikram Joshi',
    program: 'Full-Stack Web Development',
    enrolled: '2026-03-01',
    progress: 45,
    status: 'In Progress',
  ),
  _Member(
    name: 'Sneha Patil',
    program: 'Entrepreneurship Basics',
    enrolled: '2026-04-05',
    progress: 22,
    status: 'In Progress',
  ),
  _Member(
    name: 'Aditya Rao',
    program: 'Spoken English & Communication',
    enrolled: '2026-02-12',
    progress: 15,
    status: 'Dropped',
  ),
  _Member(
    name: 'Meera Iyer',
    program: 'Digital Marketing Mastery',
    enrolled: '2026-03-22',
    progress: 64,
    status: 'In Progress',
  ),
  _Member(
    name: 'Sandeep Gokhale',
    program: 'Mobile Repair Technician',
    enrolled: '2026-04-12',
    progress: 38,
    status: 'In Progress',
  ),
  _Member(
    name: 'Kavita Bhosle',
    program: 'Tailoring & Boutique Setup',
    enrolled: '2026-02-28',
    progress: 100,
    status: 'Completed',
  ),
  _Member(
    name: 'Manish Kale',
    program: 'Excel for Small Business',
    enrolled: '2026-04-18',
    progress: 100,
    status: 'Completed',
  ),
  _Member(
    name: 'Pooja Naik',
    program: 'Social Media for SMBs',
    enrolled: '2026-04-22',
    progress: 56,
    status: 'In Progress',
  ),
  _Member(
    name: 'Rajesh Gaikwad',
    program: 'Tally with GST',
    enrolled: '2026-02-08',
    progress: 12,
    status: 'Dropped',
  ),
];

// ================================================================
// PARTNER DATA
// ================================================================

final List<_Partner> partners = [
  _Partner(
    institution: 'NIIT Pune',
    contact: 'Mr. Aniruddha Joshi',
    phone: '+91 98765 43210',
    programs: ['Tech', 'Digital Marketing'],
    enrollments: 42,
    status: 'Active',
  ),
  _Partner(
    institution: 'Manipal ProLearn',
    contact: 'Ms. Shruti Rao',
    phone: '+91 98765 11222',
    programs: ['Digital Marketing', 'Business'],
    enrollments: 191,
    status: 'Active',
  ),
  _Partner(
    institution: 'Aptech Computer Edu',
    contact: 'Mr. Suresh Patil',
    phone: '+91 98765 22333',
    programs: ['Finance', 'Tech'],
    enrollments: 84,
    status: 'Active',
  ),
  _Partner(
    institution: 'Singer Skill Academy',
    contact: 'Ms. Latha Pillai',
    phone: '+91 98765 33444',
    programs: ['Craft'],
    enrollments: 35,
    status: 'Active',
  ),
  _Partner(
    institution: 'IIHM Bangalore',
    contact: 'Chef Rakesh Menon',
    phone: '+91 98765 44555',
    programs: ['Culinary'],
    enrollments: 30,
    status: 'Active',
  ),
  _Partner(
    institution: 'MSME-DI Pune',
    contact: 'Dr. Vandana Kelkar',
    phone: '+91 98765 55666',
    programs: ['Business', 'Finance'],
    enrollments: 89,
    status: 'Active',
  ),
  _Partner(
    institution: 'British Council Pune',
    contact: "Ms. Helen D'Souza",
    phone: '+91 98765 66777',
    programs: ['Business'],
    enrollments: 75,
    status: 'Active',
  ),
  _Partner(
    institution: 'VLCC Institute',
    contact: 'Ms. Anita Khanna',
    phone: '+91 98765 88999',
    programs: ['Craft'],
    enrollments: 12,
    status: 'Pending',
  ),
];

// ================================================================
// JOB DATA
// ================================================================

final List<_Job> jobs = [
  _Job(
    title: 'Junior Web Developer',
    company: 'Persistent Systems',
    type: 'Job',
    sector: 'IT/Tech',
    skills: ['React', 'JavaScript'],
    deadline: '2026-05-25',
    applicants: 28,
    status: 'Open',
  ),
  _Job(
    title: 'Digital Marketing Intern',
    company: 'Bajaj Allianz',
    type: 'Internship',
    sector: 'Finance',
    skills: ['SEO', 'Google Ads'],
    deadline: '2026-05-18',
    applicants: 47,
    status: 'Open',
  ),
  _Job(
    title: 'Tailor & Designer',
    company: 'Fabindia',
    type: 'Job',
    sector: 'Retail',
    skills: ['Tailoring', 'Pattern making'],
    deadline: '2026-05-30',
    applicants: 18,
    status: 'Open',
  ),
  _Job(
    title: 'Cloud Kitchen Chef',
    company: 'Faasos',
    type: 'Job',
    sector: 'Food & Bev',
    skills: ['Indian cuisine', 'FSSAI'],
    deadline: '2026-05-22',
    applicants: 14,
    status: 'Open',
  ),
  _Job(
    title: 'Accounts Executive',
    company: 'Tata Capital',
    type: 'Job',
    sector: 'Finance',
    skills: ['Tally', 'GST'],
    deadline: '2026-05-15',
    applicants: 36,
    status: 'Open',
  ),
  _Job(
    title: 'Sales Associate',
    company: 'Reliance Trends',
    type: 'Job',
    sector: 'Retail',
    skills: ['Sales', 'Communication'],
    deadline: '2026-05-10',
    applicants: 52,
    status: 'Closed',
  ),
  _Job(
    title: 'Beauty Consultant',
    company: 'Lakmé Salon',
    type: 'Job',
    sector: 'Retail',
    skills: ['Beauty therapy', 'Customer service'],
    deadline: '2026-06-01',
    applicants: 11,
    status: 'Open',
  ),
  _Job(
    title: 'Mobile Repair Tech',
    company: 'Cashify',
    type: 'Contract',
    sector: 'IT/Tech',
    skills: ['Hardware repair', 'Diagnostics'],
    deadline: '2026-05-28',
    applicants: 9,
    status: 'Open',
  ),
  _Job(
    title: 'Content Creator',
    company: 'ShareChat',
    type: 'Internship',
    sector: 'IT/Tech',
    skills: ['Reels', 'Video editing'],
    deadline: '2026-05-20',
    applicants: 73,
    status: 'Open',
  ),
  _Job(
    title: 'Production Operator',
    company: 'Bajaj Auto',
    type: 'Job',
    sector: 'Manufacturing',
    skills: ['Machine operation', 'Quality'],
    deadline: '2026-05-26',
    applicants: 41,
    status: 'Open',
  ),
];

// ================================================================
// APPLICATION DATA
// ================================================================

final Map<String, List<_Candidate>> placementCandidates = {
  'Applied': [
    _Candidate(
      name: 'Priya Sharma',
      position: 'Digital Marketing Intern',
      match: 92,
    ),
    _Candidate(
      name: 'Rohit Kulkarni',
      position: 'Accounts Executive',
      match: 88,
    ),
    _Candidate(
      name: 'Manish Kale',
      position: 'Junior Web Developer',
      match: 71,
    ),
    _Candidate(name: 'Pooja Naik', position: 'Content Creator', match: 84),
  ],
  'Shortlisted': [
    _Candidate(
      name: 'Vikram Joshi',
      position: 'Junior Web Developer',
      match: 89,
    ),
    _Candidate(name: 'Sneha Patil', position: 'Beauty Consultant', match: 76),
    _Candidate(name: 'Aditya Rao', position: 'Production Operator', match: 68),
    _Candidate(name: 'Kavita Bhosle', position: 'Tailor & Designer', match: 95),
  ],
  'Interview Scheduled': [
    _Candidate(
      name: 'Anjali Deshpande',
      position: 'Cloud Kitchen Chef',
      match: 82,
    ),
    _Candidate(
      name: 'Sandeep Gokhale',
      position: 'Mobile Repair Tech',
      match: 91,
    ),
    _Candidate(
      name: 'Meera Iyer',
      position: 'Digital Marketing Intern',
      match: 78,
    ),
    _Candidate(
      name: 'Rajesh Gaikwad',
      position: 'Production Operator',
      match: 65,
    ),
  ],
  'Offer Made': [
    _Candidate(
      name: 'Nikhil Gupta',
      position: 'Junior Web Developer',
      match: 94,
    ),
    _Candidate(name: 'Sushma Pawar', position: 'Accounts Executive', match: 87),
    _Candidate(name: 'Deepak Shinde', position: 'Sales Associate', match: 73),
    _Candidate(name: 'Trupti Joshi', position: 'Beauty Consultant', match: 81),
  ],
  'Placed': [
    _Candidate(name: 'Aarti Joshi', position: 'Tailor & Designer', match: 96),
    _Candidate(name: 'Rahul Mehta', position: 'Content Creator', match: 90),
    _Candidate(name: 'Geeta Karne', position: 'Cloud Kitchen Chef', match: 85),
    _Candidate(
      name: 'Mahesh Bhosle',
      position: 'Production Operator',
      match: 79,
    ),
  ],
};

// ================================================================
// FEEDBACK DATA
// ================================================================

final List<_Feedback> feedbacks = [
  _Feedback(
    company: 'Persistent Systems',
    candidate: 'Aarti Joshi',
    feedback: 'Strong fundamentals, learns fast.',
    date: '2026-04-25',
  ),
  _Feedback(
    company: 'Bajaj Allianz',
    candidate: 'Rahul Mehta',
    feedback: 'Good attitude, needs more SEO depth.',
    date: '2026-04-22',
  ),
  _Feedback(
    company: 'Faasos',
    candidate: 'Geeta Karne',
    feedback: 'Excellent culinary skill, FSSAI savvy.',
    date: '2026-04-20',
  ),
  _Feedback(
    company: 'Bajaj Auto',
    candidate: 'Mahesh Bhosle',
    feedback: 'Punctual and quality-focused.',
    date: '2026-04-18',
  ),
  _Feedback(
    company: 'Fabindia',
    candidate: 'Aarti Joshi',
    feedback: 'Creative, fast turnarounds.',
    date: '2026-04-15',
  ),
  _Feedback(
    company: 'Reliance Trends',
    candidate: 'Deepak Shinde',
    feedback: 'Average sales numbers so far.',
    date: '2026-04-12',
  ),
];


class _DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;
  final bool isDarkMode;
  final int? selectedIndex;

  _DonutChartPainter({
    required this.percentages,
    required this.colors,
    required this.isDarkMode,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double baseStrokeWidth = 38.0;
    final double baseRadius = (size.width / 2) - baseStrokeWidth - 40; // leave room for labels
    final Offset center = Offset(size.width / 2, size.height / 2);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final isSelected = selectedIndex == i;
      final double strokeWidth = isSelected ? 48.0 : baseStrokeWidth;
      final double radius = isSelected ? baseRadius + 5 : baseRadius;
      
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      final sweepAngle = (percentages[i] / 100) * 2 * math.pi;
      
      // Highlight selected sector, dim others if one is selected
      if (selectedIndex != null && !isSelected) {
        paint.color = colors[i].withOpacity(0.3);
      } else {
        paint.color = colors[i];
      }

      // Draw arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.015, // slight gap
        sweepAngle - 0.03, // slight gap
        false,
        paint,
      );

      // Draw label lines
      final double midAngle = startAngle + (sweepAngle / 2);
      final double lineStartRadius = radius + (strokeWidth / 2) + 2;
      final double lineEndRadius = lineStartRadius + 18;
      
      final Offset lineStart = Offset(
        center.dx + lineStartRadius * math.cos(midAngle),
        center.dy + lineStartRadius * math.sin(midAngle),
      );
      final Offset lineEnd = Offset(
        center.dx + lineEndRadius * math.cos(midAngle),
        center.dy + lineEndRadius * math.sin(midAngle),
      );

      final Paint linePaint = Paint()
        ..color = (selectedIndex != null && !isSelected) ? colors[i].withAlpha(50) : colors[i].withAlpha(150)
        ..strokeWidth = isSelected ? 2.0 : 1.0;
      canvas.drawLine(lineStart, lineEnd, linePaint);

      // Draw text
      final Offset textBaseOffset = Offset(
        center.dx + (lineEndRadius + 15) * math.cos(midAngle),
        center.dy + (lineEndRadius + 15) * math.sin(midAngle),
      );

      final textSpan = TextSpan(
        text: '${percentages[i].toInt()}%',
        style: TextStyle(
          color: (selectedIndex != null && !isSelected) ? colors[i].withAlpha(100) : colors[i].withAlpha(200),
          fontSize: isSelected ? 16 : 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final Offset centeredTextOffset = Offset(
        textBaseOffset.dx - textPainter.width / 2,
        textBaseOffset.dy - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, centeredTextOffset);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


