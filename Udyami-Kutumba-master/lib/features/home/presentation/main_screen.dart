import 'dart:ui';
import 'dart:convert' as dart_convert;
import 'package:flutter/material.dart';
import 'package:udyamikutumba/features/jobs/childrens/programm/childrens_programme.dart';
import 'package:udyamikutumba/features/jobs/lead/lead_management_screen.dart';
import 'package:udyamikutumba/features/jobs/news/news_screen.dart';
import 'package:udyamikutumba/features/jobs/prince_princess_programme/prince_princess_programme.dart';
import 'package:udyamikutumba/features/jobs/reward/screen/rewards_scree.dart';
import 'package:udyamikutumba/features/jobs/training_screen/training_screen.dart';
import '../../../core/api/ubn/feed_api.dart';
import '../../../core/providers/theme_providers.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../auth/presentation/login_screen.dart';
import '../../social_channels/presentation/social_channels_screen.dart';
import '../../ucn/ucnsubscreens/ucn_subscription_screen.dart';
import 'home_screen.dart';
import 'voice_input_screen.dart';
import 'discover_people_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/api/ubn/feed_api.dart';
import 'chats_screen.dart';
import '../../ward/presentation/ward_screen.dart';
import '../../financial/presentation/financial_screen.dart';
import '../../ucn/presentation/ucn_screen.dart';
import '../../uqueens/presentation/uqueens_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../cards/presentation/cards_screen.dart';
import '../../jobs/jobs_screen.dart';
import '../../posts/presentation/my_posts_screen.dart';
import '../../requirements/presentation/requirements_screen.dart';
import '../../requirements/presentation/my_requirements_screen.dart';
import '../../explore/presentation/explore_screen.dart';
import '../../communications/presentation/communications_screen.dart';
import '../../../core/api/profile/profile_api.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../jobs/directory_screen/member_directory_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../geofence/presentation/geofence_screen.dart';
import '../../posts/presentation/post_screen.dart';
import '../../posts/presentation/my_posts_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../../core/api/membership/membership_purchase_api.dart';
import '../../social_channels/presentation/leads_subscribed_screens.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;

  UserProfileModel? _profileData;
  final ProfileAPI _profileAPI = ProfileAPI();
  final MembershipPurchaseAPI _membershipAPI = MembershipPurchaseAPI();
  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;
  bool _isDigitalMarketingSubscribed = false;
  DateTime? _currentBackPressTime;

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false; // Prevent app exit
    }

    DateTime now = DateTime.now();
    if (_currentBackPressTime == null || 
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Double tap to close the app'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true; // Exit app
  }

  bool get _isPrime {
    if (SessionManager.user?['isPrime'] == true) {
      return true;
    }
    if (_profileData != null) {
      return _profileData!.user.isPrime == true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fetchProfile();
    SessionManager.profileUpdateNotifier.addListener(_fetchProfile);
  }

  @override
  void dispose() {
    SessionManager.profileUpdateNotifier.removeListener(_fetchProfile);
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final stopwatch = Stopwatch()..start();
    try {
      final user = SessionManager.user;
      if (user != null && user['userId'] != null) {
        final response = await _profileAPI.getUserProfileById(
          user['userId'].toString(),
        );
        if (response != null && response['success'] == true) {
          if (mounted) {
            setState(() {
              _profileData = UserProfileModel.fromJson(response['data']);
            });
          }
        }

        try {
          final posts = await FeedAPI.getPostsByUser(user['userId'].toString());
          final followersData = await FeedAPI.getFollowers(user['userId'].toString());
          final followingData = await FeedAPI.getFollowing(user['userId'].toString());
          if (mounted) {
            setState(() {
              _postsCount = posts.length;
              if (followersData != null) _followersCount = followersData['count'] ?? 0;
              if (followingData != null) _followingCount = followingData['count'] ?? 0;
            });
          }
        } catch (e) {
          print('Error fetching feed counts: $e');
        }
        
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
            if (SessionManager.user?['isDigital'] == true) {
              hasDigitalMarketing = true;
            }
            if (mounted) {
              setState(() {
                _isDigitalMarketingSubscribed = hasDigitalMarketing;
              });
            }
          }
        } catch (e) {
          print("DEV DEBUG - MainScreen fetch history error: $e");
        }
      }
    } catch (e) {
      print("DEV DEBUG - MainScreen _fetchProfile error: $e");
    } finally {
      stopwatch.stop();
      print("DEV DEBUG - MainScreen: _fetchProfile finished. Loading took ${stopwatch.elapsed.inSeconds} seconds (${stopwatch.elapsedMilliseconds} ms).");
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    // const WardScreen(),
    const WardFilterScreen(),
    const FinancialScreen(),
    const UcnScreen(),
    const CommunicationsScreen(),
    const JobsScreen(),
    const RequirementsScreen(),
    const PostScreen(),
    const ExploreScreen(),
    const UQueensScreen(),
    const MemberDirectoryScreen(),
    const ChatsScreen(),
    const LeadsSubscribedScreens(), // Index 12
    const SocialChannelsScreen(),   // Index 13
  ];

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
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                await SessionManager.clearSession(); // Clear cached session

                // Navigate back to LoginScreen and clear all previous routes
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

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    ThemeData theme,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? theme.colorScheme.primary : Colors.grey.shade600;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
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
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody:
            true, // This allows the body to flow underneath the floating nav bar
      endDrawer: Drawer(
        backgroundColor: theme.brightness == Brightness.dark
            ? Colors.black
            : theme.colorScheme.surface,
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
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.surface
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
                                    radius: 24, // Decreased from 30
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (_profileData?.user.username?.isNotEmpty == true
                                              ? _profileData!.user.username!
                                              : _profileData?.user.name) ??
                                              SessionManager.user?['username'] ??
                                              SessionManager.user?['name'] ??
                                              'Guest',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // const SizedBox(height: 4),
                                        // Text(
                                        //   'ID: ${_profileData?.user.userId ?? SessionManager.user?['userId'] ?? 'N/A'}',
                                        //   style: TextStyle(
                                        //     fontSize: 12,
                                        //     color: theme.brightness == Brightness.dark
                                        //         ? Colors.grey.shade400
                                        //         : Colors.grey.shade700,
                                        //   ),
                                        // ),
                                        // const SizedBox(height: 2),
                                        // Text(
                                        //   'Role: ${(_profileData?.user.roles.isNotEmpty == true) ? _profileData!.user.roles.map((e) => e.roleName).where((e) => e.isNotEmpty).join(', ') : 'User'}',
                                        //   style: const TextStyle(
                                        //     fontSize: 12,
                                        //     color: Colors.teal,
                                        //     fontWeight: FontWeight.w600,
                                        //   ),
                                        //   maxLines: 1,
                                        //   overflow: TextOverflow.ellipsis,
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => const MyPostsScreen(
                                          emptyMessage: "no feeds avaiable, post one"
                                        )
                                      ));
                                    },
                                    child: _buildStatColumn(_postsCount.toString(), 'Feed', theme),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => DiscoverPeopleScreen(
                                          title: "Followers", 
                                          userId: SessionManager.user?['userId'].toString(),
                                          emptyMessage: "connected by no one"
                                        )
                                      ));
                                    },
                                    child: _buildStatColumn(_followersCount.toString(), 'Connected By', theme),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => DiscoverPeopleScreen(
                                          title: "Following", 
                                          userId: SessionManager.user?['userId'].toString(),
                                          emptyMessage: "connected with no one"
                                        )
                                      ));
                                    },
                                    child: _buildStatColumn(_followingCount.toString(), 'Connected With', theme),
                                  ),
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
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.surface
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
                            icon: Icons.workspace_premium,
                            title: 'Subscribe',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UcnSubscriptionScreen(),
                                ),
                              );
                            },
                          ),
                          if (!_isPrime) ...[
                            _buildDrawerItem(
                              context,
                              icon: Icons.handshake_rounded,
                              title: 'UBN',
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentIndex = 3;
                                });
                              },
                            ),
                            _buildDrawerItem(
                              context,
                              icon: Icons.people_alt_rounded,
                              title: 'Chats',
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentIndex = 4;
                                });
                              },
                            ),
                          ],
                          if (_isPrime)
                            _buildDrawerItem(
                              context,
                              icon: Icons.work_outline,
                              title: 'Jobs',
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentIndex = 5;
                                });
                              },
                            ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.contact_phone_outlined,
                            title: 'Directory',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 10;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.assignment_outlined,
                            title: 'Requirements',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 6;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'My Requirements',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyRequirementsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.dynamic_feed_outlined,
                            title: 'Post',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 7;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.history_edu,
                            title: 'My Posts',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyPostsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.explore_outlined,
                            title: 'Explore',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 8;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.stars_rounded,
                            title: 'uQueens',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 9;
                              });
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
                            icon: Icons.forum_rounded,
                            title: 'Social Channels',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SocialChannelsScreen(),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SkillTrainingScreen(),
                                ),
                              );
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
                                  builder: (context) =>
                                      const LeadManagementScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.child_friendly_rounded,
                            title: 'Children\'s Programme',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ChildrenProgrammeScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            context,
                            icon: Icons.workspace_premium,
                            title: 'Udyami Prince & Princess Programme',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrincePrincessProgrammeScreen(),
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
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  isLogout: true,
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _showLogoutDialog(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Image.asset(
          'assets/logo/uk_logo_white_bg_1584x672.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        actions: [
          const ThemeToggleButton(),
          if (!_isPrime)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 10,
                        backgroundColor: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Ensure white bg logo looks good in dark mode
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/logo/uk_logo_white_bg_1584x672.png',
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Upgrade Membership',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unlock exclusive features and grow your network with a premium membership.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // UB Kutumba Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const UcnSubscriptionScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.workspace_premium_rounded),
                                  label: const Text(
                                    'JOIN UB KUTUMBA',
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // UB Warrior Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Navigate to Playstore')),
                                    );
                                  },
                                  icon: const Icon(Icons.shield_outlined),
                                  label: const Text(
                                    'JOIN UB WARRIOR',
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('EARN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.add),
            onSelected: (int newIndex) {
              setState(() {
                _currentIndex = newIndex;
              });
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
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VoiceInputScreen(),
            ),
          );
        },
        child: const Icon(Icons.mic),
      ),
      bottomNavigationBar: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ), // Increases overall height
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(
                    alpha: 0.75,
                  ), // Glassy background
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.3,
                    ), // Glass edge reflection
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Home', theme),
                    _buildNavItem(1, Icons.domain_rounded, 'Area', theme),
                    _buildNavItem(2, Icons.account_balance_wallet_rounded, 'Finance', theme,),
                    if (_isPrime && _isDigitalMarketingSubscribed) ...[
                      _buildNavItem(3, Icons.handshake_rounded, 'UBN', theme),
                      _buildNavItem(12, Icons.campaign_rounded, 'Marketing', theme),
                    ] else if (_isPrime && !_isDigitalMarketingSubscribed) ...[
                      _buildNavItem(3, Icons.handshake_rounded, 'UBN', theme),
                      _buildNavItem(4, Icons.people_alt_rounded, 'Leads', theme),
                    ] else if (!_isPrime && _isDigitalMarketingSubscribed) ...[
                      _buildNavItem(5, Icons.work_outline, 'Jobs', theme),
                      _buildNavItem(13, Icons.campaign_rounded, 'Social', theme),
                    ] else ...[
                      _buildNavItem(5, Icons.work_outline, 'Jobs', theme),
                      _buildNavItem(11, Icons.chat_bubble_outline, 'Chats', theme),
                    ],
                  ],
                ),
              ),
                ), 
              ),
            ),
          ),
        ),
      ),
      )
    );
  }

}
