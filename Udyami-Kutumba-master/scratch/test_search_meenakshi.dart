import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final payload = {
    'name': 'Meenakshi',
    'query': 'Meenakshi',
    'role': 'TalukHead',
    'wardName': 'Subedarpalya',
    'talukaId': 'f9a6257c-7cbe-4c1c-a25a-8403ee801110',
    'districtId': '3a4b9264-bc85-4d60-b74a-32ea61304150',
  };
  
  final res = await http.post(
    Uri.parse('https://backend.udyamikutumba.com/userprofile/search-users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );
  
  print(res.statusCode);
  print(res.body);
}
