import 'dart:convert';
import '../../api.dart';

class ApplicationAPI {
  static final ApiClient _api = ApiClient();

  // 1. POST /applications/applyForMembership
  static Future<Map<String, dynamic>?> applyForMembership({
    required String guestId,
    required String businessCategory,
    required String businessSubCategory,
    required String businessTag,
    String remarks = '',
  }) async {
    final Map<String, dynamic> body = {
      "guestId": guestId,
      "businessCategory": businessCategory,
      "businessSubCategory": businessSubCategory,
      "businessTag": businessTag,
      "remarks": remarks,
    };

    final response = await _api.post('/applications/applyForMembership', body);
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response as Map<String, dynamic>?;
  }

  // 2. GET /applications/getAllApplications
  static Future<Map<String, dynamic>?> getAllApplications() async {
    final response = await _api.get('/applications/getAllApplications');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response as Map<String, dynamic>?;
  }

  // 3. GET /applications/getMembershipApplicationById/{applicationId}
  static Future<Map<String, dynamic>?> getApplicationById(String applicationId) async {
    final response = await _api.get('/applications/getMembershipApplicationById/$applicationId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response as Map<String, dynamic>?;
  }

  // 4. GET /applications/getApplicationByGuestId/{guestId}
  static Future<Map<String, dynamic>?> getApplicationByGuestId(String guestId) async {
    final response = await _api.get('/applications/getApplicationByGuestId/$guestId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response as Map<String, dynamic>?;
  }

  // 5. PATCH /applications/reviewMEmbershipApplication
  static Future<Map<String, dynamic>?> reviewApplication({
    required String applicationId,
    required String status,
    required String remarks,
    required String reviewedBy,
  }) async {
    final Map<String, dynamic> body = {
      "applicationId": applicationId,
      "status": status,
      "remarks": remarks,
      "reviewedBy": reviewedBy,
    };

    final response = await _api.patch('/applications/reviewMEmbershipApplication', body);
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response as Map<String, dynamic>?;
  }

  // 6. GET /applications/statistics
  static Future<Map<String, dynamic>?> getStatistics() async {
    final response = await _api.get('/applications/statistics');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response as Map<String, dynamic>?;
  }
}
