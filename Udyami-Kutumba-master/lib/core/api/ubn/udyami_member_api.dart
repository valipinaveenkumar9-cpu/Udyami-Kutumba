import '../api.dart';

class UdyamiMemberAPI {
  static final ApiClient _api = ApiClient();

  static Future<bool> createUdyamiMember(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/udyami-members/createUdyamiMembers', payload);
      
      if (response != null && response['success'] != false) {
        return true;
      } else {
        print("DEV DEBUG - createUdyamiMembers failed: $response");
        return false;
      }
    } catch (e) {
      print("DEV DEBUG - Error in createUdyamiMembers: $e");
      return false;
    }
  }

  static Future<bool> updateUdyamiMember(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _api.patch('/udyami-members/$id/profile', payload);
      
      if (response != null && response['success'] != false) {
        return true;
      } else {
        print("DEV DEBUG - updateUdyamiMember failed: $response");
        return false;
      }
    } catch (e) {
      print("DEV DEBUG - Error in updateUdyamiMember: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getAllUdyamiMembers() async {
    try {
      final response = await _api.get('/udyami-members/getAllUdyamiMembers?limit=1000');
      
      if (response != null && response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        print("DEV DEBUG - getAllUdyamiMembers failed: $response");
      }
    } catch (e) {
      print("DEV DEBUG - Error in getAllUdyamiMembers: $e");
    }
    return [];
  }
}
