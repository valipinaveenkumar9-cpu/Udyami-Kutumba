import '../api.dart';
import 'package:http/http.dart' as http;

class CommunicationsAPI extends ApiClient {
  
  // ==================== WALLET ====================

  Future<dynamic> addWalletData(String userId, int coins) async {
    print('DEV DEBUG - CommunicationsAPI: addWalletData called with userId: $userId, coins: $coins');
    final response = await post('/wallet/addWalletData', {
      'userId': userId,
      'coins': coins,
    });
    return response;
  }

  Future<dynamic> getWalletData(String userId) async {
    print('DEV DEBUG - CommunicationsAPI: getWalletData called for userId: $userId');
    final response = await get('/wallet/getWalletData/$userId');
    return response;
  }

  // ==================== SEND EMAIL ====================

  Future<dynamic> sendSingleMail(Map<String, dynamic> mailData) async {
    print('DEV DEBUG - CommunicationsAPI: sendSingleMail called');
    final response = await post('/send-email/sendSingleMail', mailData);
    return response;
  }

  Future<dynamic> sendBulkMail(String campaignId) async {
    print('DEV DEBUG - CommunicationsAPI: sendBulkMail called for campaignId: $campaignId');
    final response = await post('/send-email/sendBulkMail/$campaignId', {});
    return response;
  }

  // ==================== BULK CAMPAIGN ====================

  Future<dynamic> createBulkCampaign(Map<String, dynamic> campaignData) async {
    print('DEV DEBUG - CommunicationsAPI: createBulkCampaign called with data: $campaignData');
    final response = await post('/bulk-campagin/createBulkCampagians', campaignData);
    return response;
  }

  Future<dynamic> getAllCampaigns({int page = 1, int limit = 10, String? userId, String? adminStatus, String? channel}) async {
    String query = '?page=$page&limit=$limit';
    if (userId != null) query += '&userId=$userId';
    if (adminStatus != null) query += '&adminStatus=$adminStatus';
    if (channel != null) query += '&channel=$channel';
    
    print('DEV DEBUG - CommunicationsAPI: getAllCampaigns called with query: $query');
    final response = await get('/bulk-campagin/getAllCampaigns$query');
    return response;
  }

  Future<dynamic> getCampaignReport(String userId) async {
    print('DEV DEBUG - CommunicationsAPI: getCampaignReport called for userId: $userId');
    final response = await get('/bulk-campagin/getCampaginReport/$userId');
    return response;
  }

  Future<dynamic> getCampaignRecipients() async {
    print('DEV DEBUG - CommunicationsAPI: getCampaignRecipients called');
    final response = await get('/bulk-campagin/getCampaignRecipients');
    return response;
  }

  Future<dynamic> uploadCsvData({
    required String userId,
    required String channel,
    required String scheduledAt,
    String? subject,
    String? message,
    String? templateId,
    http.MultipartFile? file,
    http.MultipartFile? voiceFile,
  }) async {
    print('DEV DEBUG - CommunicationsAPI: uploadCsvData called for userId: $userId');
    
    Map<String, String> fields = {
      'userId': userId,
      'channel': channel,
      'scheduledAt': scheduledAt,
      'templateId': templateId ?? '',
      'subject': subject ?? '',
      'message': message ?? '',
    };
    
    // Some backends require voiceFile to be present even as an empty string if no file is uploaded
    if (voiceFile == null) {
      fields['voiceFile'] = '';
    }

    List<http.MultipartFile> files = [];
    if (file != null) files.add(file);
    if (voiceFile != null) files.add(voiceFile);

    final response = await postMultipart(
      '/bulk-campagin/upload',
      fields: fields,
      files: files,
    );
    return response;
  }

  Future<dynamic> getAllUploadedCsvData({int page = 1, int limit = 10, String? status, String? userId}) async {
    String query = '?page=$page&limit=$limit';
    if (status != null) query += '&status=$status';
    if (userId != null) query += '&userId=$userId';
    
    print('DEV DEBUG - CommunicationsAPI: getAllUploadedCsvData called with query: $query');
    final response = await get('/bulk-campagin/getAllUploadedCsvData$query');
    return response;
  }

  Future<dynamic> getUploadedCsvDataForUser(String userId) async {
    print('DEV DEBUG - CommunicationsAPI: getUploadedCsvDataForUser called for userId: $userId');
    final response = await get('/bulk-campagin/getUploadedCsvDat/$userId'); // Note the typo in endpoint from swagger 'getUploadedCsvDat'
    return response;
  }
}

