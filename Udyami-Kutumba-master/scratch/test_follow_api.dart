import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNzg3ODcxZC0xYzM4LTRkMzEtYmZjZi03ZTdkNGU5MTA2MDAiLCJlbWFpbCI6InZhbGlwaW5hdmVlbmt1bWFyOUBnbWFpbC5jb20iLCJyb2xlcyI6W10sImlhdCI6MTc4NzU1MDcyNSwiZXhwIjoxNzg3NjM3MTI1fQ.aNjQAXSOTeIhaxsnSHc-ZVQP5ZYObjIgKYDu-lRsHWI';
  
  try {
    var response = await http.post(
      Uri.parse('https://backend.udyamikutumba.com/user/follow'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "userId": "d787871d-1c38-4d31-bfcf-7e7d4e910600",
        "targetUserId": "e8e19572-c23d-4c3d-b4b6-a83a0adbd457"
      })
    );
    print('Follow Response: ${response.statusCode} - ${response.body}');
  } catch(e) {
    print('Error: $e');
  }
}
