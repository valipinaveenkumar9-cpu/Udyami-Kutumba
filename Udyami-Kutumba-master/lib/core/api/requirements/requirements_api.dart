import 'package:flutter/foundation.dart';
import '../api.dart';

class RequirementsAPI {
  static final ApiClient _api = ApiClient();

  /// POST /requirements/createRequirements
  static Future<Map<String, dynamic>> createRequirement({
    required String userId,
    required String requirement,
    required String category,
    required String source,
    String status = 'Pending',
  }) async {
    try {
      final payload = {
        'userId': userId,
        'requirement': requirement,
        'category': category,
        'source': source,
        'status': status,
      };

      final response = await _api.post('/requirements/createRequirements', payload);

      if (response != null && response['success'] != false) {
        return {'success': true, 'data': response['data']};
      } else {
        return {
          'success': false,
          'message': response != null ? response['message'] : 'Failed to create requirement.',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEV DEBUG - error - requirements_api.dart - Exception: $e');
      }
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST /requirements/getMyRequirements
  static Future<Map<String, dynamic>> getMyRequirements(String userId) async {
    try {
      final payload = {'userId': userId};
      
      final response = await _api.post('/requirements/getMyRequirements', payload);

      if (response != null && response['success'] != false) {
        return {'success': true, 'data': response['data']};
      }
      return {'success': false, 'message': response != null ? response['message'] : 'Failed to fetch requirements.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST /requirements/getB2CRequirements
  static Future<Map<String, dynamic>> getB2CRequirements(String wardId, String category) async {
    try {
      final payload = {'wardId': wardId, 'category': category};
      
      final response = await _api.post('/requirements/getB2CRequirements', payload);

      if (response != null && response['success'] != false) {
        return {'success': true, 'data': response['data']};
      }
      return {'success': false, 'message': response != null ? response['message'] : 'Failed to fetch B2C requirements.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST /requirements/getB2BRequirements
  static Future<Map<String, dynamic>> getB2BRequirements(String talukaId, String category) async {
    try {
      final payload = {'talukaId': talukaId, 'category': category};
      
      final response = await _api.post('/requirements/getB2BRequirements', payload);

      if (response != null && response['success'] != false) {
        return {'success': true, 'data': response['data']};
      }
      return {'success': false, 'message': response != null ? response['message'] : 'Failed to fetch B2B requirements.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// PATCH /requirements/updateStatus/{requirementId}
  static Future<Map<String, dynamic>> updateStatus(String requirementId, String userId, String status) async {
    try {
      final payload = {'userId': userId, 'status': status};
      
      final response = await _api.patch('/requirements/updateStatus/$requirementId', payload);

      if (response != null && response['success'] != false) {
        return {'success': true, 'data': response['data']};
      }
      return {'success': false, 'message': response != null ? response['message'] : 'Failed to update status.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// PATCH /requirements/updateRequirements/{requirementId}
  static Future<Map<String, dynamic>> updateRequirement(String requirementId, String userId, String requirement, String category, String source) async {
    try {
      final payload = {
        'userId': userId,
        'requirement': requirement,
        'category': category,
        'source': source
      };
      
      final response = await _api.patch('/requirements/updateRequirements/$requirementId', payload);

      if (response != null && response['success'] != false) {
        return {'success': true, 'data': response['data']};
      }
      return {'success': false, 'message': response != null ? response['message'] : 'Failed to update requirement.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// DELETE /requirements/delete/{requirementId}
  static Future<Map<String, dynamic>> deleteRequirement(String requirementId, String userId) async {
    try {
      final response = await _api.delete('/requirements/delete/$requirementId?userId=$userId');

      if (response != null && response['success'] != false) {
        return {'success': true, 'message': response['message'] ?? 'Requirement deleted.'};
      }
      return {'success': false, 'message': response != null ? response['message'] : 'Failed to delete requirement.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
