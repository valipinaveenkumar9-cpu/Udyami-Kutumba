import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNzg3ODcxZC0xYzM4LTRkMzEtYmZjZi03ZTdkNGU5MTA2MDAiLCJlbWFpbCI6InZhbGlwaW5hdmVlbmt1bWFyOUBnbWFpbC5jb20iLCJyb2xlcyI6W10sImlhdCI6MTc4NzU1MDcyNSwiZXhwIjoxNzg3NjM3MTI1fQ.aNjQAXSOTeIhaxsnSHc-ZVQP5ZYObjIgKYDu-lRsHWI';
  String postId = '8f1434ec-49ef-42ea-a84c-9beee3966257';
  
  try {
    var likeResponse = await http.delete(
      Uri.parse('https://backend.udyamikutumba.com/feed/$postId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "userId": "d787871d-1c38-4d31-bfcf-7e7d4e910600"
      })
    );
    print('Unlike response: ${likeResponse.statusCode} - ${likeResponse.body}');
  } catch(e) {
    print('Error: $e');
  }
}
