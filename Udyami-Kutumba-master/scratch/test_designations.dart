import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://backend.udyamikutumba.com/udyamimngt/designations');
  final response = await http.get(url);
  print(response.statusCode);
  print(response.body);
}
