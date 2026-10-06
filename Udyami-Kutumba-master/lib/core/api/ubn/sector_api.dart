import 'dart:convert' as dart_convert;
import '../api.dart';

class SectorAPI {
  final ApiClient _api = ApiClient();

  // 1. Get All Categories
  Future<dynamic> getAllCategories() async {
    final response = await _api.get('/sector/getAllCategories');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 1b. Get All Sectors
  Future<dynamic> getAllSectors() async {
    final response = await _api.get('/sector/getAllSectors');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 2. Create Sector Join Request
  Future<dynamic> createSectorRequest(Map<String, dynamic> data) async {
    final response = await _api.post('/sector-join-request', data);
    // Return error responses so UI can show message
    return response;
  }

  // 3. Get All Sector Join Requests
  Future<dynamic> getAllSectorRequests() async {
    final response = await _api.get('/sector-join-request');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 4. Get Sector Join Request By Id
  Future<dynamic> getSectorRequestById(String id) async {
    final response = await _api.get('/sector-join-request/$id');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 5. Get Requests Created By User
  Future<dynamic> getRequestsCreatedByUser(String userId) async {
    final response = await _api.get('/sector-join-request/created-user/$userId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 6. Get Member Requests
  Future<dynamic> getMemberRequests(String userId) async {
    final response = await _api.get('/sector-join-request/member/$userId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 7. Endorse Request
  Future<dynamic> endorseRequest(String id) async {
    final response = await _api.patch('/sector-join-request/$id/endorse', {});
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 8. Approve Request
  Future<dynamic> approveRequest(String id) async {
    final response = await _api.patch('/sector-join-request/$id/approve', {});
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 9. Reject Request
  Future<dynamic> rejectRequest(String id, String remarks) async {
    final response = await _api.patch('/sector-join-request/$id/reject', {'remarks': remarks});
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 10. Delete Request
  Future<dynamic> deleteRequest(String id) async {
    final response = await _api.delete('/sector-join-request/$id');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 11. Create Business Tags
  Future<dynamic> createBusinessTags(Map<String, dynamic> data) async {
    final response = await _api.post('/sector-join-request/createBusinessTags', data);
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 12. Get All Sub-Sub-Sectors by SubSector Id
  Future<dynamic> getAllSubSubSectors(String subSectorId) async {
    final response = await _api.get('/sector/getAllSubSubSectors/$subSectorId');
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }

  // 13. Create Other (Sector / Sub-Sector / Sub-Sub-Sector)
  Future<dynamic> createOther(Map<String, dynamic> data) async {
    final response = await _api.post('/sector/create-other', data);
    if (response is Map<String, dynamic> && response['success'] == false && response.containsKey('statusCode')) return null;
    return response;
  }
}
