import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

void main() async {
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNzg3ODcxZC0xYzM4LTRkMzEtYmZjZi03ZTdkNGU5MTA2MDAiLCJlbWFpbCI6InZhbGlwaW5hdmVlbmt1bWFyOUBnbWFpbC5jb20iLCJyb2xlcyI6W10sImlhdCI6MTc4NzU1MDcyNSwiZXhwIjoxNzg3NjM3MTI1fQ.aNjQAXSOTeIhaxsnSHc-ZVQP5ZYObjIgKYDu-lRsHWI';
  String userId = 'd787871d-1c38-4d31-bfcf-7e7d4e910600';
  
  try {
    String postId = 'b137244f-1dc6-4f44-bb14-eb72938bf12e'; // The post we just created
    
    // 2. Delete the post with a body this time
    var deleteResponse = await http.delete(
      Uri.parse('https://backend.udyamikutumba.com/feed/deletePost/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({"userId": userId})
    );
    print('Delete Post (with body) Response: ${deleteResponse.statusCode} - ${deleteResponse.body}');
  } catch(e) {
    print('Error: $e');
  }
}
