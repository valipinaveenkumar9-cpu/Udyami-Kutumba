import 'package:http/http.dart' as http;
import '../api.dart';
import '../../utils/session_manager.dart';

class MembershipPurchaseAPI {
  final ApiClient _client = ApiClient();

  // Fetch all membership plans
  Future<dynamic> getAllPlans() async {
    return await _client.get('/membership-purchase/membershipAllPlans');
  }

  // Update membership (Subscribe to Prime/Basic)
  Future<dynamic> updateMembership({
    required String userId,
    required bool isBasic,
    required bool isPrime,
  }) async {
    return await _client.patch('/membership-purchase/update-membership', {
      "userId": userId,
      "isBasic": isBasic,
      "isPrime": isPrime,
    });
  }

  // Create order for membership purchase
  Future<dynamic> createOrder({
    required String userId,
    required String planId,
  }) async {
    return await _client.post('/membership-purchase/create-order', {
      "userId": userId,
      "planId": planId,
    });
  }

  // Verify payment
  Future<dynamic> verifyPayment({
    required String paymentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    return await _client.post('/membership-purchase/verify-payment', {
      "paymentId": paymentId,
      "razorpayOrderId": razorpayOrderId,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpaySignature": razorpaySignature,
    });
  }

  // Get Membership History
  Future<dynamic> getMembershipHistory(String userId) async {
    return await _client.get('/membership-purchase/membership-history?userId=$userId');
  }

  // Download Receipt (Returns raw binary bodyBytes)
  Future<dynamic> downloadReceipt(String paymentId) async {
    final token = SessionManager.token;
    // Safely use ApiClient.baseUrl statically
    final url = Uri.parse('${ApiClient.baseUrl}/membership-purchase/receipt/$paymentId');
    try {
      final response = await http.get(url, headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

}
