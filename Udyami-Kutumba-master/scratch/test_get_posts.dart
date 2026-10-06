import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNzg3ODcxZC0xYzM4LTRkMzEtYmZjZi03ZTdkNGU5MTA2MDAiLCJlbWFpbCI6InZhbGlwaW5hdmVlbmt1bWFyOUBnbWFpbC5jb20iLCJyb2xlcyI6W10sImlhdCI6MTc4NzU1MDcyNSwiZXhwIjoxNzg3NjM3MTI1fQ.aNjQAXSOTeIhaxsnSHc-ZVQP5ZYObjIgKYDu-lRsHWI';
  String userId = 'd787871d-1c38-4d31-bfcf-7e7d4e910600'; // my user ID
  
  try {
    var postRes = await http.get(
      Uri.parse('https://backend.udyamikutumba.com/feed/getPostBy/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*'
      }
    );
    print('Posts raw: ${postRes.body}');
  } catch(e) {
    print('Error: $e');
  }
}
