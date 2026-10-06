import 'package:flutter/material.dart';

/// Sanitize text by replacing "CloudPatra" (any case) with "Ownify"
String sanitizeCloudPatra(String text) {
  if (text.isEmpty) return text;
  return text.replaceAll(RegExp(r'CloudPatra', caseSensitive: false), 'Ownify');
}

/// Robust date normalizer that returns YYYY-MM-DD
String normalizeDateString(
  dynamic rawDate, {
  String? calendarStartDate,
  int? dayOffset,
}) {
  if (rawDate == null || rawDate.toString().trim().isEmpty) {
    if (calendarStartDate != null &&
        calendarStartDate.isNotEmpty &&
        dayOffset != null &&
        dayOffset > 0) {
      final start = DateTime.tryParse(calendarStartDate);
      if (start != null) {
        final calc = start.add(Duration(days: dayOffset - 1));
        return '${calc.year.toString().padLeft(4, '0')}-${calc.month.toString().padLeft(2, '0')}-${calc.day.toString().padLeft(2, '0')}';
      }
    }
    return '';
  }

  final str = rawDate.toString().trim();

  // If ISO 8601 or contains 'T' (e.g. 2026-09-15T10:00:00.000Z)
  if (str.contains('T')) {
    final datePart = str.split('T').first;
    return datePart;
  }
  if (str.contains(' ')) {
    final datePart = str.split(' ').first;
    if (datePart.contains('-')) return datePart;
  }

  // If epoch timestamp
  final epoch = int.tryParse(str);
  if (epoch != null && str.length >= 10) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      str.length == 10 ? epoch * 1000 : epoch,
    );
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // If YYYY/MM/DD or DD/MM/YYYY
  if (str.contains('/')) {
    final parts = str.split('/');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
      } else if (parts[2].length == 4) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    }
  }

  // Standard YYYY-MM-DD
  final dashParts = str.split('-');
  if (dashParts.length == 3) {
    if (dashParts[0].length == 4) {
      final y = dashParts[0];
      final m = dashParts[1].padLeft(2, '0');
      final d = dashParts[2].length > 2
          ? dashParts[2].substring(0, 2)
          : dashParts[2].padLeft(2, '0');
      return '$y-$m-$d';
    } else if (dashParts[2].length == 4) {
      final y = dashParts[2];
      final m = dashParts[1].padLeft(2, '0');
      final d = dashParts[0].padLeft(2, '0');
      return '$y-$m-$d';
    }
  }

  return str;
}

/// Normalizes time strings to human readable 12-hour format e.g. "10:00 AM"
String normalizeTimeString(dynamic rawTime) {
  if (rawTime == null || rawTime.toString().trim().isEmpty) {
    return '10:00 AM';
  }

  final str = rawTime.toString().trim();

  // If already contains AM or PM
  if (str.toUpperCase().contains('AM') || str.toUpperCase().contains('PM')) {
    return str;
  }

  // If ISO date string contains 'T', extract time
  if (str.contains('T')) {
    final timePart = str.split('T').last.replaceAll('Z', '');
    return normalizeTimeString(timePart);
  }

  // If 24-hour format HH:MM or HH:MM:SS
  final parts = str.split(':');
  if (parts.length >= 2) {
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].substring(0, 2));
    if (hour != null && minute != null) {
      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  return str;
}

/// Represents a single activity/event in the Marketing Calendar.
class MarketingCalendarActivity {
  final String id;
  final int day;
  final String date; // Always normalized YYYY-MM-DD
  final String time; // Always normalized e.g. "10:00 AM"
  final String? endTime;
  final String activity;
  final String platform;
  final String title;
  final String description;
  final String? product;
  final String? location;
  final String? attendee;
  final String? reminder;
  final String? recurrence; // e.g. 'daily', 'weekly', 'none'
  final String? rawStatus; // 'Upcoming', 'Today', 'Completed', 'Approved', etc.

  const MarketingCalendarActivity({
    required this.id,
    required this.day,
    required this.date,
    required this.time,
    this.endTime,
    required this.activity,
    required this.platform,
    required this.title,
    required this.description,
    this.product,
    this.location,
    this.attendee,
    this.reminder,
    this.recurrence,
    this.rawStatus,
  });

  factory MarketingCalendarActivity.fromJson(
    Map<String, dynamic> json, {
    String? calendarStartDate,
  }) {
    final rawDay = json['day'] is int
        ? json['day'] as int
        : int.tryParse(json['day']?.toString() ?? '1') ?? 1;

    final rawDate = json['date'] ??
        json['activityDate'] ??
        json['scheduledDate'] ??
        json['eventDate'] ??
        json['postDate'] ??
        json['dateTime'];

    final normalizedDate = normalizeDateString(
      rawDate,
      calendarStartDate: calendarStartDate,
      dayOffset: rawDay,
    );

    final rawTitle = json['title']?.toString() ??
        json['topic']?.toString() ??
        json['name']?.toString() ??
        json['headline']?.toString() ??
        'Marketing Activity';

    final rawDesc = json['description']?.toString() ??
        json['content']?.toString() ??
        json['notes']?.toString() ??
        json['caption']?.toString() ??
        '';

    final generatedId = json['_id']?.toString() ??
        json['id']?.toString() ??
        '$rawDay-${json['platform']}-$normalizedDate-${rawTitle.hashCode}';

    return MarketingCalendarActivity(
      id: generatedId,
      day: rawDay,
      date: normalizedDate,
      time: normalizeTimeString(json['time'] ?? json['startTime']),
      endTime: json['endTime'] != null ? normalizeTimeString(json['endTime']) : null,
      activity: json['activity']?.toString() ??
          json['type']?.toString() ??
          json['category']?.toString() ??
          'SOCIAL_POST',
      platform: json['platform']?.toString() ??
          json['channel']?.toString() ??
          'INSTAGRAM',
      title: sanitizeCloudPatra(rawTitle),
      description: sanitizeCloudPatra(rawDesc),
      product: json['product']?.toString() != null
          ? sanitizeCloudPatra(json['product']!.toString())
          : null,
      location: json['location']?.toString() ?? json['venue']?.toString(),
      attendee: json['attendee']?.toString() ??
          json['contact']?.toString() ??
          json['author']?.toString(),
      reminder: json['reminder']?.toString(),
      recurrence: json['recurrence']?.toString() ?? json['recurring']?.toString(),
      rawStatus: json['status']?.toString(),
    );
  }

  MarketingCalendarActivity copyWith({
    String? id,
    int? day,
    String? date,
    String? time,
    String? endTime,
    String? activity,
    String? platform,
    String? title,
    String? description,
    String? product,
    String? location,
    String? attendee,
    String? reminder,
    String? recurrence,
    String? rawStatus,
  }) {
    return MarketingCalendarActivity(
      id: id ?? this.id,
      day: day ?? this.day,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      activity: activity ?? this.activity,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      description: description ?? this.description,
      product: product ?? this.product,
      location: location ?? this.location,
      attendee: attendee ?? this.attendee,
      reminder: reminder ?? this.reminder,
      recurrence: recurrence ?? this.recurrence,
      rawStatus: rawStatus ?? this.rawStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'date': date,
      'time': time,
      if (endTime != null) 'endTime': endTime,
      'activity': activity,
      'platform': platform,
      'title': title,
      'description': description,
      if (product != null) 'product': product,
      if (location != null) 'location': location,
      if (attendee != null) 'attendee': attendee,
      if (reminder != null) 'reminder': reminder,
      if (recurrence != null) 'recurrence': recurrence,
      if (rawStatus != null) 'status': rawStatus,
    };
  }

  /// Parses date into a local [DateTime] using YYYY-MM-DD components directly.
  /// This prevents timezone day shifting (e.g. Sep 2 UTC becoming Sep 1 local).
  DateTime? get localDateTime {
    if (date.isEmpty) return null;
    final parts = date.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(date)?.toLocal();
  }

  /// Returns true if this activity's date is strictly before today (local date comparison).
  bool get isPastDate {
    if (date.isEmpty) return false;
    final now = DateTime.now();
    final todayStr = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
    ].join('-');
    return date.compareTo(todayStr) < 0;
  }

  /// Returns true if this activity is scheduled for today.
  bool get isToday {
    if (date.isEmpty) return false;
    final now = DateTime.now();
    final todayStr = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
    ].join('-');
    return date == todayStr;
  }

  /// Status string matching reference `getEventStatus(event)`:
  /// - 'Completed' if in the past
  /// - 'Today' if today
  /// - 'Upcoming' if in the future
  String get displayStatus {
    if (rawStatus != null && rawStatus!.isNotEmpty) {
      return rawStatus!;
    }
    if (isPastDate) return 'Completed';
    if (isToday) return 'Today';
    return 'Upcoming';
  }

  /// Formatted date e.g. "Sep 15, 2026"
  String get formattedDisplayDate {
    final dt = localDateTime;
    if (dt == null) return date;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthName = months[dt.month - 1];
    return '$monthName ${dt.day}, ${dt.year}';
  }

  /// Day number as two digits (e.g. "02", "15")
  String get dayString {
    final parts = date.split('-');
    if (parts.length == 3) {
      return parts[2].padLeft(2, '0');
    }
    return day.toString().padLeft(2, '0');
  }

  /// Month name uppercase (e.g. "SEP", "OCT")
  String get monthShortName {
    final dt = localDateTime;
    if (dt == null) return '';
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[dt.month - 1];
  }

  /// Platform display color matching reference app SCSS
  Color get platformColor {
    switch (platform.toUpperCase()) {
      case 'INSTAGRAM':
        return const Color(0xFFD4A438); // var(--mk-gold)
      case 'FACEBOOK':
        return const Color(0xFF5A9BD8); // var(--mk-blue)
      case 'YOUTUBE':
        return const Color(0xFFE5644E); // var(--mk-red)
      case 'LINKEDIN':
        return const Color(0xFF0A66C2);
      case 'GOOGLE_ADS':
        return const Color(0xFF4285F4);
      case 'META_ADS':
        return const Color(0xFF1877F2);
      default:
        return const Color(0xFF00897B); // Primary teal
    }
  }

  /// Platform icon data
  IconData get platformIcon {
    switch (platform.toUpperCase()) {
      case 'INSTAGRAM':
        return Icons.camera_alt_outlined;
      case 'FACEBOOK':
        return Icons.facebook;
      case 'LINKEDIN':
        return Icons.business_center_outlined;
      case 'YOUTUBE':
        return Icons.play_circle_fill_rounded;
      case 'GOOGLE_ADS':
        return Icons.ads_click_rounded;
      case 'META_ADS':
        return Icons.campaign_rounded;
      default:
        return Icons.language_rounded;
    }
  }

  /// Activity type icon
  IconData get activityIcon {
    switch (activity.toUpperCase()) {
      case 'SOCIAL_POST':
        return Icons.article_outlined;
      case 'REEL':
      case 'VIDEO':
        return Icons.videocam_outlined;
      case 'STORY':
        return Icons.auto_stories_outlined;
      case 'CAROUSEL':
        return Icons.collections_outlined;
      case 'BLOG':
        return Icons.edit_note_outlined;
      case 'OFFER':
        return Icons.local_offer_outlined;
      case 'PRODUCT_PROMOTION':
        return Icons.shopping_bag_outlined;
      case 'TESTIMONIAL':
        return Icons.format_quote_rounded;
      case 'EDUCATIONAL':
        return Icons.school_outlined;
      case 'FESTIVAL':
        return Icons.celebration_outlined;
      case 'CUSTOMER_ENGAGEMENT':
        return Icons.groups_outlined;
      case 'LEAD_GENERATION':
        return Icons.person_add_alt_1_outlined;
      case 'BRAND_AWARENESS':
      case 'ADVERTISEMENT':
        return Icons.campaign_outlined;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// Marketing Calendar containing metadata and activities list.
class MarketingCalendar {
  final String id;
  final String userId;
  final String startDate;
  final String endDate;
  final int durationDays;
  final List<MarketingCalendarActivity> calendar;
  final String? createdAt;
  final String? updatedAt;

  const MarketingCalendar({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.calendar,
    this.createdAt,
    this.updatedAt,
  });

  factory MarketingCalendar.fromJson(Map<String, dynamic> json) {
    final start = json['startDate']?.toString() ?? '';
    var list = <MarketingCalendarActivity>[];

    if (json['calendar'] is List) {
      list = (json['calendar'] as List)
          .map((item) => MarketingCalendarActivity.fromJson(
                Map<String, dynamic>.from(item as Map),
                calendarStartDate: start,
              ))
          .toList();
    } else if (json['activities'] is List) {
      list = (json['activities'] as List)
          .map((item) => MarketingCalendarActivity.fromJson(
                Map<String, dynamic>.from(item as Map),
                calendarStartDate: start,
              ))
          .toList();
    }

    return MarketingCalendar(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      startDate: start,
      endDate: json['endDate']?.toString() ?? '',
      durationDays: json['durationDays'] is int
          ? json['durationDays'] as int
          : int.tryParse(json['durationDays']?.toString() ?? '30') ?? 30,
      calendar: list,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  factory MarketingCalendar.fromActivityList(
    List<MarketingCalendarActivity> activities, {
    String? userId,
    String? startDate,
  }) {
    return MarketingCalendar(
      id: 'calendar-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? '',
      startDate: startDate ??
          (activities.isNotEmpty ? activities.first.date : ''),
      endDate: activities.isNotEmpty ? activities.last.date : '',
      durationDays: activities.length,
      calendar: activities,
    );
  }
}

/// Response envelope for Marketing Calendar API calls.
class MarketingCalendarResponse {
  final bool success;
  final String message;
  final MarketingCalendar? data;

  const MarketingCalendarResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MarketingCalendarResponse.fromJson(dynamic json) {
    if (json is List) {
      final activities = json
          .map((item) => MarketingCalendarActivity.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList();
      return MarketingCalendarResponse(
        success: true,
        message: 'Loaded successfully',
        data: MarketingCalendar.fromActivityList(activities),
      );
    }

    if (json is Map<String, dynamic>) {
      MarketingCalendar? calendarData;

      if (json['data'] is Map) {
        calendarData = MarketingCalendar.fromJson(
          Map<String, dynamic>.from(json['data'] as Map),
        );
      } else if (json['data'] is List) {
        final activities = (json['data'] as List)
            .map((item) => MarketingCalendarActivity.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
        calendarData = MarketingCalendar.fromActivityList(activities);
      } else if (json['calendar'] is List) {
        calendarData = MarketingCalendar.fromJson(json);
      }

      return MarketingCalendarResponse(
        success: json['success'] != false,
        message: json['message']?.toString() ?? '',
        data: calendarData,
      );
    }

    return const MarketingCalendarResponse(
      success: false,
      message: 'Unrecognized response format',
      data: null,
    );
  }
}
