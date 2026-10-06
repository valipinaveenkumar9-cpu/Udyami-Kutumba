

import '../../models/assembly_scorecard_model.dart';
import '../../models/scorecard_model.dart';
import '../../models/scoring_weights_model.dart';
import '../../models/taluka_leaderboard_model.dart';
import '../../models/ward_leaderboard_model.dart';
import '../api.dart';

class ScorecardApi extends ApiClient {
  Future<dynamic> getScorecard(String userId) async {
    print('DEV DEBUG - ScorecardApi - getScorecard called for userId: $userId');
    try {
      final response = await get('/socring-weights/scorecard/$userId');
      if (response != null && response['success'] == true && response['data'] != null) {
        print('DEV DEBUG - ScorecardApi - getScorecard successful');
        return ScorecardModel.fromJson(response['data']);
      }
      return response;
    } catch (e) {
      print('DEV DEBUG - ScorecardApi - getScorecard exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<dynamic> getAllScoringWeights() async {
    print('DEV DEBUG - ScorecardApi - getAllScoringWeights called');
    try {
      final response = await get('/socring-weights/getAllScoringWeights');
      if (response != null && response['success'] == true) {
        print('DEV DEBUG - ScorecardApi - getAllScoringWeights successful');
        return ScoringWeightsResponse.fromJson(response);
      }
      return response;
    } catch (e) {
      print('DEV DEBUG - ScorecardApi - getAllScoringWeights exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<dynamic> updateScoringWeights(Map<String, dynamic> data) async {
    print('DEV DEBUG - ScorecardApi - updateScoringWeights called with: $data');
    try {
      final response = await put('/socring-weights/updateScoringWeights', data);
      print('DEV DEBUG - ScorecardApi - updateScoringWeights response: $response');
      return response;
    } catch (e) {
      print('DEV DEBUG - ScorecardApi - updateScoringWeights exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<dynamic> getWardLeaderboard(String wardName, {int limit = 5}) async {
    print('DEV DEBUG - ScorecardApi - getWardLeaderboard called for wardName: $wardName, limit: $limit');
    try {
      final response = await get('/socring-weights/leaderboard/ward?wardName=$wardName&limit=$limit');
      if (response != null && response['success'] == true) {
        print('DEV DEBUG - ScorecardApi - getWardLeaderboard successful');
        return WardLeaderboardResponse.fromJson(response);
      }
      return response;
    } catch (e) {
      print('DEV DEBUG - ScorecardApi - getWardLeaderboard exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
  Future<dynamic> getTalukaLeaderboard(String talukaId, {int limit = 100}) async {
    print('DEV DEBUG - ScorecardApi - getTalukaLeaderboard called for talukaId: $talukaId, limit: $limit');
    try {
      final response = await get('/socring-weights/getTalukaLeaderboard/$talukaId?limit=$limit');
      if (response != null && response['success'] == true) {
        print('DEV DEBUG - ScorecardApi - getTalukaLeaderboard successful');
        return TalukaLeaderboardResponse.fromJson(response);
      }
      return response;
    } catch (e) {
      print('DEV DEBUG - ScorecardApi - getTalukaLeaderboard exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
  Future<AssemblyScorecardResponse?> getAssemblyScoreCard(String assemblyId, {int limit = 100}) async {
    try {
      final response = await get(
        '/socring-weights/getAssemblyScoreCard/$assemblyId?limit=$limit',
      );
      if (response != null) {
        return AssemblyScorecardResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      print("Error fetching assembly scorecard: $e");
      return null;
    }
  }
}

