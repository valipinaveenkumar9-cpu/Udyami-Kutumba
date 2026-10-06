import 'package:flutter/foundation.dart';
import '../../models/uc_training_model.dart';
import '../api.dart';

class UcTrainingAPI {
  final ApiClient _api = ApiClient();

  Future<List<UcTrainingModel>> getAllTrainings() async {
    try {
      final response = await _api.get('/uc-training/getAllTrainings');

      if (response != null && response['success'] == true && response['data'] != null) {
        final List<dynamic> list = response['data'];
        return list.map((e) => UcTrainingModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("DEV DEBUG - get - uc_training_api.dart - Exception: $e");
      }
      return [];
    }
  }
}
