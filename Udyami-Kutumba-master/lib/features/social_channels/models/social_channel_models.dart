import 'package:flutter/material.dart';

/// Represents a connected social media account from MarketOS backend:
/// GET /setting/getUserSocialAccountDetails/{userId}
class SocialMediaAccount {
  final String platform;
  final bool connected;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  SocialMediaAccount({
    required this.platform,
    required this.connected,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SocialMediaAccount.fromJson(Map<String, dynamic> json) {
    return SocialMediaAccount(
      platform: (json['platform'] ?? '').toString(),
      connected: json['connected'] == true,
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'connected': connected,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// Helper model for the standard MarketOS channel connection definitions
class ChannelConnectionItem {
  final String name;
  final String detail;
  final String platformKey;
  final IconData icon;
  final Color color;
  bool connected;
  bool isConnecting;

  ChannelConnectionItem({
    required this.name,
    required this.detail,
    required this.platformKey,
    required this.icon,
    required this.color,
    this.connected = false,
    this.isConnecting = false,
  });

  ChannelConnectionItem copyWith({
    String? name,
    String? detail,
    String? platformKey,
    IconData? icon,
    Color? color,
    bool? connected,
    bool? isConnecting,
  }) {
    return ChannelConnectionItem(
      name: name ?? this.name,
      detail: detail ?? this.detail,
      platformKey: platformKey ?? this.platformKey,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      connected: connected ?? this.connected,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }

  /// Default predefined list of supported channels matching MarketOS Customer specs
  static List<ChannelConnectionItem> defaultConnections() {
    return [
      ChannelConnectionItem(
        name: 'Facebook Page',
        detail: 'Connect business page for feed & reels',
        platformKey: 'FACEBOOK',
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
        connected: false,
      ),
      ChannelConnectionItem(
        name: 'Instagram Business',
        detail: 'Automate grid posts, carousels & stories',
        platformKey: 'INSTAGRAM',
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFFE1306C),
        connected: false,
      ),
      ChannelConnectionItem(
        name: 'Meta Ads account',
        detail: 'Manage sponsored campaigns & conversion sync',
        platformKey: 'META_ADS',
        icon: Icons.campaign_rounded,
        color: const Color(0xFF0081FB),
        connected: false,
      ),
      ChannelConnectionItem(
        name: 'Google Ads',
        detail: 'Search intent & display lead generation',
        platformKey: 'GOOGLE_ADS',
        icon: Icons.ads_click_rounded,
        color: const Color(0xFF4285F4),
        connected: false,
      ),
      ChannelConnectionItem(
        name: 'Google Analytics 4',
        detail: 'Web traffic and attribution pipeline',
        platformKey: 'GOOGLE_ANALYTICS',
        icon: Icons.analytics_outlined,
        color: const Color(0xFFEA4335),
        connected: false,
      ),
      ChannelConnectionItem(
        name: 'LinkedIn Page',
        detail: 'B2B executive presence & professional reach',
        platformKey: 'LINKEDIN',
        icon: Icons.business_center_rounded,
        color: const Color(0xFF0A66C2),
        connected: false,
      ),
      ChannelConnectionItem(
        name: 'Your ERP / CRM',
        detail: 'Webhook active · lead stages flowing',
        platformKey: 'ERP',
        icon: Icons.hub_rounded,
        color: const Color(0xFF00897B),
        connected: false,
      ),
    ];
  }
}

/// Represents generated and published marketing content from MarketOS:
/// GET /create-content/getGeneratedContent/{userId}
class GeneratedContentItem {
  final String id;
  final String? userId;
  final String? platform;
  final String? contentType;
  final String? productName;
  final String? generatedContent;
  final String? mediaType;
  final String? mediaUrl;
  final String? status;
  final String? publishedAt;
  final String? publishedUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? calendarId;
  final String? activityType;
  final Map<String, dynamic>? aiResponse;

  GeneratedContentItem({
    required this.id,
    this.userId,
    this.platform,
    this.contentType,
    this.productName,
    this.generatedContent,
    this.mediaType,
    this.mediaUrl,
    this.status,
    this.publishedAt,
    this.publishedUrl,
    this.createdAt,
    this.updatedAt,
    this.calendarId,
    this.activityType,
    this.aiResponse,
  });

  factory GeneratedContentItem.fromJson(Map<String, dynamic> json) {
    return GeneratedContentItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: json['userId']?.toString(),
      platform: json['platform']?.toString(),
      contentType: json['contentType']?.toString(),
      productName: json['productName']?.toString(),
      generatedContent: json['generatedContent']?.toString(),
      mediaType: json['mediaType']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      status: json['status']?.toString(),
      publishedAt: json['publishedAt']?.toString(),
      publishedUrl: json['publishedUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      calendarId: json['calendarId']?.toString(),
      activityType: json['activityType']?.toString(),
      aiResponse: json['aiResponse'] is Map ? Map<String, dynamic>.from(json['aiResponse']) : null,
    );
  }

  bool get isPublished {
    final s = (status ?? '').toUpperCase();
    return s == 'PUBLISHED' || (publishedAt != null && publishedAt!.isNotEmpty);
  }

  bool get isApproved {
    final s = (status ?? '').toUpperCase();
    return s == 'APPROVED';
  }

  bool get isRejected {
    final s = (status ?? '').toUpperCase();
    return s == 'REJECTED' || s == 'FAILED';
  }

  bool get isWaitingApproval {
    final s = (status ?? '').toUpperCase();
    return s == 'READY_FOR_APPROVAL' ||
        s == 'GENERATED' ||
        s == 'PENDING' ||
        s == 'PROCESSING' ||
        (!isPublished && !isApproved && !isRejected);
  }

  bool get isVideo {
    final m = (mediaType ?? '').toLowerCase();
    return m.startsWith('video') || m == 'reel';
  }

  String get platformKey {
    final p = (platform ?? '').toLowerCase();
    if (p.contains('instagram')) return 'instagram';
    if (p.contains('meta') || p.contains('facebook')) return 'meta';
    if (p.contains('google')) return 'google';
    if (p.contains('linkedin')) return 'linkedin';
    return 'other';
  }

  String get platformLabel {
    return switch (platformKey) {
      'instagram' => 'Instagram',
      'meta' => 'Meta Ads',
      'google' => 'Google Ads',
      'linkedin' => 'LinkedIn',
      _ => platform ?? 'Other Channel',
    };
  }

  IconData get platformIcon {
    return switch (platformKey) {
      'instagram' => Icons.camera_alt_outlined,
      'meta' => Icons.facebook,
      'google' => Icons.ads_click_rounded,
      'linkedin' => Icons.business_center_rounded,
      _ => Icons.share_rounded,
    };
  }

  Color get platformColor {
    return switch (platformKey) {
      'instagram' => const Color(0xFFE1306C),
      'meta' => const Color(0xFF1877F2),
      'google' => const Color(0xFF4285F4),
      'linkedin' => const Color(0xFF0A66C2),
      _ => Colors.teal,
    };
  }

  IconData get contentTypeIcon {
    return switch ((contentType ?? '').toUpperCase()) {
      'IMAGE' => Icons.image_outlined,
      'VIDEO' => Icons.videocam_outlined,
      'REEL' => Icons.movie_filter_outlined,
      'STORY' => Icons.amp_stories_outlined,
      'CAROUSEL' => Icons.view_carousel_outlined,
      'TEXT' => Icons.article_outlined,
      _ => Icons.description_outlined,
    };
  }

  String get displayHeadline {
    if (productName != null && productName!.isNotEmpty) {
      return productName!;
    }
    final marketing = aiResponse?['marketingContent'];
    if (marketing is Map && marketing['headline'] != null && marketing['headline'].toString().isNotEmpty) {
      return marketing['headline'].toString();
    }
    return generatedContent != null && generatedContent!.length > 40
        ? '${generatedContent!.substring(0, 40)}...'
        : (generatedContent ?? 'Marketing Content');
  }

  String get displayCaption {
    final marketing = aiResponse?['marketingContent'];
    if (marketing is Map && marketing['caption'] != null && marketing['caption'].toString().isNotEmpty) {
      return marketing['caption'].toString();
    }
    return generatedContent ?? '';
  }

  String get displayDescription {
    final marketing = aiResponse?['marketingContent'];
    if (marketing is Map && marketing['description'] != null) {
      return marketing['description'].toString();
    }
    return '';
  }

  String get displayCallToAction {
    final marketing = aiResponse?['marketingContent'];
    if (marketing is Map && marketing['callToAction'] != null) {
      return marketing['callToAction'].toString();
    }
    return '';
  }

  List<String> get displayHashtags {
    final marketing = aiResponse?['marketingContent'];
    if (marketing is Map && marketing['hashtags'] is List) {
      return (marketing['hashtags'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  String get activityTitle {
    return aiResponse?['activity']?['title']?.toString() ?? '';
  }

  String get activityDescription {
    return aiResponse?['activity']?['description']?.toString() ?? '';
  }

  String get activityDate {
    return aiResponse?['activity']?['date']?.toString() ?? '';
  }

  String get activityTime {
    return aiResponse?['activity']?['time']?.toString() ?? '';
  }

  String get activityPlatform {
    return aiResponse?['activity']?['platform']?.toString() ?? '';
  }
}

/// Platform distribution counters
class PlatformDistributionMetrics {
  final int instagram;
  final int meta;
  final int google;
  final int linkedin;
  final int other;

  PlatformDistributionMetrics({
    this.instagram = 0,
    this.meta = 0,
    this.google = 0,
    this.linkedin = 0,
    this.other = 0,
  });

  factory PlatformDistributionMetrics.fromContents(List<GeneratedContentItem> contents) {
    int ig = 0, fb = 0, goog = 0, li = 0, oth = 0;
    for (final c in contents) {
      switch (c.platformKey) {
        case 'instagram':
          ig++;
          break;
        case 'meta':
          fb++;
          break;
        case 'google':
          goog++;
          break;
        case 'linkedin':
          li++;
          break;
        default:
          oth++;
          break;
      }
    }
    return PlatformDistributionMetrics(
      instagram: ig,
      meta: fb,
      google: goog,
      linkedin: li,
      other: oth,
    );
  }
}
