import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api.dart';
import '../../../core/utils/session_manager.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import 'review_approvals_screen.dart';
import 'edit_profile_screen.dart';
import 'reports_screen.dart';
import 'storage_screen.dart';
import 'widgets/marketos_theme.dart';
import 'social_channels_settings_screen.dart';

class SocialChannelsProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToWorkspace;

  const SocialChannelsProfileScreen({
    super.key,
    this.onBackToWorkspace,
  });

  @override
  State<SocialChannelsProfileScreen> createState() =>
      _SocialChannelsProfileScreenState();
}

typedef ProfileScreen = SocialChannelsProfileScreen;

class _SocialChannelsProfileScreenState
    extends State<SocialChannelsProfileScreen> {
  final ApiClient _api = ApiClient();
  final SocialChannelApi _socialApi = SocialChannelApi();

  String _userName = 'Entrepreneur';
  String _workspaceName = 'Udyami Kutumba Workspace';
  String? _profileImageUrl;
  int _walletBalance = 0;
  int _pendingApprovalsCount = 0;
  bool _isLoading = true;

  List<ChannelConnectionItem> _connections =
      ChannelConnectionItem.defaultConnections();

  @override
  void initState() {
    super.initState();
    _loadProfileAndWallet();
  }

  Future<void> _showConnectAccountDialog(ChannelConnectionItem conn) async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Connect ${conn.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'Username or email'),
                  ),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final user = usernameCtrl.text.trim();
                          final pass = passwordCtrl.text;

                          if (user.isEmpty || pass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter both username and password.')),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final result = await _socialApi.connectSocialMediaAccount(
                            platform: conn.platformKey,
                            username: user,
                            password: pass,
                          );

                          setDialogState(() => isLoading = false);

                          if (result['success'] != false) {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${conn.name} connected successfully. An Admin will review and activate it.'),
                                backgroundColor: const Color(0xFF1F8F5F),
                              ),
                            );
                            _loadProfileAndWallet(); // Refresh connections
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Connection failed.'),
                                backgroundColor: const Color(0xFFC23F2C),
                              ),
                            );
                          }
                        },
                  child: const Text('Continue'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _loadProfileAndWallet() async {
    setState(() => _isLoading = true);
    final userId = _socialApi.currentUserId;

    // 1. User info from session
    final user = SessionManager.user;
    if (user != null) {
      final name = user['name'] ?? user['firstName'] ?? user['fullName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        _userName = name.toString().trim();
      }
      final business = user['businessName'] ??
          user['companyName'] ??
          user['workspaceName'];
      if (business != null && business.toString().trim().isNotEmpty) {
        _workspaceName = business.toString().trim();
      }
    }

    if (userId == null || userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      await Future.wait([
        _fetchUserProfile(userId),
        _fetchWallet(userId),
        _fetchPendingCount(),
        _fetchConnectedAccounts(),
      ]);
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final res = await _api.get('/auth/getUserById/$userId');
      if (res is Map<String, dynamic> && res['data'] is Map) {
        final data = res['data'] as Map;
        final name = data['name']?.toString();
        if (name != null && name.isNotEmpty) _userName = name;

        final profile = data['profile'];
        if (profile is Map) {
          final img = profile['profileImage']?.toString();
          if (img != null && img.isNotEmpty) _profileImageUrl = img;

          final vertical = profile['selectedBusinessVertical']?.toString();
          final bDetails = profile['businessDetails'];
          if (bDetails is Map && bDetails['businessName'] != null) {
            _workspaceName = bDetails['businessName'].toString();
          } else if (vertical != null && vertical.isNotEmpty) {
            _workspaceName = vertical;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchWallet(String userId) async {
    try {
      final res = await _api.get('/wallet/getWalletData/$userId');
      if (res is Map<String, dynamic>) {
        final bal = res['balanceCoins'] ??
            res['data']?['balanceCoins'] ??
            res['coins'] ??
            res['data']?['coins'];
        if (bal != null) {
          _walletBalance = int.tryParse(bal.toString()) ?? 0;
        }
      }
    } catch (_) {
      // Keep _walletBalance at 0 on error — no hardcoded fallback
    }
  }

  Future<void> _fetchPendingCount() async {
    try {
      final contents = await _socialApi.getAllGeneratedContent();
      final pending = contents.where((c) => c.isWaitingApproval).length;
      if (mounted) {
        setState(() => _pendingApprovalsCount = pending);
      }
    } catch (_) {}
  }

  Future<void> _fetchConnectedAccounts() async {
    try {
      final accounts = await _socialApi.getUserSocialMediaAccounts();
      final updated = _connections.map((conn) {
        final matched = accounts.any((acc) =>
            acc.platform.toUpperCase() == conn.platformKey &&
            acc.connected &&
            acc.isActive);
        return conn.copyWith(connected: matched);
      }).toList();
      if (mounted) {
        setState(() => _connections = updated);
      }
    } catch (_) {}
  }

  String get _initials {
    final parts = _userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'MK';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _showSettingsModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SocialChannelsSettingsScreen(),
      ),
    );
  }

  void _showStorageModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StorageScreen(),
      ),
    );
  }

  void _showReportsModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportsScreen(walletBalance: _walletBalance),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of your MarketOS workspace?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionManager.clearSession();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC23F2C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final dim = MarketOSTheme.dim(context);
    final surf = MarketOSTheme.surf(context);
    final surf2 = MarketOSTheme.surf2(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);
    final gold2 = MarketOSTheme.gold2(context);
    final goldFade = MarketOSTheme.goldFade(context);

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _loadProfileAndWallet,
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Hero Panel
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              //   decoration: BoxDecoration(
              //     color: surf,
              //     border: Border(bottom: BorderSide(color: line)),
              //   ),
              //   child: Row(
              //     children: [
              //       // Avatar / Initials
              //       if (_profileImageUrl != null &&
              //           _profileImageUrl!.isNotEmpty) ...[
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(18),
              //           child: CachedNetworkImage(
              //             imageUrl: _profileImageUrl!,
              //             width: 58,
              //             height: 58,
              //             fit: BoxFit.cover,
              //             errorWidget: (_, __, ___) => _buildInitialsBox(gold),
              //           ),
              //         ),
              //       ] else ...[
              //         _buildInitialsBox(gold),
              //       ],
              //       const SizedBox(width: 14),

              //       // Identity
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'WORKSPACE OWNER',
              //               style: TextStyle(
              //                 fontFamily: 'monospace',
              //                 fontSize: 9,
              //                 fontWeight: FontWeight.bold,
              //                 letterSpacing: 1.2,
              //                 color: dim,
              //               ),
              //             ),
              //             const SizedBox(height: 3),
              //             Text(
              //               _userName,
              //               style: TextStyle(
              //                 fontSize: 20,
              //                 fontWeight: FontWeight.bold,
              //                 color: text,
              //               ),
              //             ),
              //             const SizedBox(height: 2),
              //             Text(
              //               _workspaceName,
              //               maxLines: 1,
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(fontSize: 12, color: muted),
              //             ),
              //           ],
              //         ),
              //       ),

              //       // Edit Profile Button
              //       Container(
              //         width: 36,
              //         height: 36,
              //         decoration: BoxDecoration(
              //           color: surf2,
              //           shape: BoxShape.circle,
              //           border: Border.all(color: line),
              //         ),
              //         child: IconButton(
              //           padding: EdgeInsets.zero,
              //           icon: const Icon(Icons.edit_outlined, size: 17),
              //           color: muted,
              //           onPressed: () async {
              //             final result = await Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (_) => EditProfileScreen(
              //                   currentName: _userName,
              //                   currentWorkspace: _workspaceName,
              //                 ),
              //               ),
              //             );
              //             if (result == true) {
              //               _loadProfileAndWallet();
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 12),

              // Status Row (Available Coins)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: line),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1F8F5F),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x331F8F5F),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Available Coins',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: goldFade,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹$_walletBalance Coins',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: gold2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    Text(
                      '5 OPTIONS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: dim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Options List
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: line),
                ),
                child: Column(
                  children: [
                    _buildOptionRow(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      detail: 'Appearance, accounts and approval rules',
                      onTap: _showSettingsModal,
                      lineColor: line,
                      text: text,
                      dim: dim,
                      gold: gold,
                      goldFade: goldFade,
                    ),
                    _buildOptionRow(
                      icon: Icons.perm_media_outlined,
                      label: 'Storage',
                      detail: 'Manage images, reels and media files',
                      onTap: _showStorageModal,
                      lineColor: line,
                      text: text,
                      dim: dim,
                      gold: gold,
                      goldFade: goldFade,
                    ),
                    _buildOptionRow(
                      icon: Icons.check_circle_outline,
                      label: 'Approvals',
                      detail: '$_pendingApprovalsCount items waiting for you',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReviewApprovalsScreen(),
                          ),
                        ).then((_) => _loadProfileAndWallet());
                      },
                      lineColor: line,
                      text: text,
                      dim: dim,
                      gold: gold,
                      goldFade: goldFade,
                    ),
                    _buildOptionRow(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      detail: 'Performance and campaign insights',
                      onTap: _showReportsModal,
                      lineColor: line,
                      text: text,
                      dim: dim,
                      gold: gold,
                      goldFade: goldFade,
                    ),
                    _buildOptionRow(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      detail: 'Sign out of your MarketOS account',
                      onTap: _showLogoutDialog,
                      lineColor: Colors.transparent,
                      text: text,
                      dim: dim,
                      gold: gold,
                      goldFade: goldFade,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Back to Workspace Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: widget.onBackToWorkspace,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text(
                      'Back to workspace',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Version Tag
              Center(
                child: Text(
                  'MARKETOS MOBILE · V1.0.0',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: dim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsBox(Color gold) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: gold,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38B8862A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171008),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required String detail,
    required VoidCallback onTap,
    required Color lineColor,
    required Color text,
    required Color dim,
    required Color gold,
    required Color goldFade,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: lineColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: goldFade,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: gold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 11, color: dim),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: dim),
          ],
        ),
      ),
    );
  }
}
