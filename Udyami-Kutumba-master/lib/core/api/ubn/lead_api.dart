import 'package:flutter/foundation.dart';
import '../../models/lead_model.dart';
import '../api.dart';

class LeadAPI {
  static final ApiClient _api = ApiClient();

  /// POST /bni-lead/createLead
  static Future<bool> createLead(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/bni-lead/createLead', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception creating lead: $e");
      return false;
    }
  }

  /// POST /bni-lead/getLeadsByid
  static Future<List<LeadModel>> getLeadsById(String userId) async {
    try {
      final payload = {"createdUserId": userId};
      final response = await _api.post('/bni-lead/getLeadsByid', payload);

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => LeadModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching leads: $e");
      return [];
    }
  }

  /// GET /bni-lead/getAllLeads
  static Future<List<LeadModel>> getAllLeads() async {
    try {
      final response = await _api.get('/bni-lead/getAllLeads');

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => LeadModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching all leads: $e");
      return [];
    }
  }

  /// PATCH /bni-lead/{leadId}/status
  static Future<bool> updateLeadStatus(String leadId, String status, String userId) async {
    try {
      final payload = {
        "status": status,
        "userId": userId,
      };

      final response = await _api.patch('/bni-lead/$leadId/status', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception updating lead status: $e");
      return false;
    }
  }

  /// POST /bni-lead/completed-by-user
  static Future<Map<String, dynamic>> getCompletedLeadsByUser(String userId) async {
    try {
      final payload = {"createdUserId": userId};
      final response = await _api.post('/bni-lead/completed-by-user', payload);

      if (response is Map && response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final leadsList = (data['leads'] as List?)?.map((x) => LeadModel.fromJson(x)).toList() ?? [];
        return {
          'leads': leadsList,
          'totalGratitudeSlips': response['totalGratitudeSlips'] ?? 0,
          'totalGratitudeAmount': response['totalGratitudeAmount'] ?? 0,
        };
      }
      return {'leads': <LeadModel>[], 'totalGratitudeSlips': 0, 'totalGratitudeAmount': 0};
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching completed leads: $e");
      return {'leads': <LeadModel>[], 'totalGratitudeSlips': 0, 'totalGratitudeAmount': 0};
    }
  }

  /// POST /bni-lead/converted-by-user
  static Future<List<LeadModel>> getConvertedLeadsByUser(String userId) async {
    try {
      final payload = {"createdUserId": userId};
      final response = await _api.post('/bni-lead/converted-by-user', payload);

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => LeadModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching converted leads: $e");
      return [];
    }
  }

  /// GET /bni-lead/free-member-leads
  static Future<List<LeadModel>> getFreeMemberLeads() async {
    try {
      final response = await _api.get('/bni-lead/free-member-leads');

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => LeadModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching free member leads: $e");
      return [];
    }
  }

  /// GET /bni-lead/paid-member-leads
  static Future<List<LeadModel>> getPaidMemberLeads() async {
    try {
      final response = await _api.get('/bni-lead/paid-member-leads');

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => LeadModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching paid member leads: $e");
      return [];
    }
  }
  /// GET /bni-lead/matched/{userId}
  static Future<List<LeadModel>> getMatchedLeads(String userId) async {
    try {
      final response = await _api.get('/bni-lead/matched/$userId');

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) {
          if (x is Map && x.containsKey('lead')) {
             return LeadModel.fromJson(x['lead']);
          }
          return LeadModel.fromJson(x); // Fallback
        }).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - error - lead_api.dart - Exception fetching matched leads: $e");
      return [];
    }
  }
}
