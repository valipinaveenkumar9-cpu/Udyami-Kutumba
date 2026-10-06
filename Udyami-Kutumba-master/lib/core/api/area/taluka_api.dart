import '../api.dart';

class TalukaAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> getAssemblyLeadership(String talukaId) async {
    return await _api.get('/talukas/getAssemblyLeadership/$talukaId');
  }

  Future<dynamic> getAllTalukas() async {
    return await _api.get('/talukas/getAllTalukas');
  }

  Future<dynamic> getAllUcnMembersUnderTaluka(String talukaId) async {
    return await _api.get('/talukas/getAllUcnMembersUnderTaluka/$talukaId');
  }
}
