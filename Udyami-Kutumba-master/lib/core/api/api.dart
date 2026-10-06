import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/network_utils.dart';
import '../utils/session_manager.dart';

class ApiClient {
  static String get baseUrl => NetworkUtils.baseUrl;

  Map<String, String> get _headers {
    final token = SessionManager.token;
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  bool _isRefreshing = false;
  Future<bool>? _refreshFuture;

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return await _refreshFuture ?? false;

    _isRefreshing = true;
    _refreshFuture = _doRefreshToken();
    final result = await _refreshFuture!;
    _isRefreshing = false;
    return result;
  }

  Future<bool> _doRefreshToken() async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) return false;
    
    final url = Uri.parse('$baseUrl/auth/refresh-token');
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final newToken = decoded['token'] ?? decoded['accessToken'] ?? decoded['data']?['token'] ?? decoded['data']?['accessToken'];
        if (newToken != null && newToken is String) {
          final user = SessionManager.user;
          await SessionManager.saveSession(newToken, user ?? {});
          return true;
        }
      }
      await SessionManager.clearSession();
      return false;
    } catch (e) {
      await SessionManager.clearSession();
      return false;
    }
  }

  Future<dynamic> _requestWithRetry(String endpoint, Future<http.Response> Function() requestFunc) async {
    try {
      var response = await requestFunc();
      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          response = await requestFunc();
        }
      }
      return _processResponse(response);
    } catch (e) {
      print('DEV DEBUG - API Load Time - ApiClient request($endpoint) FAILED');
      print('DEV DEBUG - api.dart - API Exception for $endpoint: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - post - api.dart - API POST Request to: $url');
      print('DEV DEBUG - post - api.dart - API POST Body: ${jsonEncode(body)}');
      
      final response = await http.post(url, headers: _headers, body: jsonEncode(body));
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.post($endpoint, body: ${jsonEncode(body)}) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - post - api.dart - API POST Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - post - api.dart - API POST Response Body: ${response.body}');
      return response;
    });
  }

  Future<dynamic> get(String endpoint) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - get - api.dart - API GET Request to: $url');
      
      final response = await http.get(url, headers: _headers);
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.get($endpoint) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - get - api.dart - API GET Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - get - api.dart - API GET Response Body: ${response.body}');
      return response;
    });
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - put - api.dart - API PUT Request to: $url');
      print('DEV DEBUG - put - api.dart - API PUT Body: ${jsonEncode(body)}');
      
      final response = await http.put(url, headers: _headers, body: jsonEncode(body));
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.put($endpoint, body: ${jsonEncode(body)}) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - put - api.dart - API PUT Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - put - api.dart - API PUT Response Body: ${response.body}');
      return response;
    });
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - patch - api.dart - API PATCH Request to: $url');
      print('DEV DEBUG - patch - api.dart - API PATCH Body: ${jsonEncode(body)}');
      
      final response = await http.patch(url, headers: _headers, body: jsonEncode(body));
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.patch($endpoint, body: ${jsonEncode(body)}) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - patch - api.dart - API PATCH Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - patch - api.dart - API PATCH Response Body: ${response.body}');
      return response;
    });
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - delete - api.dart - API DELETE Request to: $url');
      
      final response = await http.delete(url, headers: _headers, body: data != null ? jsonEncode(data) : null);
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.delete($endpoint, data: ${data != null ? jsonEncode(data) : "null"}) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - delete - api.dart - API DELETE Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - delete - api.dart - API DELETE Response Body: ${response.body}');
      return response;
    });
  }

    Future<dynamic> getBytes(String endpoint) async {
    final sw = Stopwatch()..start();
    final url = Uri.parse('$baseUrl$endpoint');
    print('DEV DEBUG - getBytes - api.dart - API GET Bytes Request to: $url');
    try {
      var response = await http.get(url, headers: _headers);
      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          response = await http.get(url, headers: _headers);
        }
      }
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.getBytes($endpoint) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.getBytes($endpoint) FAILED');
      return null;
    }
  }

  Future<http.Response> postRaw(String endpoint, Map<String, dynamic> body) async {
    final sw = Stopwatch()..start();
    final url = Uri.parse('$baseUrl$endpoint');
    print('DEV DEBUG - postRaw - api.dart - API POST Raw Request to: $url');
    print('DEV DEBUG - postRaw - api.dart - API POST Raw Body: ${jsonEncode(body)}');

    var response = await http.post(url, headers: _headers, body: jsonEncode(body));
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        response = await http.post(url, headers: _headers, body: jsonEncode(body));
      }
    }
    
    sw.stop();
    print('DEV DEBUG - API Load Time - ApiClient.postRaw($endpoint) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
    print('DEV DEBUG - postRaw - api.dart - API POST Raw Response Status [${response.statusCode}] from: $url');
    return response;
  }

  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
  }) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - postMultipart - api.dart - API POST Multipart to: $url');
      print('DEV DEBUG - postMultipart - api.dart - Fields: $fields');

      final request = http.MultipartRequest('POST', url);
      final token = SessionManager.token;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (files != null) {
        for (var file in files) {
          request.files.add(file);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.postMultipart($endpoint, fields: $fields) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - postMultipart - api.dart - Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - postMultipart - api.dart - Response Body: ${response.body}');
      return response;
    });
  }

  Future<dynamic> patchMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
  }) async {
    return _requestWithRetry(endpoint, () async {
      final sw = Stopwatch()..start();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DEV DEBUG - patchMultipart - api.dart - API PATCH Multipart to: $url');
      print('DEV DEBUG - patchMultipart - api.dart - Fields: $fields');

      final request = http.MultipartRequest('PATCH', url);
      final token = SessionManager.token;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (files != null) {
        for (var file in files) {
          request.files.add(file);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.patchMultipart($endpoint, fields: $fields) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      print('DEV DEBUG - patchMultipart - api.dart - Response Status [${response.statusCode}] from: $url');
      print('DEV DEBUG - patchMultipart - api.dart - Response Body: ${response.body}');
      return response;
    });
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body; 
      }
    } else {
      String errorMsg = 'Error ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final msg = decoded['message'] ?? decoded['error'] ?? errorMsg;
          return {
            'success': false,
            'statusCode': response.statusCode,
            'message': msg.toString(),
            'error': msg.toString(),
            'data': decoded,
          };
        }
      } catch (_) {}
      return {'success': false, 'statusCode': response.statusCode, 'error': errorMsg, 'message': errorMsg};
    }
  }
}
