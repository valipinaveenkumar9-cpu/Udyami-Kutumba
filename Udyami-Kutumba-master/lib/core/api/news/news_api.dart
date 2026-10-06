import 'package:flutter/foundation.dart';
import '../../models/news_model.dart';
import '../api.dart';

class NewsAPI {
  static final ApiClient _api = ApiClient();

  static Future<bool> createNews(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/news/createNews', payload);
      return response != null && response['success'] != false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception creating news: $e");
      return false;
    }
  }

  static Future<List<NewsModel>> getAllNews({
    int page = 1,
    int limit = 50,
    String? category,
    String? search,
    bool? isFeatured,
  }) async {
    try {
      final queryParams = <String>[
        'page=$page',
        'limit=$limit',
      ];
      
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }
      if (isFeatured != null) {
        queryParams.add('isFeatured=$isFeatured');
      }

      final q = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _api.get('/news/getAllNews$q');

      if (response != null && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => NewsModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching all news: $e");
      return [];
    }
  }

  static Future<List<NewsModel>> getFeaturedNews() async {
    try {
      final response = await _api.get('/news/getFeaturedNews');

      if (response != null && response['success'] == true && response['data'] != null) {
        return (response['data'] as List).map((x) => NewsModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception fetching featured news: $e");
      return [];
    }
  }

  static Future<bool> updateNews(String newsId, Map<String, dynamic> payload) async {
    try {
      final response = await _api.patch('/news/updateNews/$newsId', payload);
      return response != null && response['success'] != false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception updating news: $e");
      return false;
    }
  }

  static Future<bool> deleteNews(String newsId) async {
    try {
      final response = await _api.delete('/news/deleteNews/$newsId');
      return response != null && response['success'] != false;
    } catch (e) {
      if (kDebugMode) print("DEV DEBUG - Exception deleting news: $e");
      return false;
    }
  }
}
