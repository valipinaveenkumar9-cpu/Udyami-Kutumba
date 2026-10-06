import '../api.dart';

class DashboardAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> fetchUsersSuperAdmin() async {
    return await _api.get('/auth/getAllUsers');
  }

  Future<dynamic> fetchUsersByDistrict(String district) async {
    return await _api.get(
      '/district/users-by-district?district=${Uri.encodeComponent(district)}',
    );
  }

  Future<dynamic> fetchUsersByTaluka(String taluka) async {
    return await _api.get(
      '/talukas/users-by-taluka?taluka=${Uri.encodeComponent(taluka)}',
    );
  }

  Future<dynamic> fetchUsersByWard(String wardName) async {
    return await _api.get(
      '/ward/users-by-ward?ward=${Uri.encodeComponent(wardName)}',
    );
  }

  Future<dynamic> fetchChannelPartners({String? wardId}) async {
    if (wardId != null) {
      return await _api.get(
        '/auth/getAllChannelPartners?wardId=$wardId&limit=100',
      );
    }
    return await _api.get('/auth/getAllChannelPartners?limit=100');
  }

  Future<dynamic> fetchCloudPatraApplicationsByWard(String wardId) async {
    return await _api.get('/cloud-patra/getAllApplicationsByWard/$wardId');
  }

  Future<dynamic> fetchCpSubmissions(String userId) async {
    return await _api.get(
      '/cp-on-boarding/getAllCPSubmittedDataCreatedBYWardChairman/$userId',
    );
  }

  Future<dynamic> fetchWardsByTaluka(String talukaId) async {
    return await _api.get('/ward/getWardBy/$talukaId');
  }

  Future<dynamic> fetchWardChairmenBy(String locationId) async {
    return await _api.get('/talukas/getAllWardChaimansBy/$locationId');
  }

  // Role-aware position hierarchy lookup. This is the SAME endpoint the
  // web dashboard uses (/ward-chart/hierarchy/:positionId) to resolve a
  // District/Taluka/Ward Head's own administered location. It is more
  // reliable than the profile's generic 'district' field, which reflects
  // the member's registered address and can be empty for appointed heads.
  Future<dynamic> fetchWardHierarchy(String positionId) async {
    return await _api.get('/ward-chart/hierarchy/$positionId');
  }

  Future<dynamic> fetchTalukasByDistrict(String districtId) async {
    return await _api.get('/district/getAllDistricts?districtId=$districtId');
  }

  // Super Admin extras
  Future<dynamic> fetchAllDistricts() async {
    return await _api.get('/district/getAllDistricts');
  }

  Future<dynamic> searchMembers(Map<String, dynamic> payload) async {
    return await _api.post('/userprofile/search-users', payload);
  }

  Future<dynamic> getLocationByWardHeadId(String userId) async {
    return await _api.get('/ward-chart/getLocationByWardHeadId/$userId');
  }

  Future<dynamic> getBusinessCircleDashboard(String id, String type) async {
    return await _api.get('/business-circle/$id/dashboard?type=$type');
  }

  Future<dynamic> fetchHeadsByRole(String role) async {
    return await _api.get('/ward/usersByRole?role=$role');
  }
}
