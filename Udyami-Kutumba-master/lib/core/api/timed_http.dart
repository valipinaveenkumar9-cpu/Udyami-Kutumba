import 'package:http/http.dart' as http;
import 'dart:convert';
export 'package:http/http.dart' hide get, post, put, patch, delete;

Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
  final sw = Stopwatch()..start();
  final response = await http.get(url, headers: headers);
  sw.stop();
  print('DEV DEBUG - API Load Time - http.get($url) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
  return response;
}

Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final sw = Stopwatch()..start();
  final response = await http.post(url, headers: headers, body: body, encoding: encoding);
  sw.stop();
  print('DEV DEBUG - API Load Time - http.post($url) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
  return response;
}

Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final sw = Stopwatch()..start();
  final response = await http.put(url, headers: headers, body: body, encoding: encoding);
  sw.stop();
  print('DEV DEBUG - API Load Time - http.put($url) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
  return response;
}

Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final sw = Stopwatch()..start();
  final response = await http.patch(url, headers: headers, body: body, encoding: encoding);
  sw.stop();
  print('DEV DEBUG - API Load Time - http.patch($url) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
  return response;
}

Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final sw = Stopwatch()..start();
  final response = await http.delete(url, headers: headers, body: body, encoding: encoding);
  sw.stop();
  print('DEV DEBUG - API Load Time - http.delete($url) network call took ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
  return response;
}
