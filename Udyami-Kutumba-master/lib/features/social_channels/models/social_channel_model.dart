import 'package:flutter/material.dart';

enum SocialPlatform {
  whatsApp,
  telegram,
  youtube,
  instagram,
  linkedIn,
  facebook,
  twitter,
  website,
}

extension SocialPlatformExtension on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.whatsApp:
        return 'WhatsApp';
      case SocialPlatform.telegram:
        return 'Telegram';
      case SocialPlatform.youtube:
        return 'YouTube';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.linkedIn:
        return 'LinkedIn';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.twitter:
        return 'X (Twitter)';
      case SocialPlatform.website:
        return 'Website';
    }
  }

  Color get brandColor {
    switch (this) {
      case SocialPlatform.whatsApp:
        return const Color(0xFF25D366);
      case SocialPlatform.telegram:
        return const Color(0xFF0088CC);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.instagram:
        return const Color(0xFFE1306C);
      case SocialPlatform.linkedIn:
        return const Color(0xFF0A66C2);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.twitter:
        return const Color(0xFF111111);
      case SocialPlatform.website:
        return const Color(0xFF02A092);
    }
  }

  IconData get icon {
    switch (this) {
      case SocialPlatform.whatsApp:
        return Icons.chat_bubble_rounded;
      case SocialPlatform.telegram:
        return Icons.send_rounded;
      case SocialPlatform.youtube:
        return Icons.play_circle_filled_rounded;
      case SocialPlatform.instagram:
        return Icons.camera_alt_rounded;
      case SocialPlatform.linkedIn:
        return Icons.business_center_rounded;
      case SocialPlatform.facebook:
        return Icons.facebook_rounded;
      case SocialPlatform.twitter:
        return Icons.tag_rounded;
      case SocialPlatform.website:
        return Icons.language_rounded;
    }
  }
}

class SocialChannel {
  final String id;
  final String title;
  final String description;
  final SocialPlatform platform;
  final String category;
  final String url;
  final String memberCount;
  final bool isOfficial;
  final bool isFeatured;
  final List<String> tags;

  const SocialChannel({
    required this.id,
    required this.title,
    required this.description,
    required this.platform,
    required this.category,
    required this.url,
    required this.memberCount,
    this.isOfficial = true,
    this.isFeatured = false,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'platform': platform.name,
      'category': category,
      'url': url,
      'memberCount': memberCount,
      'isOfficial': isOfficial,
      'isFeatured': isFeatured,
      'tags': tags,
    };
  }

  factory SocialChannel.fromJson(Map<String, dynamic> json) {
    return SocialChannel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      platform: SocialPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => SocialPlatform.website,
      ),
      category: json['category'] as String,
      url: json['url'] as String,
      memberCount: json['memberCount'] as String,
      isOfficial: json['isOfficial'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
