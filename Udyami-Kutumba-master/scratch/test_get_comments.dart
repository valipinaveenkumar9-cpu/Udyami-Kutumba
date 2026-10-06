import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  try {
    var response = await http.get(Uri.parse('https://backend.udyamikutumba.com/swagger-json'));
    var json = jsonDecode(response.body);
    var paths = json['paths'] as Map;
    for (var path in paths.keys) {
      if (path.toString().toLowerCase().contains('comment')) {
        for (var method in (paths[path] as Map).keys) {
          if (method == 'delete') {
            print('Found DELETE comment path: $path');
          }
        }
      }
    }
  } catch(e) {
    print('Error: $e');
  }
}
