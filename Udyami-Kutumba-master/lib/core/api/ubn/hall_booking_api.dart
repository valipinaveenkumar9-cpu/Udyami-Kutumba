import '../api.dart';
import '../../utils/session_manager.dart';

class HallBookingAPI {
  final ApiClient _api = ApiClient();

  /// 1. Create Hall Booking
  Future<dynamic> createHallBooking({
    required String meetingId,
    required String hallName,
    required String bookingDate,
    required int seats,
  }) async {
    final createdUserId = SessionManager.user?['userId'];
    if (createdUserId == null) {
      return {'success': false, 'message': 'User ID not found in session'};
    }

    final body = {
      "meetingId": meetingId,
      "hallName": hallName,
      "bookingDate": bookingDate,
      "seats": seats,
      "createdUserId": createdUserId,
    };
    
    return await _api.post('/hall-booking/createHallBooking', body);
  }

  /// 2. Get Hall Bookings by Created User
  Future<dynamic> getHallBookingsByUser(String createdUserId) async {
    return await _api.get('/hall-booking/getBookingHallData/$createdUserId');
  }

  /// 3. Get All Hall Bookings
  Future<dynamic> getAllHallBookings() async {
    return await _api.get('/hall-booking/getAllHallBookings');
  }

  /// 4. Update Hall Booking
  Future<dynamic> updateHallBooking(String hallBookingId, {
    String? hallName,
    String? bookingDate,
    int? seats,
  }) async {
    final body = <String, dynamic>{};
    if (hallName != null) body['hallName'] = hallName;
    if (bookingDate != null) body['bookingDate'] = bookingDate;
    if (seats != null) body['seats'] = seats;

    return await _api.patch('/hall-booking/updateBookingData/$hallBookingId', body);
  }

  /// 5. Delete Hall Booking
  Future<dynamic> deleteHallBooking(String hallBookingId) async {
    return await _api.delete('/hall-booking/deleteHallBooking/$hallBookingId');
  }
}
