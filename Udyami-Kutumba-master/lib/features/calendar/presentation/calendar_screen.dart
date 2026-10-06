import 'package:flutter/material.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../data/marketing_calendar_api.dart';
import '../models/marketing_calendar_models.dart';

enum CalendarViewMode { month, week, agenda }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final MarketingCalendarApi _api = MarketingCalendarApi();

  bool _isLoading = true;
  String? _errorMessage;
  MarketingCalendar? _marketingCalendar;
  List<MarketingCalendarActivity> _allActivities = [];

  // View & Filters
  CalendarViewMode _viewMode = CalendarViewMode.month;
  String _selectedFilter = 'all'; // all, instagram, facebook, linkedin, youtube, google_ads, meta_ads
  DateTime _currentDisplayMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  /// Format DateTime to YYYY-MM-DD
  String _toIsoDateString(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCalendar({DateTime? targetMonth}) async {
    final monthToLoad = targetMonth ?? _currentDisplayMonth;
    final firstDay = DateTime(monthToLoad.year, monthToLoad.month, 1);
    final lastDay = DateTime(monthToLoad.year, monthToLoad.month + 1, 0);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.getMarketingCalendar(
        startDate: _toIsoDateString(firstDay),
        endDate: _toIsoDateString(lastDay),
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        final rawList = response.data!.calendar;

        // Expand any recurring activities and deduplicate
        final expanded = _expandRecurringActivities(rawList, monthToLoad);
        final deduplicated = _deduplicateActivities(expanded);

        setState(() {
          _marketingCalendar = response.data;
          _allActivities = deduplicated;
          _isLoading = false;
        });

        // Set display month if targetMonth was specified
        if (targetMonth != null) {
          setState(() {
            _currentDisplayMonth = DateTime(targetMonth.year, targetMonth.month, 1);
          });
        }
      } else {
        setState(() {
          _errorMessage = response.message.isNotEmpty
              ? response.message
              : 'Failed to load marketing calendar. Please tap Retry.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network connection issue: $e';
        _isLoading = false;
      });
    }
  }

  /// Avoid duplicate events by using a unique composite key
  List<MarketingCalendarActivity> _deduplicateActivities(List<MarketingCalendarActivity> list) {
    final Map<String, MarketingCalendarActivity> uniqueMap = {};
    for (final act in list) {
      final key = '${act.date}_${act.platform}_${act.title}_${act.time}';
      uniqueMap[key] = act;
    }
    return uniqueMap.values.toList();
  }

  /// Handle recurring events (daily, weekly, weekdays) across the target month
  List<MarketingCalendarActivity> _expandRecurringActivities(
    List<MarketingCalendarActivity> list,
    DateTime month,
  ) {
    final result = <MarketingCalendarActivity>[];
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (final act in list) {
      result.add(act);

      final rec = act.recurrence?.toLowerCase().trim();
      if (rec == null || rec.isEmpty || rec == 'none') continue;

      final baseDt = act.localDateTime;
      if (baseDt == null) continue;

      if (rec == 'daily') {
        for (int day = 1; day <= daysInMonth; day++) {
          final target = DateTime(month.year, month.month, day);
          final dateStr = _toIsoDateString(target);
          if (dateStr != act.date) {
            result.add(act.copyWith(
              id: '${act.id}-rec-$dateStr',
              date: dateStr,
              day: day,
            ));
          }
        }
      } else if (rec == 'weekly') {
        for (int day = 1; day <= daysInMonth; day++) {
          final target = DateTime(month.year, month.month, day);
          if (target.weekday == baseDt.weekday) {
            final dateStr = _toIsoDateString(target);
            if (dateStr != act.date) {
              result.add(act.copyWith(
                id: '${act.id}-rec-$dateStr',
                date: dateStr,
                day: day,
              ));
            }
          }
        }
      } else if (rec == 'weekdays') {
        for (int day = 1; day <= daysInMonth; day++) {
          final target = DateTime(month.year, month.month, day);
          if (target.weekday >= DateTime.monday && target.weekday <= DateTime.friday) {
            final dateStr = _toIsoDateString(target);
            if (dateStr != act.date) {
              result.add(act.copyWith(
                id: '${act.id}-rec-$dateStr',
                date: dateStr,
                day: day,
              ));
            }
          }
        }
      }
    }

    return result;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Filter Logic
  // ──────────────────────────────────────────────────────────────────────────
  bool _matchesFilter(MarketingCalendarActivity activity, String filter) {
    if (filter == 'all') return true;
    final plat = activity.platform.toUpperCase();
    switch (filter) {
      case 'instagram':
        return plat == 'INSTAGRAM';
      case 'facebook':
        return plat == 'FACEBOOK';
      case 'linkedin':
        return plat == 'LINKEDIN';
      case 'youtube':
        return plat == 'YOUTUBE';
      case 'google_ads':
        return plat == 'GOOGLE_ADS';
      case 'meta_ads':
        return plat == 'META_ADS';
      default:
        return true;
    }
  }

  List<MarketingCalendarActivity> get _filteredActivities {
    return _allActivities.where((a) => _matchesFilter(a, _selectedFilter)).toList();
  }

  /// Get distinct active days sorted ascending
  List<int> get _activeDays {
    final days = _filteredActivities.map((a) => a.day).toSet().toList();
    days.sort();
    return days;
  }

  /// Activities for a specific calendar day number
  List<MarketingCalendarActivity> _eventsForDay(int day) {
    return _filteredActivities.where((a) => a.day == day).toList();
  }

  /// Activities for a specific [DateTime]
  List<MarketingCalendarActivity> _eventsForDate(DateTime date) {
    final dateStr = _toIsoDateString(date);
    return _filteredActivities.where((a) => a.date == dateStr).toList();
  }

  /// Title month name
  String _getCalendarMonthTitle() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (_viewMode == CalendarViewMode.agenda && _allActivities.isNotEmpty) {
      final firstDt = _allActivities.first.localDateTime;
      if (firstDt != null) {
        return '${monthNames[firstDt.month - 1]} ${firstDt.year}';
      }
    }

    return '${monthNames[_currentDisplayMonth.month - 1]} ${_currentDisplayMonth.year}';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Navigation & Date Changes
  // ──────────────────────────────────────────────────────────────────────────
  void _prevMonth() {
    final newMonth = DateTime(
      _currentDisplayMonth.year,
      _currentDisplayMonth.month - 1,
      1,
    );
    setState(() {
      _currentDisplayMonth = newMonth;
    });
    _loadCalendar(targetMonth: newMonth);
  }

  void _nextMonth() {
    final newMonth = DateTime(
      _currentDisplayMonth.year,
      _currentDisplayMonth.month + 1,
      1,
    );
    setState(() {
      _currentDisplayMonth = newMonth;
    });
    _loadCalendar(targetMonth: newMonth);
  }

  void _goToToday() {
    final now = DateTime.now();
    final newMonth = DateTime(now.year, now.month, 1);
    setState(() {
      _currentDisplayMonth = newMonth;
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
    _loadCalendar(targetMonth: newMonth);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CRUD Actions: Create, Edit, Delete, Status Update
  // ──────────────────────────────────────────────────────────────────────────
  void _deleteEvent(MarketingCalendarActivity event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Activity?'),
        content: Text('Are you sure you want to remove "${event.title}" from your calendar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _allActivities.removeWhere((a) => a.id == event.id);
              });
              await _api.deleteActivity(event.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Activity removed from calendar.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditEventModal(MarketingCalendarActivity event) {
    final titleCtrl = TextEditingController(text: event.title);
    final descCtrl = TextEditingController(text: event.description);
    String selectedPlatform = event.platform;
    String selectedTime = event.time;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title / Headline',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'What to do / Description',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Platform & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: ['INSTAGRAM', 'FACEBOOK', 'LINKEDIN', 'YOUTUBE', 'GOOGLE_ADS', 'META_ADS'].contains(selectedPlatform.toUpperCase())
                              ? selectedPlatform.toUpperCase()
                              : 'INSTAGRAM',
                          decoration: InputDecoration(
                            labelText: 'Platform',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'INSTAGRAM', child: Text('Instagram')),
                            DropdownMenuItem(value: 'FACEBOOK', child: Text('Facebook')),
                            DropdownMenuItem(value: 'LINKEDIN', child: Text('LinkedIn')),
                            DropdownMenuItem(value: 'YOUTUBE', child: Text('YouTube')),
                            DropdownMenuItem(value: 'GOOGLE_ADS', child: Text('Google Ads')),
                            DropdownMenuItem(value: 'META_ADS', child: Text('Meta Ads')),
                          ],
                          onChanged: (v) {
                            if (v != null) setModalState(() => selectedPlatform = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: selectedTime,
                          decoration: InputDecoration(
                            labelText: 'Time (e.g. 10:00 AM)',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (v) => selectedTime = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = event.copyWith(
                          title: sanitizeCloudPatra(titleCtrl.text.trim()),
                          description: sanitizeCloudPatra(descCtrl.text.trim()),
                          platform: selectedPlatform,
                          time: normalizeTimeString(selectedTime),
                        );

                        Navigator.pop(ctx);

                        setState(() {
                          final idx = _allActivities.indexWhere((a) => a.id == event.id);
                          if (idx != -1) {
                            _allActivities[idx] = updated;
                          }
                        });

                        await _api.updateActivity(updated);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.teal,
                              content: Text('Activity updated successfully.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _updateStatus(MarketingCalendarActivity event, String newStatus) async {
    final updated = event.copyWith(rawStatus: newStatus);
    setState(() {
      final idx = _allActivities.indexWhere((a) => a.id == event.id);
      if (idx != -1) {
        _allActivities[idx] = updated;
      }
    });

    await _api.updateActivityStatus(event.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal,
          content: Text('Status updated to $newStatus.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Bottom Sheet: Event Details (matches reference calendar.page.html:251-544)
  // ──────────────────────────────────────────────────────────────────────────
  void _openEventDetails(MarketingCalendarActivity event) {
    if (event.isPastDate) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header: Platform Badge + Edit + Delete + Close Buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.platformColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: event.platformColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(event.platformIcon, size: 14, color: event.platformColor),
                          const SizedBox(width: 6),
                          Text(
                            event.platform.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: event.platformColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit activity',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditEventModal(event);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      tooltip: 'Delete activity',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteEvent(event);
                      },
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Activity Type Row
                Row(
                  children: [
                    Icon(event.activityIcon, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(
                      event.activity.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Big Headline Title
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Schedule Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262626) : const Color(0xFFF4F6F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_outlined, size: 20, color: Colors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scheduled for',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.formattedDisplayDate,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              event.time,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Row with Quick Status Actions
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: event.isToday ? Colors.teal : Colors.blueAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.displayStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: event.isToday ? Colors.teal : Colors.blueAccent,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down_circle_outlined, size: 18, color: Colors.grey.shade500),
                      tooltip: 'Change Status',
                      onSelected: (val) {
                        Navigator.pop(ctx);
                        _updateStatus(event, val);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'Approved', child: Text('Mark Approved')),
                        PopupMenuItem(value: 'Published', child: Text('Mark Published')),
                        PopupMenuItem(value: 'Completed', child: Text('Mark Completed')),
                        PopupMenuItem(value: 'Pending', child: Text('Mark Pending')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // "What to do" Section
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(
                      'What to do',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262626) : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    event.description.isNotEmpty
                        ? event.description
                        : 'Review this marketing item and prepare your media asset for broadcast.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // "Activity details" Card
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(
                      'Activity details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262626) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        icon: event.activityIcon,
                        label: 'Activity',
                        value: event.activity.replaceAll('_', ' '),
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildDetailItem(
                        icon: event.platformIcon,
                        label: 'Platform',
                        value: event.platform,
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildDetailItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Calendar day',
                        value: 'Day ${event.day}',
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildDetailItem(
                        icon: Icons.today_rounded,
                        label: 'Date',
                        value: event.date,
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                      _buildDetailItem(
                        icon: Icons.alarm_rounded,
                        label: 'Scheduled time',
                        value: event.time,
                        isDark: isDark,
                      ),
                      if (event.attendee != null && event.attendee!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildDetailItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Attendee / Contact',
                          value: event.attendee!,
                          isDark: isDark,
                        ),
                      ],
                      if (event.location != null && event.location!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildDetailItem(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: event.location!,
                          isDark: isDark,
                        ),
                      ],
                      if (event.reminder != null && event.reminder!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildDetailItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Reminder',
                          value: event.reminder!,
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // "Got it" action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Add Post Modal (matches reference calendar.page.html:154-247)
  // ──────────────────────────────────────────────────────────────────────────
  void _showAddPostModal() {
    final topicCtrl = TextEditingController();
    String channel = 'Instagram · Reel';
    DateTime selectedPostDate = _selectedDate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add a post',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // What's it about?
                  Text(
                    "What's it about?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: topicCtrl,
                    decoration: InputDecoration(
                      hintText: 'New 5-axis machine arriving next week',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Channel Select
                  Text(
                    'Channel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: channel,
                        isExpanded: true,
                        dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'Instagram · Reel', child: Text('Instagram · Reel')),
                          DropdownMenuItem(value: 'Instagram · Carousel', child: Text('Instagram · Carousel')),
                          DropdownMenuItem(value: 'Facebook · Image', child: Text('Facebook · Image')),
                          DropdownMenuItem(value: 'YouTube · Short', child: Text('YouTube · Short')),
                          DropdownMenuItem(value: 'LinkedIn · Post', child: Text('LinkedIn · Post')),
                          DropdownMenuItem(value: 'Google Ads · Search', child: Text('Google Ads · Search')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => channel = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // When (Date Picker)
                  Text(
                    'When',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedPostDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedPostDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFF4F5F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _toIsoDateString(selectedPostDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mini note
                  Text(
                    "We'll draft copy and creative from your brief, then send it back here for approval.",
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Create draft button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        final topic = topicCtrl.text.trim();
                        if (topic.isEmpty) return;

                        Navigator.pop(ctx);

                        // Parse platform from channel
                        final platformKey = channel.toLowerCase().contains('instagram')
                            ? 'INSTAGRAM'
                            : (channel.toLowerCase().contains('facebook')
                                ? 'FACEBOOK'
                                : (channel.toLowerCase().contains('youtube')
                                    ? 'YOUTUBE'
                                    : (channel.toLowerCase().contains('linkedin')
                                        ? 'LINKEDIN'
                                        : 'GOOGLE_ADS')));

                        final activityType = channel.toLowerCase().contains('reel')
                            ? 'REEL'
                            : (channel.toLowerCase().contains('carousel')
                                ? 'CAROUSEL'
                                : (channel.toLowerCase().contains('short')
                                    ? 'VIDEO'
                                    : 'SOCIAL_POST'));

                        final newActivity = MarketingCalendarActivity(
                          id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
                          day: selectedPostDate.day,
                          date: _toIsoDateString(selectedPostDate),
                          time: '10:00 AM',
                          activity: activityType,
                          platform: platformKey,
                          title: sanitizeCloudPatra(topic),
                          description: 'Generated draft from user brief: $topic',
                          rawStatus: 'Pending',
                        );

                        setState(() {
                          _allActivities.add(newActivity);
                          _selectedDate = selectedPostDate;
                        });

                        await _api.createDraftPost(
                          topic: topic,
                          channel: channel,
                          date: _toIsoDateString(selectedPostDate),
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.teal,
                              content: Text("Draft queued: It'll appear in Approvals shortly"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Create draft', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ──────────────────────────────────────────────────────────────────────────
  // VIEW 1: Interactive Month Calendar Grid
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMonthView(bool isDark) {
    final firstDayOfMonth = DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month, 1);
    final daysInMonth = DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month + 1, 0).day;
    final leadingEmptyDays = firstDayOfMonth.weekday % 7; // Sunday = 0
    final selectedEvents = _eventsForDate(_selectedDate);

    return RefreshIndicator(
      onRefresh: _loadCalendar,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Month navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: _prevMonth,
                tooltip: 'Previous month',
              ),
              Expanded(
                child: Text(
                  _getCalendarMonthTitle(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: _nextMonth,
                tooltip: 'Next month',
              ),
              TextButton(
                onPressed: _goToToday,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.teal,
                ),
                child: const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Calendar Card Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _WeekdayHeader('S'),
                    _WeekdayHeader('M'),
                    _WeekdayHeader('T'),
                    _WeekdayHeader('W'),
                    _WeekdayHeader('T'),
                    _WeekdayHeader('F'),
                    _WeekdayHeader('S'),
                  ],
                ),
                const SizedBox(height: 8),

                // Calendar Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leadingEmptyDays + daysInMonth,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    if (index < leadingEmptyDays) {
                      return const SizedBox.shrink();
                    }

                    final dayNumber = index - leadingEmptyDays + 1;
                    final cellDate = DateTime(
                      _currentDisplayMonth.year,
                      _currentDisplayMonth.month,
                      dayNumber,
                    );
                    final isSelected = cellDate.year == _selectedDate.year &&
                        cellDate.month == _selectedDate.month &&
                        cellDate.day == _selectedDate.day;
                    final isToday = cellDate.year == DateTime.now().year &&
                        cellDate.month == DateTime.now().month &&
                        cellDate.day == DateTime.now().day;

                    final dayEvents = _eventsForDate(cellDate);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = cellDate;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.teal
                              : (isToday
                                  ? Colors.teal.withValues(alpha: 0.12)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(10),
                          border: isToday && !isSelected
                              ? Border.all(color: Colors.teal, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: (isSelected || isToday)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isToday
                                        ? Colors.teal
                                        : (isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                              ),
                            ),
                            // Event indicator dots
                            if (dayEvents.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dayEvents.take(3).map((e) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? Colors.white : e.platformColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Selected Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Events for ${_formatDateHeader(_selectedDate)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedEvents.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Events list for selected date
          if (selectedEvents.isEmpty)
            _buildEmptyDayState(isDark)
          else
            ...selectedEvents.map((e) => _buildEventCard(e, isDark)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VIEW 2: Week Strip View
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWeekView(bool isDark) {
    final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final selectedEvents = _eventsForDate(_selectedDate);

    return RefreshIndicator(
      onRefresh: _loadCalendar,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Week navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: () {
                  final newDate = _selectedDate.subtract(const Duration(days: 7));
                  final newMonth = DateTime(newDate.year, newDate.month, 1);
                  setState(() {
                    _selectedDate = newDate;
                    _currentDisplayMonth = newMonth;
                  });
                  _loadCalendar(targetMonth: newMonth);
                },
                tooltip: 'Previous week',
              ),
              Expanded(
                child: Text(
                  '${_formatShortMonthDay(weekDays.first)} – ${_formatShortMonthDay(weekDays.last)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: () {
                  final newDate = _selectedDate.add(const Duration(days: 7));
                  final newMonth = DateTime(newDate.year, newDate.month, 1);
                  setState(() {
                    _selectedDate = newDate;
                    _currentDisplayMonth = newMonth;
                  });
                  _loadCalendar(targetMonth: newMonth);
                },
                tooltip: 'Next week',
              ),
              TextButton(
                onPressed: _goToToday,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.teal,
                ),
                child: const Text('Today', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 7-Day horizontal strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDays.map((date) {
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                const weekHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                final header = weekHeaders[date.weekday % 7];
                final dayEvents = _eventsForDate(date);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.teal
                          : (isToday
                              ? Colors.teal.withValues(alpha: 0.12)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(color: Colors.teal, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          header,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white70
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : const Color(0xFF0D1B4C)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (dayEvents.isNotEmpty)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.white : Colors.teal,
                            ),
                          )
                        else
                          const SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Events list for selected date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Events for ${_formatDateHeader(_selectedDate)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedEvents.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (selectedEvents.isEmpty)
            _buildEmptyDayState(isDark)
          else
            ...selectedEvents.map((e) => _buildEventCard(e, isDark)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VIEW 3: Agenda View (Exact match of reference calendar.page.html:85-136)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAgendaView(bool isDark) {
    final activeDays = _activeDays;

    if (activeDays.isEmpty) {
      return _buildEmptyCalendarState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadCalendar,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: activeDays.length + 1, // +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == activeDays.length) {
            return const SizedBox(height: 80);
          }

          final day = activeDays[index];
          final events = _eventsForDay(day);
          final firstEvent = events.isNotEmpty ? events.first : null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 46x46 Date Badge (.date-badge)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282828) : const Color(0xFFF4F5F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        firstEvent != null ? firstEvent.dayString : day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        firstEvent != null ? firstEvent.monthShortName : 'DAY',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Day events list (.day-events)
                Expanded(
                  child: Column(
                    children: events.map((event) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildEventCard(event, isDark),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Card Widget: .ev (matches reference .ev styling)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEventCard(MarketingCalendarActivity event, bool isDark) {
    final isPast = event.isPastDate;

    return Opacity(
      opacity: isPast ? 0.45 : 1.0,
      child: InkWell(
        onTap: isPast ? null : () => _openEventDetails(event),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: event.platformColor.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: event.platformColor, width: 2.5),
            ),
          ),
          child: Row(
            children: [
              // Dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: event.platformColor,
                ),
              ),
              const SizedBox(width: 8),

              // Title (.lbl)
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Time (.time)
              Text(
                event.time,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 4),

              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Empty & Error States
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyCalendarState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No marketing calendar found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your 30-day marketing calendar will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadCalendar(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Generate / Refresh Calendar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.amber),
            ),
            const SizedBox(height: 16),
            Text(
              'Calendar Unavailable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unable to connect to the marketing calendar service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadCalendar(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDayState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'No activities scheduled for this date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the + button below to queue a draft post.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helper Formatters
  // ──────────────────────────────────────────────────────────────────────────
  String _formatDateHeader(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatShortMonthDay(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD SCREEN
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.teal;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        title: Text(
          'Marketing Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF0D1B4C),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Calendar',
            onPressed: () => _loadCalendar(),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Section Header (matches reference mk-section-header)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCalendarMonthTitle(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _marketingCalendar != null
                                ? '${_marketingCalendar!.durationDays}-day schedule. Approved items publish automatically.'
                                : 'Approved items publish automatically. Drafts wait for you.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Channel Filter dropdown (.chan-select)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F5F8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isDense: true,
                          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0D1B4C),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All channels')),
                            DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                            DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                            DropdownMenuItem(value: 'linkedin', child: Text('LinkedIn')),
                            DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                            DropdownMenuItem(value: 'google_ads', child: Text('Google Ads')),
                            DropdownMenuItem(value: 'meta_ads', child: Text('Meta Ads')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFilter = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // View Mode Switcher: Month | Week | Agenda
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFECEFF3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildViewTab(
                        label: 'Month',
                        icon: Icons.calendar_view_month_rounded,
                        mode: CalendarViewMode.month,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                      _buildViewTab(
                        label: 'Week',
                        icon: Icons.view_week_rounded,
                        mode: CalendarViewMode.week,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                      _buildViewTab(
                        label: 'Agenda',
                        icon: Icons.view_agenda_rounded,
                        mode: CalendarViewMode.agenda,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2.5),
                        SizedBox(height: 16),
                        Text(
                          'Loading your marketing calendar...',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState(isDark)
                    : switch (_viewMode) {
                        CalendarViewMode.month => _buildMonthView(isDark),
                        CalendarViewMode.week => _buildWeekView(isDark),
                        CalendarViewMode.agenda => _buildAgendaView(isDark),
                      },
          ),
        ],
      ),

      // Floating Action Button (+ Add Post Modal)
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostModal,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Add a post',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildViewTab({
    required String label,
    required IconData icon,
    required CalendarViewMode mode,
    required Color primaryColor,
    required bool isDark,
  }) {
    final isSelected = _viewMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF383838) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String letter;
  const _WeekdayHeader(this.letter);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        letter,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
