import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

void main() async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://udyami-circle-db.onrender.com/feed/createPost'));

  request.headers['accept'] = '*/*';
  request.headers['Authorization'] =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwYzY5MjVjZC0zZmNmLTRiZDQtOGM1MS00ZWU4ZmYwN2FiNjQiLCJlbWFpbCI6Im1zLmFwcHByb2plY3RAdW5kZWZpbmVkLmNvbSIsImlhdCI6MTczNjA5NzE2NSwiZXhwIjoxNzY3NjMzMTY1fQ.sJ9f1R6oN72ZOPp605hQ3vKjQ0dGzU14oKkEomrT3_w'; // Dummy token or user token if available? Wait, no, maybe the API doesn't need auth, or the user already provided one in ApiClient.

  // Using the dummy token from the curl example!
  request.fields['userId'] = 'd787871d-1c38-4d31-bfcf-7e7d4e910600';
  request.fields['content'] = 'Today we completed an important community meeting.';

  try {
    var response = await request.send();
    print('Status Code: ${response.statusCode}');
    var responseData = await response.stream.bytesToString();
    print('Response Data: $responseData');
  } catch (e) {
    print('Error: $e');
  }
}
