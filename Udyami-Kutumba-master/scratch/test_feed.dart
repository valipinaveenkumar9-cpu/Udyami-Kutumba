import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://backend.udyamikutumba.com/feed/getAllPosts?page=1&limit=10');
  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwYzY5MjVjZC0zZmNmLTRiZDQtOGM1MS00ZWU4ZmYwN2FiNjQiLCJlbWFpbCI6Im1zLmFwcHByb2plY3RzQGdtYWlsLmNvbSIsInJvbGVzIjpbImRpc3RyaWN0X2hlYWQiXSwicG9zaXRpb25JZCI6Ijk4OTkzN2I2LTg0YTgtNDZiMi1hOTViLTc3YjAxNTY2MDIzMyIsInBlcm1pc3Npb24iOiJSRUFEX09OTFkiLCJpYXQiOjE3ODczMDk3MTksImV4cCI6MTc4NzM5NjExOX0.FGZgQ_IHPXkrqgHI-UPdy_UhNW9no7dOB3Y8qf4aGG8",
      "Content-Type": "application/json",
    }
  );
  
  if (response.statusCode == 200) {
    var decoded = jsonDecode(response.body);
    print("Success. Contains data? ${decoded.containsKey('data')}");
    var data = decoded['data'] as List;
    print("Total items: ${data.length}");
    
    for (var i = 0; i < (data.length < 2 ? data.length : 2); i++) {
       print("User: ${data[i]['user']?['name']}");
       print("Media: ${data[i]['media']?.length}");
    }
  } else {
    print("Error: ${response.statusCode}");
  }
}
