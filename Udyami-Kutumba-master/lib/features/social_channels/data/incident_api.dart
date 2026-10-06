import 'package:flutter/foundation.dart';
import '../../../core/api/api.dart';
import '../../../core/utils/session_manager.dart';
import '../models/incident_model.dart';

class IncidentApi {
  final ApiClient _api = ApiClient();

  /// Logged-in user's ID
  String? get currentUserId {
    final user = SessionManager.user;
    return user?['userId']?.toString() ??
        user?['id']?.toString() ??
        user?['_id']?.toString();
  }

  /// Get user's incidents:
  /// GET /incidents/getIncidentsByUserId/{userId}
  Future<List<Incident>> getUserIncidents() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      debugPrint('IncidentApi: No user logged in, returning seed incidents');
      return _mockIncidents();
    }

    try {
      final endpoint = '/incidents/getIncidentsByUserId/$userId';
      final response = await _api.get(endpoint);

      List<dynamic> list = [];
      if (response is List) {
        list = response;
      } else if (response is Map && response['data'] is List) {
        list = response['data'] as List;
      } else if (response is Map && response['incidents'] is List) {
        list = response['incidents'] as List;
      }

      if (list.isEmpty) {
        return _mockIncidents();
      }

      return list
          .map((item) => Incident.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('IncidentApi.getUserIncidents error: $e');
      return _mockIncidents();
    }
  }

  /// Create new incident:
  /// POST /incidents/createIncidents
  Future<Incident?> createIncident(CreateIncidentPayload payload) async {
    final userId = currentUserId ?? 'user_123';
    final requestBody = payload.toJson(userId);

    try {
      final response = await _api.post(
        '/incidents/createIncidents',
        requestBody,
      );

      if (response is Map<String, dynamic>) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        return Incident.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('IncidentApi.createIncident error: $e');
      // If server unreachable, create local instance for immediate feedback
      return Incident(
        id: 'inc-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        generatedContentId: payload.generatedContentId,
        calendarId: payload.calendarId,
        activityType: payload.activityType,
        incidentType: payload.incidentType,
        severity: IncidentSeverity.fromString(payload.severity),
        title: payload.title,
        message: payload.message,
        errorMessage: payload.errorMessage,
        status: IncidentStatus.open,
        resolved: false,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
  }

  /// Seed fallback incidents matching reference data for rich testing
  List<Incident> _mockIncidents() {
    return [
      Incident(
        id: 'inc-1',
        userId: currentUserId ?? 'user_1',
        activityType: 'SOCIAL_POST',
        incidentType: 'IMAGE_GENERATION_FAILED',
        severity: IncidentSeverity.high,
        title: 'CNC Floor reel image generation timeout',
        message:
            'The AI image generation pipeline timed out after 60s while generating shop-floor visual variations.',
        errorMessage: 'GATEWAY_TIMEOUT: Upstream StableDiffusion model took >60s',
        status: IncidentStatus.open,
        resolved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      ),
      Incident(
        id: 'inc-2',
        userId: currentUserId ?? 'user_1',
        activityType: 'CAMPAIGN',
        incidentType: 'AI_API_ERROR',
        severity: IncidentSeverity.medium,
        title: 'Meta ad spend cap verification sync warning',
        message:
            'Ad set budget sync reported a temporary rate-limit response from Meta Graph API.',
        errorMessage: 'OAuthException: (#17) User request limit reached',
        status: IncidentStatus.resolved,
        resolved: true,
        resolvedAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      Incident(
        id: 'inc-3',
        userId: currentUserId ?? 'user_1',
        activityType: 'REEL',
        incidentType: 'TOKEN_LIMIT',
        severity: IncidentSeverity.low,
        title: 'Prompt token budget exceeded in Kannada dialect transliteration',
        message:
            'Transliteration prompt exceeded 2048 tokens; prompt automatically truncated.',
        errorMessage: null,
        status: IncidentStatus.resolved,
        resolved: true,
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
    ];
  }
}
