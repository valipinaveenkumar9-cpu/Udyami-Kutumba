import '../api.dart';

class GuestAPI {
  static final ApiClient _api = ApiClient();

  // POST /bni-guest/createGuest
  static Future<Map<String, dynamic>?> createGuest({
    required String guestName,
    required String createdUserId,
    String? meetingId,
    String status = "Pending",
    String? businessCategory,
    String? businessSubCategory,
    String? businessTag,
  }) async {
    final Map<String, dynamic> body = {
      "guestName": guestName,
      "createdUserId": createdUserId,
      "status": status,
      if (meetingId != null) "meetingId": meetingId,
      if (businessCategory != null) "businessCategory": businessCategory,
      if (businessSubCategory != null) "businessSubCategory": businessSubCategory,
      if (businessTag != null) "businessTag": businessTag,
    };

    try {
      final response = await _api.post('/bni-guest/createGuest', body);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // GET /bni-guest/getAllGuests
  static Future<Map<String, dynamic>?> getAllGuests() async {
    try {
      final response = await _api.get('/bni-guest/getAllGuests');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return null;
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // PATCH /bni-guest/updateGuestData/{guestId}
  static Future<Map<String, dynamic>?> updateGuestData({
    required String guestId,
    required String userId,
    required String guestName,
    required String status,
  }) async {
    final Map<String, dynamic> body = {
      "userId": userId,
      "guestName": guestName,
      "status": status,
    };

    try {
      final response = await _api.patch('/bni-guest/updateGuestData/$guestId', body);
      // Return response even on error (original behavior)
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
