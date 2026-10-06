import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/gratitude_model.dart';
import '../../utils/session_manager.dart';
import 'package:http/http.dart' as http;
import '../api.dart';

class GratitudeAPI {
  static final ApiClient _api = ApiClient();

  static Future<List<GratitudeModel>> getAllGratitudeSlips() async {
    final userId = SessionManager.user?['userId'] ?? SessionManager.user?['id'];

    if (userId == null || userId.toString().isEmpty) {
      log("Error: User ID is missing.");
      throw Exception("User ID is missing.");
    }

    try {
      final response = await _api.get('/gratitude/getGratitudeSlipByCreatedUser/$userId');

      if (response != null && response['success'] == true && response['data'] != null) {
        final dataList = response['data'] as List;
        return dataList.map((e) => GratitudeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("DEV DEBUG - error - gratitude_api.dart - Error fetching gratitude slips: $e");
      return [];
    }
  }

  static Future<bool> createGratitudeSlip({
    required Map<String, dynamic> payload,
    String? utrNo,
    List<String>? imagePaths,
  }) async {
    print("DEV DEBUG - method - gratitude_api.dart - createGratitudeSlip called");
    try {
      final Map<String, String> fields = {};
      payload.forEach((key, value) {
        if (value != null) {
          fields[key] = value.toString();
        }
      });

      if (utrNo != null && utrNo.isNotEmpty) {
        fields['utrNo'] = utrNo;
      }

      List<http.MultipartFile> files = [];
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (var path in imagePaths) {
          files.add(await http.MultipartFile.fromPath('proofImages', path));
        }
      }

      final response = await _api.postMultipart(
        '/gratitude/CreateGratitudeSlip',
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      if (response != null && response['success'] != false) {
        return true;
      }
      return false;
    } catch (e) {
      print("DEV DEBUG - error - gratitude_api.dart - Error creating gratitude slip: $e");
      return false;
    }
  }
}
