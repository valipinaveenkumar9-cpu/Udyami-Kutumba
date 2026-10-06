import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/social_channel_models.dart';

class SocialChannelApi {
  final ApiClient _api = ApiClient();

  /// Retrieve current user ID from session
  String? get currentUserId {
    final user = SessionManager.user;
    return user?['userId']?.toString() ??
        user?['id']?.toString() ??
        user?['_id']?.toString();
  }

  /// Get connected social media accounts for the current user:
  /// GET /setting/getUserSocialAccountDetails/{userId}
  Future<List<SocialMediaAccount>> getUserSocialMediaAccounts() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      debugPrint('SocialChannelApi: No logged-in userId');
      return [];
    }

    try {
      final endpoint = '/setting/getUserSocialAccountDetails/$userId';
      final response = await _api.get(endpoint);

      if (response is List) {
        return response
            .map((item) => SocialMediaAccount.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => SocialMediaAccount.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map && response['success'] == false) {
        debugPrint('SocialChannelApi: API returned error: ${response['message']}');
        return [];
      }

      return [];
    } catch (e) {
      debugPrint('SocialChannelApi.getUserSocialMediaAccounts error: $e');
      return [];
    }
  }

  /// Connect a social media account:
  /// POST /setting/addSocialMediaAccounts
  Future<Map<String, dynamic>> connectSocialMediaAccount({
    required String platform,
    required String username,
    required String password,
  }) async {
    final userId = currentUserId ?? '';

    final payload = {
      'userId': userId,
      'platform': platform.toUpperCase(),
      'username': username.trim(),
      'password': password,
    };

    try {
      final response = await _api.post(
        '/setting/addSocialMediaAccounts',
        payload,
      );

      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'success': true, 'data': response};
    } catch (e) {
      debugPrint('SocialChannelApi.connectSocialMediaAccount error: $e');
      return {
        'success': false,
        'message': 'Unable to connect $platform right now. Please try again.',
      };
    }
  }

  /// Fetch all generated marketing contents / campaigns:
  /// GET /create-content/getGeneratedContent/{userId}
  Future<List<GeneratedContentItem>> getAllGeneratedContent() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return [];
    }

    try {
      final endpoint = '/create-content/getGeneratedContent/$userId';
      final response = await _api.get(endpoint);

      List<dynamic> items = [];
      if (response is List) {
        items = response;
      } else if (response is Map && response['data'] is List) {
        items = response['data'] as List;
      } else if (response is Map && response['success'] == false) {
        return [];
      }

      return items
          .map((json) => GeneratedContentItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('SocialChannelApi.getAllGeneratedContent error: $e');
      return [];
    }
  }

  /// Fetch published campaigns:
  /// GET /create-content/getGeneratedContent/{userId} (filtered by published)
  Future<List<GeneratedContentItem>> getPublishedContent() async {
    final all = await getAllGeneratedContent();
    return all.where((c) => c.isPublished).toList();
  }

  /// Fetch content items waiting for approval / reviews:
  /// GET /create-content/getGeneratedContent/{userId} (filtered by awaiting approval)
  Future<List<GeneratedContentItem>> getPendingApprovals() async {
    final all = await getAllGeneratedContent();
    return all.where((c) => c.isWaitingApproval).toList();
  }

  /// Approve & Publish content to social channels:
  /// POST /create-content/publishContent
  Future<Map<String, dynamic>> publishContent(GeneratedContentItem content) async {
    final userId = currentUserId ?? '';
    final mediaTypeValue = (content.mediaType ?? '').toLowerCase();
    final mediaType = mediaTypeValue.startsWith('video') || mediaTypeValue == 'reel' ? 'video' : 'image';
    final channel = (content.platform ?? 'instagram').split(RegExp(r'[·|/-]'))[0].trim().toLowerCase();

    final caption = content.displayCaption;
    final hashtags = content.displayHashtags.join(' ');
    final fullCaption = [caption, hashtags].where((s) => s.isNotEmpty).join('\n\n');

    final payload = {
      'userId': userId,
      'generatedContentId': content.id,
      'channel': channel,
      'media_type': mediaType,
      'format': mediaType == 'video' ? 'reel' : 'feed',
      'media': [
        {'url': content.mediaUrl ?? ''}
      ],
      'caption': fullCaption,
    };

    try {
      final response = await _api.post('/create-content/publishContent', payload);
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'success': true, 'data': response};
    } catch (e) {
      debugPrint('SocialChannelApi.publishContent error: $e');
      return {
        'success': false,
        'message': 'Failed to publish content. Please try again.',
      };
    }
  }

  /// Regenerate content with additional user requirement:
  /// POST /create-content/regenerateContent/{contentId}
  Future<Map<String, dynamic>> regenerateContent({
    required String contentId,
    required String requirement,
  }) async {
    try {
      final response = await _api.post(
        '/create-content/regenerateContent/$contentId',
        {'requirement': requirement},
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'success': true, 'data': response};
    } catch (e) {
      debugPrint('SocialChannelApi.regenerateContent error: $e');
      return {
        'success': false,
        'message': 'Failed to regenerate content. Please try again.',
      };
    }
  }

  /// Reject content:
  /// PATCH /create-content/rejectContent/{contentId}
  Future<Map<String, dynamic>> rejectContent(String contentId) async {
    try {
      final response = await _api.patch(
        '/create-content/rejectContent/$contentId',
        {},
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'success': true, 'data': response};
    } catch (e) {
      debugPrint('SocialChannelApi.rejectContent error: $e');
      return {
        'success': false,
        'message': 'Failed to reject content. Please try again.',
      };
    }
  }

  /// Download Report:
  /// POST /create-content/download-report
  Future<Uint8List?> downloadReport(String html) async {
    try {
      final response = await _api.postRaw('/create-content/download-report', {'html': html});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      debugPrint('SocialChannelApi.downloadReport failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('SocialChannelApi.downloadReport error: $e');
      return null;
    }
  }

}
