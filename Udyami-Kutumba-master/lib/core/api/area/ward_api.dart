import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api.dart';

class WardAPI {
  final ApiClient _api = ApiClient();

  Future<dynamic> getAllWards({String? wardName}) async {
    String endpoint = '/ward/getAllWards?limit=1000';
    if (wardName != null && wardName.isNotEmpty) {
      endpoint += '&wardName=${Uri.encodeComponent(wardName)}';
    }
    return await _api.get(endpoint);
  }

  Future<dynamic> getWardMembers(String userId, String wardId) async {
    return await _api.get('/ward-chart/getWardChartData/$userId/$wardId');
  }

  Future<dynamic> getAllUcnMembersUnderWard(String wardId) async {
    return await _api.get('/ward/getAllUcnMembersUnderWard/$wardId');
  }

  Future<dynamic> getWardMap(String wardName, {String type = 'ward'}) async {
    return await _api.get('/ward/map/$wardName?type=$type');
  }

  Future<dynamic> getAllRoleUsers() async {
    return await _api.get('/roles/getAllRoleUsers');
  }

  Future<dynamic> getLocationByWardHeadId(String wardHeadId, String wardId) async {
    return await _api.get('/ward-chart/getWardChartData/$wardHeadId/$wardId');
  }

  Future<dynamic> createWardChartData({
    required String wardHeadId,
    required String wardId,
    required String ward,
    required List<Map<String, dynamic>> members,
    bool? applyToAllWards,
    bool? isCommonPage,
    String? profileImagePath,
  }) async {
    final dataMap = {
      'wardHeadId': wardHeadId,
      'wardId': wardId,
      'ward': ward,
      if (applyToAllWards != null) 'applyToAllWards': applyToAllWards,
      if (isCommonPage != null) 'isCommonPage': isCommonPage,
      'members': members,
    };
    final dataJson = jsonEncode(dataMap);

    List<http.MultipartFile>? files;
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      try {
        final file = await http.MultipartFile.fromPath('profileImages', profileImagePath);
        files = [file];
      } catch (e) {
        print('DEV DEBUG - createWardChartData: Image attachment error: $e');
      }
    }

    return await _api.postMultipart(
      '/ward-chart/createWardChartData',
      fields: {'data': dataJson},
      files: files,
    );
  }

  Future<dynamic> deleteWardChartMember(String memberId, {String? wardHeadId}) async {
    return await _api.delete('/ward-chart/deleteWardChartMember/$memberId');
  }
}

