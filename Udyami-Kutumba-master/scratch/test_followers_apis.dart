import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkNzg3ODcxZC0xYzM4LTRkMzEtYmZjZi03ZTdkNGU5MTA2MDAiLCJlbWFpbCI6InZhbGlwaW5hdmVlbmt1bWFyOUBnbWFpbC5jb20iLCJyb2xlcyI6W10sImlhdCI6MTc4NzU1MDcyNSwiZXhwIjoxNzg3NjM3MTI1fQ.aNjQAXSOTeIhaxsnSHc-ZVQP5ZYObjIgKYDu-lRsHWI';
  String userId = 'd787871d-1c38-4d31-bfcf-7e7d4e910600'; // my user ID
  
  var endpoints = [
    '/user/followers/$userId',
    '/user/following/$userId',
    '/userprofile/followers/$userId',
    '/userprofile/following/$userId',
    '/user/getFollowers/$userId',
    '/user/getFollowing/$userId',
    '/follow/getFollowers/$userId',
    '/follow/followers/$userId',
  ];

  for (var ep in endpoints) {
    try {
      var res = await http.get(
        Uri.parse('https://backend.udyamikutumba.com$ep'),
        headers: { 'Authorization': 'Bearer $token', 'accept': '*/*' }
      );
      print('GET $ep -> ${res.statusCode} (Length: ${res.body.length})');
      if (res.statusCode == 200 || res.statusCode == 201) {
         print(res.body.substring(0, res.body.length > 200 ? 200 : res.body.length));
      }
    } catch(e) {
      print('Error on $ep: $e');
    }
  }
}
