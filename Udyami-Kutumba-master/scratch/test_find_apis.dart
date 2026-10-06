import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  try {
    var response = await http.get(Uri.parse('https://backend.udyamikutumba.com/swagger-json'));
    var bodyStr = response.body.toLowerCase();
    
    // Find index of 'follow'
    int index = 0;
    while ((index = bodyStr.indexOf('follow', index)) != -1) {
       int start = (index - 50 < 0) ? 0 : index - 50;
       int end = (index + 50 > bodyStr.length) ? bodyStr.length : index + 50;
       print(bodyStr.substring(start, end).replaceAll('\n', ' '));
       index += 6;
    }
  } catch(e) {
    print('Error: $e');
  }
}
