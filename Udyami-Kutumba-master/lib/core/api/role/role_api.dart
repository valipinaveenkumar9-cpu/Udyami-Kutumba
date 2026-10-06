import '../api.dart';

class RoleAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> assignRole(Map<String, dynamic> data) async {
    return await _api.post('/roles/assignRole', data);
  }

  Future<dynamic> getAllRoles() async {
    return await _api.get('/roles/getAllRoles');
  }

  Future<dynamic> getAllRoleUsers() async {
    return await _api.get('/roles/getAllRoleUsers');
  }
}

