import 'package:flutter/foundation.dart';
import '../../models/job_model.dart';
import '../../models/applications/application_model.dart';
import '../api.dart';

class JobAPI {
  static final ApiClient _api = ApiClient();

  static Future<List<JobModel>> getAllJobs({
    int page = 1,
    int limit = 50,
    String? search,
    String? city,
    String? jobType,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (jobType != null && jobType.isNotEmpty) queryParams['jobType'] = jobType;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri(path: '/jobs/getAllJobs', queryParameters: queryParams).toString();
      final response = await _api.get(uri);

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => JobModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching jobs: $e");
      return [];
    }
  }

  static Future<bool> createJob(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/jobs/createJob', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception creating job: $e");
      return false;
    }
  }

  static Future<bool> updateJob(String jobId, Map<String, dynamic> payload) async {
    try {
      final response = await _api.patch('/jobs/updateJob/$jobId', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception updating job: $e");
      return false;
    }
  }

  static Future<bool> deleteJob(String jobId) async {
    try {
      final response = await _api.delete('/jobs/deleteJob/$jobId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception deleting job: $e");
      return false;
    }
  }

  static Future<bool> applyJob(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/jobs/applyJob', payload);
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception applying for job: $e");
      return false;
    }
  }

  static Future<List<ApplicationModel>> getAllApplications({
    int page = 1,
    int limit = 50,
    String? search,
    String? jobId,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (jobId != null && jobId.isNotEmpty) queryParams['jobId'] = jobId;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri(path: '/jobs/getAllApplications', queryParameters: queryParams).toString();
      final response = await _api.get(uri);

      if (response is Map && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => ApplicationModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching applications: $e");
      return [];
    }
  }

  static Future<bool> deleteApplication(String applicationId) async {
    try {
      final response = await _api.delete('/jobs/deleteApplication/$applicationId');
      if (response is Map && response['success'] == false && response.containsKey('statusCode')) return false;
      return true;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception deleting application: $e");
      return false;
    }
  }
}
