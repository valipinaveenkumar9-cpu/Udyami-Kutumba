import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/api.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../data/social_channel_api.dart';
import '../models/social_channel_models.dart';

class ReviewApprovalsScreen extends StatefulWidget {
  final String initialFilter;
  final VoidCallback? onContentChanged;

  const ReviewApprovalsScreen({
    super.key,
    this.initialFilter = 'waiting',
    this.onContentChanged,
  });

  @override
  State<ReviewApprovalsScreen> createState() => _ReviewApprovalsScreenState();
}

class _ReviewApprovalsScreenState extends State<ReviewApprovalsScreen> {
  final SocialChannelApi _api = SocialChannelApi();

  bool _isLoading = true;
  String? _errorMessage;
  List<GeneratedContentItem> _allContents = [];
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contents = await _api.getAllGeneratedContent();
      if (!mounted) return;
      setState(() {
        _allContents = contents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load generated content: $e';
        _isLoading = false;
      });
    }
  }

  List<GeneratedContentItem> get _filteredContents {
    switch (_selectedFilter) {
      case 'waiting':
        return _allContents.where((c) => c.isWaitingApproval).toList();
      case 'published':
        return _allContents.where((c) => c.isPublished).toList();
      case 'rejected':
        return _allContents.where((c) => c.isRejected).toList();
      case 'all':
      default:
        return _allContents;
    }
  }

  int get _waitingCount =>
      _allContents.where((c) => c.isWaitingApproval).length;
  int get _publishedCount => _allContents.where((c) => c.isPublished).length;
  int get _rejectedCount => _allContents.where((c) => c.isRejected).length;

  Future<bool> _requireActiveMembership() async {
    final user = SessionManager.user;
    bool isDigital = user?['isPrime'] == true || user?['isDigital'] == true;
    int coins = 0;
    try {
      final userId = user?['userId'] ?? user?['id'] ?? user?['_id'];
      if (userId != null) {
        final res = await ApiClient().get('/auth/getDigitalUserdataBy/$userId');
        if (res is Map && res['data'] != null) {
          isDigital = res['data']['isDigital'] == true;
          final bal = res['data']['wallet']?['balanceCoins'];
          if (bal != null) coins = int.tryParse(bal.toString()) ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Failed to load digital user data: $e');
    }

    if (isDigital && coins > 0) return true;

    if (!mounted) return false;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Renew membership'),
        content: Text(
          coins > 0
              ? 'Your digital membership is inactive. Please renew to continue.'
              : 'Your wallet has 0 coins. Please renew your membership to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _approveAndPublish(GeneratedContentItem content) async {
    if (!await _requireActiveMembership()) return;
    
    final messenger = ScaffoldMessenger.of(context);
    final result = await _api.publishContent(content);
    if (!mounted) return;

    if (result['success'] != false) {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF00897B),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Content published successfully! It will appear on your social feed shortly.',
            style: TextStyle(fontSize: 13),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      widget.onContentChanged?.call();
      _loadData();
    } else {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            result['message']?.toString() ?? 'Failed to publish content.',
          ),
        ),
      );
    }
  }

  Future<void> _showRegenerateDialog(GeneratedContentItem content) async {
    if (!await _requireActiveMembership()) return;
    
    final reqCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        final isDark = Theme.of(bottomSheetCtx).brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetCtx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Requirement / Regenerate',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(bottomSheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Specify adjustments or styling guidance for AI regeneration.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: reqCtrl,
                  maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Focus on our weekend 20% discount offer and use a warmer, more welcoming tone...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor:
                        isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(bottomSheetCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = reqCtrl.text.trim();
                          if (text.isEmpty) return;
                          Navigator.pop(bottomSheetCtx);

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Regenerating content... We will update your preview shortly.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          await _api.regenerateContent(
                            contentId: content.id,
                            requirement: text,
                          );
                          widget.onContentChanged?.call();
                          if (mounted) _loadData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Regenerate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRejectDialog(GeneratedContentItem content) async {
    if (!await _requireActiveMembership()) return;

    final messenger = ScaffoldMessenger.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: const Text('Reject Content?'),
        content: const Text(
          'Are you sure you want to reject this content item? It will be removed from your active approval queue.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      await _api.rejectContent(content.id);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Content rejected.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onContentChanged?.call();
        _loadData();
      }
    }
  }

  void _showImagePreviewDialog(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.5,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.teal;
    final list = _filteredContents;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Review Approvals',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
              ),
            ),
            if (_waitingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_waitingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh approvals',
            onPressed: _loadData,
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Subtitle Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review your AI-generated marketing content before publishing to social media.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Waiting for you ($_waitingCount)',
                        filterKey: 'waiting',
                        accentColor: Colors.amber.shade800,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'All (${_allContents.length})',
                        filterKey: 'all',
                        accentColor: primaryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Published ($_publishedCount)',
                        filterKey: 'published',
                        accentColor: Colors.green,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Rejected ($_rejectedCount)',
                        filterKey: 'rejected',
                        accentColor: Colors.redAccent,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main body list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.teal),
                        SizedBox(height: 12),
                        Text(
                          'Loading generated content...',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState(isDark)
                    : list.isEmpty
                        ? _buildEmptyState(isDark)
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                return _buildApprovalCard(list[index], isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String filterKey,
    required Color accentColor,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == filterKey;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : accentColor)
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalCard(GeneratedContentItem item, bool isDark) {
    final hasMedia = item.mediaUrl != null && item.mediaUrl!.isNotEmpty;
    final isWaiting = item.isWaitingApproval;
    final isPublished = item.isPublished;
    final isRejected = item.isRejected;

    final railColor = isWaiting
        ? Colors.amber.shade800
        : isPublished
            ? const Color(0xFF10B981)
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWaiting
              ? Colors.amber.withValues(alpha: isDark ? 0.35 : 0.4)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Colored Rail
          Container(
            height: 3.5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: railColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),

          // Media Preview
          if (hasMedia) ...[
            if (item.isVideo || isVideoUrl(item.mediaUrl)) ...[
              Stack(
                children: [
                  AppVideoThumbnail(
                    videoUrl: item.mediaUrl!,
                    title: item.displayHeadline,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  // Status badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildStatusPill(item),
                  ),
                ],
              ),
            ] else ...[
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePreviewDialog(
                      item.mediaUrl!,
                      item.displayHeadline,
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: item.mediaUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Zoom overlay hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Tap to view',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildStatusPill(item),
                  ),
                ],
              ),
            ],
          ],

          // Body Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildChipTag(
                      item.platformLabel,
                      item.platformColor,
                      icon: item.platformIcon,
                    ),
                    if (item.contentType != null &&
                        item.contentType!.isNotEmpty)
                      _buildChipTag(
                        item.contentType!,
                        Colors.indigo,
                        icon: item.contentTypeIcon,
                      ),
                    if (item.activityDate.isNotEmpty)
                      _buildChipTag(
                        '${item.activityDate} ${item.activityTime}',
                        Colors.blueGrey,
                        icon: Icons.calendar_today_outlined,
                      ),
                    if (!hasMedia) _buildStatusPill(item),
                  ],
                ),
                const SizedBox(height: 12),

                // Activity Title
                if (item.activityTitle.isNotEmpty) ...[
                  Text(
                    item.activityTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],

                // Headline
                Text(
                  item.displayHeadline,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
                const SizedBox(height: 6),

                // Product Name
                if (item.productName != null &&
                    item.productName!.isNotEmpty) ...[
                  Text(
                    'Product: ${item.productName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Caption Box with copy button
                if (item.displayCaption.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CAPTION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: item.displayCaption),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Caption copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 13,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          item.displayCaption,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark
                                ? Colors.grey.shade200
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Description
                if (item.displayDescription.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF171717) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      item.displayDescription,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Call To Action
                if (item.displayCallToAction.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          color: Color(0xFFB45309),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'CTA: ${item.displayCallToAction}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Hashtags
                if (item.displayHashtags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.displayHashtags
                        .map(
                          (tag) => Text(
                            tag.startsWith('#') ? tag : '#$tag',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Marketing Activity Details
                if (item.activityTitle.isNotEmpty ||
                    item.activityDescription.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF141414) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MARKETING ACTIVITY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (item.activityTitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.activityTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (item.activityDescription.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.activityDescription,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Divider(height: 20),

                // Action Buttons or Status Outcome
                if (isWaiting) ...[
                  Row(
                    children: [
                      // Approve & Publish button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveAndPublish(item),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text(
                            'Approve & Publish',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Add Requirement / Regenerate button
                      OutlinedButton.icon(
                        onPressed: () => _showRegenerateDialog(item),
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text('Add Req', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Reject button
                      IconButton(
                        tooltip: 'Reject content',
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => _showRejectDialog(item),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.red.withValues(alpha: isDark ? 0.2 : 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (isPublished) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Published successfully',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      if (item.publishedUrl != null &&
                          item.publishedUrl!.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            final uri = Uri.tryParse(item.publishedUrl!);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: const Text(
                            'View Post',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ] else if (isRejected) ...[
                  const Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Content rejected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],

                // Creation Timestamp
                if (item.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Generated: ${_formatDateTime(item.createdAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(GeneratedContentItem item) {
    if (item.isPublished) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Published',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (item.isRejected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Rejected',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text(
            'Waiting on you',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipTag(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing waiting',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedFilter == 'waiting'
                  ? 'No generated marketing content is currently awaiting your approval.'
                  : 'No marketing content matches this filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh Content'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
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

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Unable to load approvals right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
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
