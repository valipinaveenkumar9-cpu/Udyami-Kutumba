import 'dart:io';

void main() {
  final file = File('lib/core/api/api.dart');
  var text = file.readAsStringSync();

  final method = """
  Future<dynamic> getBytes(String endpoint) async {
    final sw = Stopwatch()..start();
    final url = Uri.parse('\$baseUrl\$endpoint');
    print('DEV DEBUG - getBytes - api.dart - API GET Bytes Request to: \$url');
    try {
      var response = await http.get(url, headers: _headers);
      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          response = await http.get(url, headers: _headers);
        }
      }
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.getBytes(\$endpoint) network call took \${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      sw.stop();
      print('DEV DEBUG - API Load Time - ApiClient.getBytes(\$endpoint) FAILED');
      return null;
    }
  }
""";

  if (!text.contains('getBytes(')) {
    text = text.replaceFirst('Future<http.Response> postRaw', method + '\n  Future<http.Response> postRaw');
    file.writeAsStringSync(text);
  }
}
