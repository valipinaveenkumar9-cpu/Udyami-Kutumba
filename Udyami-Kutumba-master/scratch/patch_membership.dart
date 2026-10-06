import 'dart:io';

void main() {
  final file = File('lib/core/api/membership_purchase_api.dart');
  var text = file.readAsStringSync();

  final oldMethod = """
  // Download Receipt
  Future<dynamic> downloadReceipt(String paymentId) async {
    final token = SessionManager.token;
    final url = Uri.parse('\${ApiClient.baseUrl}/membership-purchase/receipt/\$paymentId');
    try {
      final response = await http.get(url, headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer \$token',
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
""";

  final newMethod = """
  // Download Receipt
  Future<dynamic> downloadReceipt(String paymentId) async {
    return await _client.getBytes('/membership-purchase/receipt/\$paymentId');
  }
""";

  if (text.contains('http.get(url')) {
    text = text.replaceFirst(oldMethod.trim(), newMethod.trim());
    
    // Also we can remove `import 'package:http/http.dart' as http;` if it's there
    text = text.replaceAll("import 'package:http/http.dart' as http;\n", "");
    text = text.replaceAll("import 'timed_http.dart' as http;\n", "");
    
    file.writeAsStringSync(text);
  }
}
