import '../api.dart';

class UdyamimngtAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> getAllDesignations() async {
    return await _api.get('/udyamimngt/designations');
  }

  Future<dynamic> assignDesignation(Map<String, dynamic> data) async {
    return await _api.post('/udyamimngt/assign', data);
  }

  Future<dynamic> getMngtMembers(String wardId) async {
    return await _api.get('/udyamimngt/getMngtMembers/$wardId');
  }

  Future<dynamic> getAssignedMembersByCircleLeader(String circleLeaderId) async {
    return await _api.get('/udyamimngt/assigned-members/circle-leader/$circleLeaderId');
  }

  Future<dynamic> replaceDesignationHolder(Map<String, dynamic> data) async {
    return await _api.patch('/udyamimngt/replace-holder', data);
  }
}


