import 'dart:convert';
import '../api.dart';

class AttendanceAPI {
  final ApiClient _api = ApiClient();

  // 1. Create Attendance Session
  Future<dynamic> createAttendanceSession(Map<String, dynamic> payload) async {
    final response = await _api.post('/attendance/CreateAttendanceSession', payload);
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 2. Generate QR
  Future<dynamic> generateQR(String attendanceSessionId) async {
    final response = await _api.get('/attendance/session/$attendanceSessionId/qr');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 3. Get Active Session
  Future<dynamic> getActiveSession(String meetingId) async {
    final response = await _api.get('/attendance/session/$meetingId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 4. Scan QR
  Future<dynamic> scanQR(Map<String, dynamic> payload) async {
    // Original returned response body regardless of status for error messages
    final response = await _api.post('/attendance/scanQR', payload);
    return response;
  }

  // 5. Manual Attendance
  Future<dynamic> addManualAttendance(Map<String, dynamic> payload) async {
    final response = await _api.patch('/attendance/addManualAttendance', payload);
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 6. Get Meeting Attendance
  Future<dynamic> getMeetingAttendance(String meetingId) async {
    final response = await _api.get('/attendance/meeting/$meetingId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 7. Close Attendance Session
  Future<dynamic> closeSession(String attendanceSessionId) async {
    final response = await _api.post('/attendance/close-session', {'attendanceSessionId': attendanceSessionId});
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }
}
