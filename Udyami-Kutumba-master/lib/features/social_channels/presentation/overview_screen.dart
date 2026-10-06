import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/session_manager.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import 'review_approvals_screen.dart';

class OverviewScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAccounts;
  final VoidCallback? onNavigateToApprovals;

  const OverviewScreen({
    super.key,
    this.onNavigateToAccounts,
    this.onNavigateToApprovals,
  });

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final SocialChannelApi _api = SocialChannelApi();

  bool _isLoading = true;
  String? _errorMessage;
  List<GeneratedContentItem> _allContents = [];
  List<ChannelConnectionItem> _connections =
      ChannelConnectionItem.defaultConnections();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _api.getAllGeneratedContent(),
        _loadSocialAccounts(),
      ]);

      if (!mounted) return;
      setState(() {
        _allContents = results[0] as List<GeneratedContentItem>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load overview data: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<ChannelConnectionItem>> _loadSocialAccounts() async {
    try {
      final accounts = await _api.getUserSocialMediaAccounts();
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
      return updated;
    } catch (_) {
      return _connections;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getOwnerName() {
    final user = SessionManager.user;
    if (user != null) {
      final name = user['name'] ?? user['firstName'] ?? user['fullName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    }
    return 'Entrepreneur';
  }

  int get _publishedCount =>
      _allContents.where((c) => c.isPublished).length;

  int get _rejectedCount =>
      _allContents.where((c) => c.isRejected).length;

  int get _pendingCount =>
      _allContents.where((c) => c.isWaitingApproval).length;

  int get _connectedAccountsCount =>
      _connections.where((c) => c.connected).length;

  void _openReviewApprovals({String filter = 'waiting'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewApprovalsScreen(
          initialFilter: filter,
          onContentChanged: _loadAllData,
        ),
      ),
    );
  }

  List<_ActivityFeedRowData> _buildFeedRows() {
    final sorted = List<GeneratedContentItem>.from(_allContents);
    sorted.sort((a, b) {
      final dtA = _parseContentTimestamp(a);
      final dtB = _parseContentTimestamp(b);
      return dtB.compareTo(dtA);
    });

    return sorted.take(6).map((content) {
      final name = content.productName != null && content.productName!.isNotEmpty
          ? content.productName!
          : content.displayHeadline;
      final platform = content.platformLabel;

      if (content.isPublished) {
        return _ActivityFeedRowData(
          text: '$name published to $platform',
          time: _formatActivityTime(content),
          toneColor: const Color(0xFF10B981),
        );
      } else if (content.isRejected) {
        return _ActivityFeedRowData(
          text: '$name rejected from approval',
          time: _formatActivityTime(content),
          toneColor: const Color(0xFFEF4444),
        );
      } else if (content.isWaitingApproval) {
        return _ActivityFeedRowData(
          text: '$name waiting for your approval',
          time: _formatActivityTime(content),
          toneColor: const Color(0xFFF59E0B),
        );
      } else {
        return _ActivityFeedRowData(
          text: '$name marketing content updated',
          time: _formatActivityTime(content),
          toneColor: Colors.blueGrey,
        );
      }
    }).toList();
  }

  DateTime _parseContentTimestamp(GeneratedContentItem c) {
    for (final str in [c.publishedAt, c.createdAt]) {
      if (str != null && str.isNotEmpty) {
        try {
          return DateTime.parse(str);
        } catch (_) {}
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatActivityTime(GeneratedContentItem c) {
    final dt = _parseContentTimestamp(c);
    if (dt.millisecondsSinceEpoch == 0) return 'Recently';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 59)}m ago';
    } else if (diff.inHours < 24) {
      return DateFormat('hh:mm a').format(dt.toLocal());
    } else if (diff.inDays < 7) {
      return DateFormat('EEE, hh:mm a').format(dt.toLocal());
    } else {
      return DateFormat('dd MMM').format(dt.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingSkeleton(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 1. SECTION HEADER
          _buildSectionHeader(isDark),
          const SizedBox(height: 18),

          // 2. KPI METRICS (2x2 Grid)
          _buildKpiGrid(isDark),
          const SizedBox(height: 16),

          // 3. CONNECTED CHANNELS STATUS CARD
          _buildChannelsSummaryCard(isDark),
          const SizedBox(height: 16),

          // 4. ACTIVITY FEED CARD
          _buildActivityFeedCard(isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. SECTION HEADER with "Review Approvals" Action
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(bool isDark) {
    final greeting = _getGreeting();
    final ownerName = _getOwnerName();
    final pending = _pendingCount;

    final subtitleText = pending > 0
        ? '$pending ${pending == 1 ? 'item is' : 'items are'} waiting for your approval. Nothing publishes and nothing spends until you say so.'
        : 'No items are waiting for your approval. Everything is up to date.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $ownerName 👋',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Review Approvals Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openReviewApprovals(filter: 'waiting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Review Approvals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (pending > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. KPI METRICS (2x2 Grid)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: 'PUBLISHED',
                value: '$_publishedCount',
                sub: 'Content published to social media',
                accentColor: const Color(0xFF10B981),
                icon: Icons.check_circle_outline_rounded,
                isDark: isDark,
                onTap: () => _openReviewApprovals(filter: 'published'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: 'REJECTED',
                value: '$_rejectedCount',
                sub: 'Content rejected from approval',
                accentColor: const Color(0xFFEF4444),
                icon: Icons.cancel_outlined,
                isDark: isDark,
                onTap: () => _openReviewApprovals(filter: 'rejected'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: 'PENDING APPROVAL',
                value: '$_pendingCount',
                sub: 'Content waiting for your decision',
                accentColor: const Color(0xFFF59E0B),
                icon: Icons.hourglass_top_rounded,
                isDark: isDark,
                onTap: () => _openReviewApprovals(filter: 'waiting'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: 'TOTAL CONTENT',
                value: '${_allContents.length}',
                sub: 'Generated content in your workspace',
                accentColor: Colors.teal,
                icon: Icons.auto_awesome_outlined,
                isDark: isDark,
                onTap: () => _openReviewApprovals(filter: 'all'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String sub,
    required Color accentColor,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. CHANNELS CONNECTION SUMMARY CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildChannelsSummaryCard(bool isDark) {
    final active = _connectedAccountsCount;
    final total = _connections.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.hub_rounded, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Multi-Channel Distribution',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$active of $total connected',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Connect social media & ad platforms to publish automated campaigns, sync audiences, and track ROI.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Channel Icons Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _connections.map((conn) {
              return Tooltip(
                message: '${conn.name}: ${conn.connected ? 'Connected' : 'Not Connected'}',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: conn.connected
                        ? conn.color.withValues(alpha: 0.15)
                        : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: conn.connected
                          ? conn.color
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      width: conn.connected ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    conn.icon,
                    size: 18,
                    color: conn.connected ? conn.color : Colors.grey.shade400,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. ACTIVITY FEED CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildActivityFeedCard(bool isDark) {
    final feedRows = _buildFeedRows();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                ),
              ),
              if (_allContents.isNotEmpty)
                InkWell(
                  onTap: () => _openReviewApprovals(filter: 'all'),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (feedRows.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No recent marketing activity recorded yet.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ] else ...[
            ...feedRows.map((row) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF262626)
                          : Colors.grey.shade200,
                      width: 0.6,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: row.toneColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.text,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      row.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SKELETON / LOADING STATE
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Skeleton
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          ),
        ),
        const SizedBox(height: 16),

        // KPI Skeletons
        Row(
          children: [
            Expanded(child: _buildSkeletonBox(80, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonBox(80, isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonBox(80, isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonBox(80, isDark)),
          ],
        ),
        const SizedBox(height: 16),

        // Activity Skeleton
        _buildSkeletonBox(160, isDark),
      ],
    );
  }

  Widget _buildSkeletonBox(double height, bool isDark) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ERROR STATE
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            Text(
              'Failed to load overview',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Please check your connection and retry.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityFeedRowData {
  final String text;
  final String time;
  final Color toneColor;

  _ActivityFeedRowData({
    required this.text,
    required this.time,
    required this.toneColor,
  });
}
