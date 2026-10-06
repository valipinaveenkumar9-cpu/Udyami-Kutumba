import '../api.dart';

class AuthAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> sendOtp(String mobileNumber, String purpose) async {
    return await _api.post('/auth/send-otp', {
      'mobileNumber': mobileNumber,
      'purpose': purpose,
    });
  }

  Future<dynamic> verifyOtp(String mobileNumber, String otp, String purpose) async {
    return await _api.post('/auth/verify-otp', {
      'mobileNumber': mobileNumber,
      'otp': otp,
      'purpose': purpose,
    });
  }

  Future<dynamic> login(String mobileNumber, {String? otp, String? verificationId, bool? testMode}) async {
    final body = <String, dynamic>{
      'mobileNumber': mobileNumber,
    };
    
    if (testMode == true) {
      body['testMode'] = true;
      if (otp != null) {
        body['otp'] = otp;
      }
    } else {
      if (verificationId != null) {
        body['verificationId'] = verificationId;
      } else if (otp != null) {
        body['otp'] = otp;
      }
    }
    
    return await _api.post('/auth/loginUser', body);
  }

  Future<bool> checkUserExists(String mobileNumber) async {
    try {
      // Call loginUser with a dummy OTP to check if the user exists
      final res = await _api.post('/auth/loginUser', {
        'mobileNumber': mobileNumber,
        'otp': '0000',
      });

      // If the API returns success, it somehow worked (unlikely with dummy OTP)
      if (res != null && res['success'] == true) return true;

      // If the error message is "Invalid mobile number.", then the user doesn't exist
      final errorMsg = (res?['message'] ?? res?['error'] ?? '').toString().toLowerCase();
      if (errorMsg.contains('invalid mobile number') || errorMsg.contains('not found')) {
        return false;
      }

      // If the error is "Invalid OTP", the user exists
      return true;
    } catch (e) {
      print('DEV DEBUG - error checking user exists: $e');
      return true; // Fallback to true so we don't block them if API fails
    }
  }

  Future<dynamic> createUser(Map<String, dynamic> data) async {
    return await _api.post('/auth/createUser', data);
  }

  Future<dynamic> createUserProfile(Map<String, dynamic> data) async {
    return await _api.post('/userprofile/createUserProfile', data);
  }

  Future<dynamic> getUcnMembers(String wardId) async {
    return await _api.get('/auth/ucn-members/$wardId');
  }

  Future<dynamic> getAllUsers() async {
    return await _api.get('/auth/getAllUsers');
  }
}
