import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://backend.udyamikutumba.com';
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwYzY5MjVjZC0zZmNmLTRiZDQtOGM1MS00ZWU4ZmYwN2FiNjQiLCJlbWFpbCI6Im1zLmFwcHByb2plY3RzQGdtYWlsLmNvbSIsInJvbGVzIjpbImRpc3RyaWN0X2hlYWQiXSwicG9zaXRpb25JZCI6Ijk4OTkzN2I2LTg0YTgtNDZiMi1hOTViLTc3YjAxNTY2MDIzMyIsInBlcm1pc3Npb24iOiJSRUFEX09OTFkiLCJpYXQiOjE3ODczMDk3MTksImV4cCI6MTc4NzM5NjExOX0.FGZgQ_IHPXkrqgHI-UPdy_UhNW9no7dOB3Y8qf4aGG8';
  
  final headers = {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  final url = Uri.parse('$baseUrl/feed/getAllPosts?page=1&limit=2');
  final response = await http.get(url, headers: headers);
  final decoded = jsonDecode(response.body);
  final posts = decoded['data'] as List;
  final postId = posts[0]['_id'] ?? posts[0]['postId'];

  final endpoints = [
    '/feed/like/$postId',
    '/feed/$postId/like', // GET like might return likes?
    '/feed/get-likes/$postId',
    '/feed/$postId',
    '/like/$postId',
    '/likes/$postId',
  ];

  for(final e in endpoints) {
    final likeUrl = Uri.parse('$baseUrl$e');
    final likeRes = await http.get(likeUrl, headers: headers);
    print('GET $e: ${likeRes.statusCode}');
  }
}
