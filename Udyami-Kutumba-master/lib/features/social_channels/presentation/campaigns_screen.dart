import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';
import 'widgets/marketos_theme.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final SocialChannelApi _api = SocialChannelApi();

  List<GeneratedContentItem> _publishedContents = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Spend Caps state
  String _dailyCap = '₹3,000';
  String _monthlyCeiling = '₹90,000';
  String _breaker = '2.5× trailing average';

  @override
  void initState() {
    super.initState();
    _loadPublishedContent();
  }

  Future<void> _loadPublishedContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final all = await _api.getAllGeneratedContent();
      if (!mounted) return;

      final published = all.where((c) => _isPublished(c)).toList();
      setState(() {
        _publishedContents = published;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _publishedContents = [];
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  bool _isPublished(GeneratedContentItem content) {
    return content.status?.toUpperCase() == 'PUBLISHED' ||
        (content.publishedAt != null && content.publishedAt!.isNotEmpty);
  }

  Map<String, int> get _platformCounts {
    final counts = {
      'instagram': 0,
      'meta': 0,
      'google': 0,
      'linkedin': 0,
      'other': 0,
    };

    for (final content in _publishedContents) {
      final key = _getPlatformKey(content.platform);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return counts;
  }

  String _getPlatformKey(String? platform) {
    final normalized = (platform ?? '').toLowerCase();
    if (normalized.contains('instagram')) return 'instagram';
    if (normalized.contains('meta') || normalized.contains('facebook')) {
      return 'meta';
    }
    if (normalized.contains('google')) return 'google';
    if (normalized.contains('linkedin')) return 'linkedin';
    return 'other';
  }

  String _getPlatformLabel(String? platform) {
    final key = _getPlatformKey(platform);
    switch (key) {
      case 'instagram':
        return 'Instagram';
      case 'meta':
        return 'Meta Ads';
      case 'google':
        return 'Google Ads';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform ?? 'Other channel';
    }
  }

  IconData _getPlatformIcon(String? platform) {
    final key = _getPlatformKey(platform);
    switch (key) {
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'meta':
        return Icons.facebook;
      case 'google':
        return Icons.ads_click_rounded;
      case 'linkedin':
        return Icons.business_center_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  String _getHeadline(GeneratedContentItem content) {
    return content.aiResponse?['marketingContent']?['headline']?.toString() ??
        content.productName ??
        content.displayHeadline;
  }

  String _getCaption(GeneratedContentItem content) {
    return content.aiResponse?['marketingContent']?['caption']?.toString() ??
        content.displayCaption;
  }

  bool _isVideoContent(GeneratedContentItem content) {
    final mediaType = (content.mediaType ?? '').toLowerCase();
    final contentType = (content.contentType ?? '').toLowerCase();
    final activityType = (content.activityType ?? '').toLowerCase();
    final mediaUrl = (content.mediaUrl ?? '').toLowerCase().split('?').first;

    return mediaType.startsWith('video') ||
        contentType.contains('video') ||
        contentType.contains('reel') ||
        activityType.contains('video') ||
        activityType.contains('reel') ||
        mediaUrl.endsWith('.mp4') ||
        mediaUrl.endsWith('.webm') ||
        mediaUrl.endsWith('.mov');
  }

  String _getPublishedDate(GeneratedContentItem content) {
    final raw =
        content.publishedAt ?? content.updatedAt ?? content.createdAt;
    if (raw == null || raw.isEmpty) return 'Published recently';

    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  void _showSpendCapsModal() {
    final dailyCtrl = TextEditingController(text: _dailyCap);
    final monthlyCtrl = TextEditingController(text: _monthlyCeiling);
    String selectedBreaker = _breaker;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final surf = MarketOSTheme.surf(modalCtx);
            final text = MarketOSTheme.text(modalCtx);
            final muted = MarketOSTheme.muted(modalCtx);
            final line = MarketOSTheme.line(modalCtx);
            final gold = MarketOSTheme.gold(modalCtx);

            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: surf,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spend caps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                        color: muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Daily cap
                  Text(
                    'Daily cap — set on the ad account itself',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: dailyCtrl,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                    decoration: _inputDecoration(modalCtx),
                  ),
                  const SizedBox(height: 14),

                  // Monthly ceiling
                  Text(
                    'Monthly ceiling',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: monthlyCtrl,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                    decoration: _inputDecoration(modalCtx),
                  ),
                  const SizedBox(height: 14),

                  // Circuit breaker
                  Text(
                    'Circuit breaker — auto-pause when cost per result exceeds',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedBreaker,
                    isExpanded: true,
                    decoration: _inputDecoration(modalCtx),
                    items: const [
                      DropdownMenuItem(
                        value: '2.5× trailing average',
                        child: Text('2.5× trailing average'),
                      ),
                      DropdownMenuItem(
                        value: '2× trailing average',
                        child: Text('2× trailing average'),
                      ),
                      DropdownMenuItem(
                        value: '3× trailing average',
                        child: Text('3× trailing average'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => selectedBreaker = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Pausing spend is the only thing this system does without asking you first. Everything else waits.',
                    style: TextStyle(
                      fontSize: 11,
                      color: muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dailyCap = dailyCtrl.text.trim();
                          _monthlyCeiling = monthlyCtrl.text.trim();
                          _breaker = selectedBreaker;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF00897B),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Caps updated. Enforced on the ad account, not just here.',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save caps',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  InputDecoration _inputDecoration(BuildContext ctx) {
    final surf2 = MarketOSTheme.surf2(ctx);
    final line = MarketOSTheme.line(ctx);

    return InputDecoration(
      filled: true,
      fillColor: surf2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: MarketOSTheme.gold(ctx), width: 1.5),
      ),
    );
  }

  void _showCampaignDetailsModal(GeneratedContentItem content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final surf = MarketOSTheme.surf(ctx);
        final text = MarketOSTheme.text(ctx);
        final muted = MarketOSTheme.muted(ctx);
        final line = MarketOSTheme.line(ctx);
        final gold = MarketOSTheme.gold(ctx);
        final headline = _getHeadline(content);
        final caption = _getCaption(content);

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          decoration: BoxDecoration(
            color: surf,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: line)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_getPlatformIcon(content.platform),
                            size: 18, color: gold),
                        const SizedBox(width: 8),
                        Text(
                          _getPlatformLabel(content.platform),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: text,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      color: muted,
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Media Frame Preview
                      if (content.mediaUrl != null &&
                          content.mediaUrl!.isNotEmpty) ...[
                        if (_isVideoContent(content))
                          AppVideoThumbnail(
                            videoUrl: content.mediaUrl!,
                            title: headline,
                            height: 220,
                            width: double.infinity,
                          )
                        else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: content.mediaUrl!,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 220,
                                color: MarketOSTheme.surf2(ctx),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 220,
                                color: MarketOSTheme.surf2(ctx),
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: muted),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],

                      // Published status tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0x1F1F8F5F),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x4D1F8F5F)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: Color(0xFF1F8F5F)),
                            SizedBox(width: 4),
                            Text(
                              'Published live',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F8F5F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Headline
                      Text(
                        headline,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: text,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Caption Box with copy action
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: MarketOSTheme.surf2(ctx),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CAPTION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: muted,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: caption));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Caption copied'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_rounded,
                                          size: 13, color: gold),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              caption,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hashtags
                      if (content.displayHashtags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: content.displayHashtags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: MarketOSTheme.goldFade(ctx),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Metadata Rows
                      _detailRow('Published Date',
                          _getPublishedDate(content), text, muted),
                      _detailRow('Content Type',
                          content.contentType ?? 'Post', text, muted),
                      if (content.productName != null &&
                          content.productName!.isNotEmpty)
                        _detailRow('Product / Campaign',
                            content.productName!, text, muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
      String label, String value, Color valueColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
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
    final gold = MarketOSTheme.gold(context);
    final counts = _platformCounts;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: _loadPublishedContent,
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              _buildSectionHeader(context),
              const SizedBox(height: 20),

              // Live Distribution Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIVE DISTRIBUTION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: gold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Published campaigns',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Every piece of content that has reached a connected channel.',
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _loadPublishedContent,
                    icon: const Icon(Icons.refresh_rounded),
                    color: gold,
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      side: BorderSide(
                        color: MarketOSTheme.line(context),
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4 Platform Cards Grid
              _buildPlatformCardsGrid(context, counts),
              const SizedBox(height: 20),

              // Published Cards Grid / List
              if (_isLoading) ...[
                _buildLoadingGrid(context),
              ] else if (_hasError) ...[
                _buildErrorCard(context),
              ] else if (_publishedContents.isEmpty) ...[
                _buildEmptyCard(context),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _publishedContents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final content = _publishedContents[index];
                    return _buildPublishedCard(context, content);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final line = MarketOSTheme.line(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campaigns',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Spend caps are set on the ad account itself, not just here — so they hold even if this app goes down.',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _showSpendCapsModal,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            'Edit spend caps',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCardsGrid(
      BuildContext context, Map<String, int> counts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isWide ? 1.6 : 1.7,
          children: [
            _buildPlatformCard(
              context: context,
              name: 'Instagram',
              count: counts['instagram'] ?? 0,
              subLabel: 'published posts',
              color: const Color(0xFFD35D78),
              icon: Icons.camera_alt_outlined,
            ),
            _buildPlatformCard(
              context: context,
              name: 'Meta Ads',
              count: counts['meta'] ?? 0,
              subLabel: 'published campaigns',
              color: const Color(0xFF4F7FD6),
              icon: Icons.facebook,
            ),
            _buildPlatformCard(
              context: context,
              name: 'Google Ads',
              count: counts['google'] ?? 0,
              subLabel: 'published campaigns',
              color: const Color(0xFFD28A35),
              icon: Icons.ads_click_rounded,
            ),
            _buildPlatformCard(
              context: context,
              name: 'LinkedIn',
              count: counts['linkedin'] ?? 0,
              subLabel: 'published posts',
              color: const Color(0xFF0A78B5),
              icon: Icons.business_center_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlatformCard({
    required BuildContext context,
    required String name,
    required int count,
    required String subLabel,
    required Color color,
    required IconData icon,
  }) {
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final dim = MarketOSTheme.dim(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Spark Circle
          Positioned(
            right: -20,
            bottom: -25,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.18),
                  width: 1,
                ),
              ),
            ),
          ),

          // Content
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: text,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedCard(
      BuildContext context, GeneratedContentItem content) {
    final surf = MarketOSTheme.surf(context);
    final surf2 = MarketOSTheme.surf2(context);
    final line = MarketOSTheme.line(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final gold = MarketOSTheme.gold(context);
    final isVideo = _isVideoContent(content);

    return InkWell(
      onTap: () => _showCampaignDetailsModal(content),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Frame (16:10 aspect ratio)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (content.mediaUrl != null &&
                      content.mediaUrl!.isNotEmpty) ...[
                    if (isVideo)
                      AppVideoThumbnail(
                        videoUrl: content.mediaUrl!,
                        title: _getHeadline(content),
                        borderRadius: BorderRadius.zero,
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: content.mediaUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: surf2,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: surf2,
                          child: Icon(Icons.broken_image_outlined,
                              color: muted, size: 30),
                        ),
                      ),
                  ] else ...[
                    Container(
                      color: surf2,
                      child: Center(
                        child: Icon(Icons.campaign_outlined,
                            color: gold, size: 40),
                      ),
                    ),
                  ],

                  // Published Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xB3131F1B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.22)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Published',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Published Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform + Date Meta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_getPlatformIcon(content.platform),
                              size: 14, color: gold),
                          const SizedBox(width: 4),
                          Text(
                            _getPlatformLabel(content.platform),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: gold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _getPublishedDate(content),
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Headline
                  Text(
                    _getHeadline(content),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: text,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Caption
                  Text(
                    _getCaption(content),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: MarketOSTheme.surf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MarketOSTheme.line(context)),
          ),
          child: Column(
            children: [
              Container(
                height: 160,
                color: MarketOSTheme.surf2(context),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: MarketOSTheme.surf2(context),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: MarketOSTheme.surf2(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final gold = MarketOSTheme.gold(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: MarketOSTheme.surf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MarketOSTheme.line(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, color: gold, size: 36),
            const SizedBox(height: 10),
            Text(
              'Published campaigns are unavailable',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Refresh to try loading the latest content.',
              style: TextStyle(fontSize: 11, color: muted),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loadPublishedContent,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    final gold = MarketOSTheme.gold(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: MarketOSTheme.surf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MarketOSTheme.line(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.rocket_launch_outlined, color: gold, size: 36),
            const SizedBox(height: 10),
            Text(
              'No published campaigns yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Approved content will appear here after publishing.',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
