import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNzg3ODcxZC0xYzM4LTRkMzEtYmZjZi03ZTdkNGU5MTA2MDAiLCJlbWFpbCI6InZhbGlwaW5hdmVlbmt1bWFyOUBnbWFpbC5jb20iLCJyb2xlcyI6W10sImlhdCI6MTc4NzU1MDcyNSwiZXhwIjoxNzg3NjM3MTI1fQ.aNjQAXSOTeIhaxsnSHc-ZVQP5ZYObjIgKYDu-lRsHWI';
  
  try {
    var res = await http.get(
      Uri.parse('https://backend.udyamikutumba.com/auth/getAllUsers'),
      headers: { 'Authorization': 'Bearer $token', 'accept': '*/*' }
    );
    print('GET /auth/getAllUsers -> ${res.statusCode}');
    if (res.statusCode == 200 || res.statusCode == 201) {
       print(res.body.substring(0, res.body.length > 200 ? 200 : res.body.length));
    }
  } catch(e) {
    print('Error: $e');
  }
}
