import '../api.dart';

class CommunicationsAdminAPI {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getAllCampaigns({String adminStatus = 'All', int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get('/bulk-campagin/getAllCampaigns?adminStatus=$adminStatus&page=$page&limit=$limit');
      if (response != null && response['success'] != false) {
        return response as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load campaigns: $response');
      }
    } catch (e) {
      print('API Error (getAllCampaigns): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllUploadedCsvData({String status = 'All', int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get('/bulk-campagin/getAllUploadedCsvData?status=$status&page=$page&limit=$limit');
      if (response != null && response['success'] != false) {
        return response as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load CSV data: $response');
      }
    } catch (e) {
      print('API Error (getAllUploadedCsvData): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reviewMemberCampaign(String campaignId, String adminUserId, String status, String remark) async {
    final payload = {
      'campaignId': campaignId,
      'adminUserId': adminUserId,
      'status': status,
      'remark': remark,
    };
    try {
      final response = await _api.patch('/bulk-campagin/reviewMemberCampagin', payload);
      if (response != null && response['success'] != false) {
        return response as Map<String, dynamic>;
      } else {
        throw Exception('Failed to review campaign: $response');
      }
    } catch (e) {
      print('API Error (reviewMemberCampaign): $e');
      rethrow;
    }
  }
}
