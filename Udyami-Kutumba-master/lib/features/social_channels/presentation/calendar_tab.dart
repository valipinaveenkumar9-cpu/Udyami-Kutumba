import 'package:flutter/material.dart';
import '../../calendar/data/marketing_calendar_api.dart';
import '../../calendar/models/marketing_calendar_models.dart';
import 'widgets/marketos_theme.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final MarketingCalendarApi _calendarApi = MarketingCalendarApi();

  List<MarketingCalendarActivity> _allActivities = [];
  bool _isLoading = true;
  String? _error;
  String _channelFilter = 'all';

  // Add post dialog state
  final TextEditingController _newTopicCtrl = TextEditingController();
  final TextEditingController _newDateCtrl = TextEditingController();
  String _newChannel = 'Instagram · Reel';

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  @override
  void dispose() {
    _newTopicCtrl.dispose();
    _newDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCalendar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _calendarApi.getMarketingCalendar();
      if (!mounted) return;

      if (res.success && res.data != null) {
        setState(() {
          _allActivities = res.data!.calendar;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allActivities = [];
          _error = res.message.isNotEmpty
              ? res.message
              : 'Failed to load marketing calendar.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allActivities = [];
        _error = 'Error loading calendar: $e';
        _isLoading = false;
      });
    }
  }

  bool _matchesFilter(MarketingCalendarActivity activity) {
    if (_channelFilter == 'all') return true;

    final platform = activity.platform.toUpperCase();
    switch (_channelFilter) {
      case 'instagram':
        return platform.contains('INSTAGRAM');
      case 'facebook':
        return platform.contains('FACEBOOK');
      case 'linkedin':
        return platform.contains('LINKEDIN');
      case 'youtube':
        return platform.contains('YOUTUBE');
      case 'google_ads':
        return platform.contains('GOOGLE');
      case 'meta_ads':
        return platform.contains('META');
      default:
        return true;
    }
  }

  List<MarketingCalendarActivity> get _filteredActivities {
    return _allActivities.where(_matchesFilter).toList();
  }

  List<int> get _activeDays {
    final days = _filteredActivities.map((a) => a.day).toSet().toList();
    days.sort();
    return days;
  }

  List<MarketingCalendarActivity> _eventsForDay(int day) {
    return _filteredActivities.where((a) => a.day == day).toList();
  }

  String _getCalendarMonth() {
    if (_allActivities.isEmpty) return 'Marketing Calendar';
    final first = _allActivities.first;
    final dt = first.localDateTime;
    if (dt == null) return 'Marketing Calendar';

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[dt.month - 1];
  }

  void _showAddPostModal() {
    _newTopicCtrl.clear();
    _newDateCtrl.text = DateTime.now().add(const Duration(days: 1)).toString().split(' ').first;

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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add a post',
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

                  Text(
                    "What's it about?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _newTopicCtrl,
                    decoration: _inputDecoration(
                      modalCtx,
                      hint: 'New 5-axis machine arriving next week',
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Channel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _newChannel,
                    isExpanded: true,
                    decoration: _inputDecoration(modalCtx),
                    items: const [
                      DropdownMenuItem(
                        value: 'Instagram · Reel',
                        child: Text('Instagram · Reel'),
                      ),
                      DropdownMenuItem(
                        value: 'Instagram · Carousel',
                        child: Text('Instagram · Carousel'),
                      ),
                      DropdownMenuItem(
                        value: 'Facebook · Image',
                        child: Text('Facebook · Image'),
                      ),
                      DropdownMenuItem(
                        value: 'YouTube · Short',
                        child: Text('YouTube · Short'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => _newChannel = v);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'When',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _newDateCtrl,
                    decoration: _inputDecoration(modalCtx, hint: 'YYYY-MM-DD'),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "We'll draft copy and creative from your brief, then send it back here for approval.",
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
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF00897B),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              "Draft queued. It'll appear in Approvals shortly.",
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
                        'Create draft',
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

  InputDecoration _inputDecoration(BuildContext ctx, {String? hint}) {
    final surf2 = MarketOSTheme.surf2(ctx);
    final line = MarketOSTheme.line(ctx);
    final muted = MarketOSTheme.muted(ctx);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: muted.withValues(alpha: 0.6), fontSize: 12),
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

  void _showEventDetailsModal(MarketingCalendarActivity event) {
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

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: surf,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: line)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Platform badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: event.platformColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: event.platformColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(event.platformIcon,
                              size: 14, color: event.platformColor),
                          const SizedBox(width: 6),
                          Text(
                            event.platform,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: event.platformColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      color: muted,
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity Type Row
                      Row(
                        children: [
                          Icon(event.activityIcon, size: 14, color: gold),
                          const SizedBox(width: 6),
                          Text(
                            event.activity.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: text,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Schedule Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: MarketOSTheme.surf2(ctx),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: line),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.calendar_month_rounded,
                                  color: gold, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scheduled for',
                                    style:
                                        TextStyle(fontSize: 10, color: muted),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    event.formattedDisplayDate,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: surf,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: line),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 12, color: muted),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.time,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Row
                      Row(
                        children: [
                          Icon(
                            event.isPastDate
                                ? Icons.done_all_rounded
                                : Icons.schedule_rounded,
                            size: 15,
                            color: event.isPastDate
                                ? const Color(0xFF1F8F5F)
                                : gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.displayStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: event.isPastDate
                                  ? const Color(0xFF1F8F5F)
                                  : gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // What to do section
                      Text(
                        'WHAT TO DO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Activity Details Card
                      Text(
                        'ACTIVITY DETAILS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MarketOSTheme.surf2(ctx),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: line),
                        ),
                        child: Column(
                          children: [
                            _sheetDetailItem(
                              icon: event.activityIcon,
                              label: 'Activity',
                              value: event.activity.replaceAll('_', ' '),
                              text: text,
                              muted: muted,
                            ),
                            Divider(color: line, height: 16),
                            _sheetDetailItem(
                              icon: event.platformIcon,
                              label: 'Platform',
                              value: event.platform,
                              text: text,
                              muted: muted,
                            ),
                            Divider(color: line, height: 16),
                            _sheetDetailItem(
                              icon: Icons.calendar_view_day_rounded,
                              label: 'Calendar day',
                              value: 'Day ${event.day}',
                              text: text,
                              muted: muted,
                            ),
                            Divider(color: line, height: 16),
                            _sheetDetailItem(
                              icon: Icons.today_rounded,
                              label: 'Date',
                              value: event.date,
                              text: text,
                              muted: muted,
                            ),
                            Divider(color: line, height: 16),
                            _sheetDetailItem(
                              icon: Icons.alarm_rounded,
                              label: 'Scheduled time',
                              value: event.time,
                              text: text,
                              muted: muted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Got it button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Got it',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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

  Widget _sheetDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color text,
    required Color muted,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: muted)),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = MarketOSTheme.bg(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);
    final gold = MarketOSTheme.gold(context);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostModal,
        backgroundColor: gold,
        child: const Icon(Icons.add_rounded, color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCalendar,
        color: gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header with Month & Channel Selector
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCalendarMonth(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Approved items publish automatically at the scheduled time. Drafts wait for you.',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: surf,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: line),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _channelFilter,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All channels'),
                          ),
                          DropdownMenuItem(
                            value: 'instagram',
                            child: Text('Instagram'),
                          ),
                          DropdownMenuItem(
                            value: 'facebook',
                            child: Text('Facebook'),
                          ),
                          DropdownMenuItem(
                            value: 'linkedin',
                            child: Text('LinkedIn'),
                          ),
                          DropdownMenuItem(
                            value: 'youtube',
                            child: Text('YouTube'),
                          ),
                          DropdownMenuItem(
                            value: 'google_ads',
                            child: Text('Google Ads'),
                          ),
                          DropdownMenuItem(
                            value: 'meta_ads',
                            child: Text('Meta Ads'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _channelFilter = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Calendar Body
              if (_isLoading) ...[
                _buildLoadingState(context),
              ] else if (_error != null && _allActivities.isEmpty) ...[
                _buildErrorState(context),
              ] else if (_activeDays.isEmpty) ...[
                _buildEmptyState(context),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeDays.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final day = _activeDays[index];
                    final events = _eventsForDay(day);
                    return _buildDayRow(context, day, events);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(
      BuildContext context, int day, List<MarketingCalendarActivity> events) {
    final first = events.isNotEmpty ? events.first : null;
    final dayNum = first?.dayString ?? day.toString().padLeft(2, '0');
    final monthName = first?.monthShortName ?? '';
    final surf = MarketOSTheme.surf(context);
    final line = MarketOSTheme.line(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Badge
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayNum,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: text,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Day Events List
        Expanded(
          child: Column(
            children: events.map((event) {
              final isPast = event.isPastDate;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: line),
                ),
                child: InkWell(
                  onTap: isPast ? null : () => _showEventDetailsModal(event),
                  borderRadius: BorderRadius.circular(10),
                  child: Opacity(
                    opacity: isPast ? 0.45 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // Platform dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: event.platformColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Title
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Time
                          Text(
                            event.time,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                          const SizedBox(width: 6),

                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: muted),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: MarketOSTheme.gold(context)),
            const SizedBox(height: 14),
            Text(
              'Loading your marketing calendar...',
              style: TextStyle(
                fontSize: 12,
                color: MarketOSTheme.muted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
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
            Icon(Icons.calendar_month_outlined, color: gold, size: 36),
            const SizedBox(height: 10),
            Text(
              'Calendar temporarily unavailable',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? 'Please check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: muted),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loadCalendar,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final gold = MarketOSTheme.gold(context);
    final text = MarketOSTheme.text(context);
    final muted = MarketOSTheme.muted(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, color: gold, size: 48),
            const SizedBox(height: 14),
            Text(
              'No marketing calendar found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your 30-day marketing calendar will appear here.',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
