import '../api.dart';

class LocationAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> getAllDistricts({String? districtId}) async {
    String endpoint = '/district/getAllDistricts';
    if (districtId != null && districtId.isNotEmpty) {
      endpoint += '?districtId=$districtId';
    }
    
    return await _api.get(endpoint);
  }
}
