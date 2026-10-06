import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:udyamikutumba/core/models/post_model.dart';

void main() async {
  final url = Uri.parse('https://backend.udyamikutumba.com/feed/getAllPosts?limit=10');
  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwYzY5MjVjZC0zZmNmLTRiZDQtOGM1MS00ZWU4ZmYwN2FiNjQiLCJlbWFpbCI6Im1zLmFwcHByb2plY3RzQGdtYWlsLmNvbSIsInJvbGVzIjpbImRpc3RyaWN0X2hlYWQiXSwicG9zaXRpb25JZCI6Ijk4OTkzN2I2LTg0YTgtNDZiMi1hOTViLTc3YjAxNTY2MDIzMyIsInBlcm1pc3Npb24iOiJSRUFEX09OTFkiLCJpYXQiOjE3ODczMDk3MTksImV4cCI6MTc4NzM5NjExOX0.FGZgQ_IHPXkrqgHI-UPdy_UhNW9no7dOB3Y8qf4aGG8",
      "Content-Type": "application/json",
    }
  );
  
  if (response.statusCode == 200) {
    var decoded = jsonDecode(response.body);
    var data = decoded['data'] as List;
    for (var m in data) {
      try {
        var post = PostModel.fromJson(m);
        print("Successfully parsed post: ${post.postId} - ${post.name} - ${post.content}");
      } catch (e) {
        print("Failed to parse post: $e");
      }
    }
  }
}
