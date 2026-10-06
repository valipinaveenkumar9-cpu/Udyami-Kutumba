import '../api.dart';

class MeetingAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> createMeeting(String userId, Map<String, dynamic> meetingData) async {
    try {
      final response = await _api.post('/meetings/createMeetings?userId=$userId', meetingData);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getMeetingsById(String userId) async {
    try {
      final response = await _api.get('/meetings/getMeetingsById/$userId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAllMeetings() async {
    try {
      final response = await _api.get('/meetings/getAllMeetings');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAcceptedMeetings(String userId) async {
    try {
      final response = await _api.get('/meetings/getAcceptedMeetings?userId=$userId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> updateMeeting(String meetingId, String userId, Map<String, dynamic> meetingData) async {
    try {
      final response = await _api.patch('/meetings/updateMemberMeetings/$meetingId?userId=$userId', meetingData);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> respondMemberMeeting(String userId, String meetingId, String status) async {
    try {
      final payload = {
        "meetingId": meetingId,
        "status": status,
      };
      final response = await _api.post('/meetings/respondMemberMeetings?userId=$userId', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> createAsemblyBasedMeetings(String userId, Map<String, dynamic> meetingData) async {
    try {
      final response = await _api.post('/meetings/createAsemblyBasedMeetings?userId=$userId', meetingData);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAllAssemblyMeetings(String talukaId) async {
    try {
      final response = await _api.get('/meetings/getAllAssemblyMeetings/$talukaId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAllMeetingsByCreatedUserId(String userId) async {
    try {
      final response = await _api.get('/meetings/getAllMeetings/created-by/$userId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAllWardPositionsUsers(String talukaId) async {
    try {
      final response = await _api.get('/meetings/getAllWardPositionsUsers/$talukaId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> createWardBasedMeetings(String userId, Map<String, dynamic> meetingData) async {
    try {
      final response = await _api.post('/meetings/createWardBasedMeetings?userId=$userId', meetingData);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAllWardMeetings(String wardId) async {
    try {
      final response = await _api.get('/meetings/getAllWardMeetings/$wardId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getWardMembersWithDesignations(String wardId) async {
    try {
      final response = await _api.get('/meetings/getWardMembersWithDesignations/$wardId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> startMeeting(String meetingId, String userId, {String? meetingType}) async {
    try {
      final payload = {
        'userId': userId,
        if (meetingType != null) 'meetingType': meetingType,
      };
      final response = await _api.post('/meetings/startMeeting/$meetingId', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> endMeeting(String meetingId, String userId, {String? meetingType}) async {
    try {
      String endpoint = '/meetings/endMeeting/$meetingId?userId=$userId';
      if (meetingType != null && meetingType.isNotEmpty) {
        endpoint += '&meetingType=${meetingType.toUpperCase()}';
      }
      final response = await _api.post(endpoint, {});
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getMeetingSummary(String meetingId, String userId) async {
    try {
      final response = await _api.get('/meetings/meetingSummary/$meetingId?userId=$userId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response;
    } catch (e) {
      return null;
    }
  }
}
